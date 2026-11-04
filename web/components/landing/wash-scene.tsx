'use client';

/* three.js objects are changed in place every frame, which is how react-three-fiber works. */
/* eslint-disable react-hooks/immutability */

import { Bvh, ContactShadows, Environment, Lightformer, Sparkles, useGLTF } from '@react-three/drei';
import { Canvas, useFrame, type ThreeEvent } from '@react-three/fiber';
import type { MotionValue } from 'motion/react';
import { memo, Suspense, useEffect, useMemo, useRef, type RefObject } from 'react';
import * as THREE from 'three';

/**
 * The 3D wash. The car is a real model (Khronos "Car Concept", CC-BY 4.0, see content.ts for the
 * credit), compressed to about 1.4 MB and repainted in Kleano purple. Dirt is added to the car's
 * own materials in the shader, and a canvas says where it remains: spraying paints that canvas
 * clean where the pointer hits. Loaded late by wash-3d.tsx and stopped while off screen.
 */

const MODEL = '/models/kleano-car.glb';
const PAINT = '#5b2f70'; // Kleano's brand purple, a touch deeper so it reads as car paint
const CAR_LENGTH = 4.6;

const MASK = 512;
const GRID = 64;
const BRUSH = 0.05; // in mask units: about a hand's width on the car
const CLEAN_AT = 0.85;
const CLEAN_PARTS = new Set(['', 'mechanical', 'tireside', 'tiretread', 'disc', 'brake']); // never look dirty

export type SprayState = { onCar: boolean };

/**
 * The dirt is projected onto the car from the viewer's side (a three-quarter view), so every
 * surface the viewer can see has its own patch of the mask.
 */
const VIEW = new THREE.Vector3(0.55, 0.42, 0.72).normalize();
const AXIS_U = new THREE.Vector3(0, 1, 0).cross(VIEW).normalize();
const AXIS_V = new THREE.Vector3().crossVectors(VIEW, AXIS_U).normalize();
const toMask = (p: THREE.Vector3) => ({ u: (p.dot(AXIS_U) + 3) / 6, v: (p.dot(AXIS_V) + 3) / 6 });

// ---- Dirt mask -------------------------------------------------------------------------------

/**
 * Grime, white where dirty and black where clean. It is painted small and enlarged, which softens
 * it like a real film of dirt, with thin runs on top where water has dried.
 */
function paintDirt(ctx: CanvasRenderingContext2D) {
  const small = document.createElement('canvas');
  small.width = small.height = 96;
  const s = small.getContext('2d') as CanvasRenderingContext2D;
  s.fillStyle = '#d6d6d6';
  s.fillRect(0, 0, 96, 96);
  for (let i = 0; i < 240; i++) {
    const shade = Math.random() > 0.5 ? 255 : 90;
    s.fillStyle = `rgba(${shade},${shade},${shade},${0.08 + Math.random() * 0.22})`;
    s.beginPath();
    s.ellipse(Math.random() * 96, Math.random() * 96, 1 + Math.random() * 7, 1 + Math.random() * 4, Math.random() * 3, 0, Math.PI * 2);
    s.fill();
  }
  ctx.globalCompositeOperation = 'source-over';
  ctx.imageSmoothingEnabled = true;
  ctx.imageSmoothingQuality = 'high';
  ctx.drawImage(small, 0, 0, MASK, MASK);
  for (let i = 0; i < 90; i++) {
    const x = Math.random() * MASK;
    const y = Math.random() * MASK;
    ctx.strokeStyle = `rgba(120,120,120,${0.05 + Math.random() * 0.1})`;
    ctx.lineWidth = 0.6 + Math.random() * 1.4;
    ctx.beginPath();
    ctx.moveTo(x, y);
    ctx.lineTo(x + (Math.random() - 0.5) * 4, y + 8 + Math.random() * 26);
    ctx.stroke();
  }
}

function eraseAt(ctx: CanvasRenderingContext2D, u: number, v: number) {
  const x = u * MASK;
  const y = (1 - v) * MASK;
  const r = BRUSH * MASK;
  const g = ctx.createRadialGradient(x, y, r * 0.4, x, y, r);
  g.addColorStop(0, 'rgba(0,0,0,0.98)');
  g.addColorStop(1, 'rgba(0,0,0,0)');
  ctx.fillStyle = g;
  ctx.fillRect(x - r, y - r, r * 2, r * 2);
}

/** Adds the dirt to a three.js physical material: duller, browner, no clear coat where it is dirty. */
function addDirt(material: THREE.MeshStandardMaterial, mask: THREE.Texture) {
  material.onBeforeCompile = (shader) => {
    shader.uniforms.uDirt = { value: mask };
    shader.uniforms.uAxisU = { value: AXIS_U };
    shader.uniforms.uAxisV = { value: AXIS_V };
    shader.vertexShader = shader.vertexShader
      .replace('#include <common>', '#include <common>\nvarying vec3 vDirtPos;')
      .replace('#include <project_vertex>', '#include <project_vertex>\nvDirtPos = (modelMatrix * vec4(transformed, 1.0)).xyz;');
    shader.fragmentShader = shader.fragmentShader
      .replace(
        '#include <common>',
        `#include <common>
        varying vec3 vDirtPos;
        uniform sampler2D uDirt;
        uniform vec3 uAxisU;
        uniform vec3 uAxisV;
        float dirtAmount;`,
      )
      .replace(
        '#include <map_fragment>',
        `#include <map_fragment>
        float dirtMask = texture2D(uDirt, (vec2(dot(vDirtPos, uAxisU), dot(vDirtPos, uAxisV)) + 3.0) / 6.0).r;
        // Dirt fully hides the paint; the mask's patches show as darker and lighter grime.
        dirtAmount = smoothstep(0.06, 0.42, dirtMask);
        float dirtHeight = smoothstep(0.15, 1.05, vDirtPos.y);
        vec3 grime = mix(vec3(0.06, 0.042, 0.028), vec3(0.235, 0.19, 0.135), dirtHeight) * (0.45 + 0.75 * dirtMask * dirtMask);
        diffuseColor.rgb = mix(diffuseColor.rgb, grime, dirtAmount);`,
      )
      .replace('#include <roughnessmap_fragment>', '#include <roughnessmap_fragment>\nroughnessFactor = mix(roughnessFactor, 0.96, dirtAmount);')
      .replace('#include <metalnessmap_fragment>', '#include <metalnessmap_fragment>\nmetalnessFactor = mix(metalnessFactor, 0.0, dirtAmount);')
      .replace(
        '#include <lights_physical_fragment>',
        `#include <lights_physical_fragment>
        #ifdef USE_CLEARCOAT
          material.clearcoat *= 1.0 - dirtAmount;
        #endif`,
      );
  };
  material.customProgramCacheKey = () => 'kleano-dirt';
  material.needsUpdate = true;
}

// ---- Foam ------------------------------------------------------------------------------------

const FOAM = 70;
type Foam = { spawn: (p: THREE.Vector3) => void };

function FoamParticles({ handle }: { handle: RefObject<Foam | null> }) {
  const mesh = useRef<THREE.InstancedMesh>(null);
  const pool = useMemo(() => Array.from({ length: FOAM }, () => ({ p: new THREE.Vector3(), life: 0, size: 0 })), []);
  const next = useRef(0);
  const dummy = useMemo(() => new THREE.Object3D(), []);

  useEffect(() => {
    const offset = new THREE.Vector3();
    handle.current = {
      spawn: (p) => {
        const item = pool[next.current];
        next.current = (next.current + 1) % FOAM;
        offset.set((Math.random() - 0.5) * 0.24, (Math.random() - 0.5) * 0.16, (Math.random() - 0.5) * 0.24);
        item.p.copy(p).add(offset).addScaledVector(VIEW, 0.03);
        item.life = 1;
        item.size = 0.03 + Math.random() * 0.055;
      },
    };
    return () => {
      handle.current = null;
    };
  }, [handle, pool]);

  useFrame((_, dt) => {
    if (!mesh.current) return;
    for (let i = 0; i < FOAM; i++) {
      const item = pool[i];
      item.life = Math.max(0, item.life - dt * 0.7);
      item.p.y -= dt * 0.09;
      dummy.position.copy(item.p);
      dummy.scale.setScalar(item.life > 0 ? item.size * (0.55 + item.life * 0.7) : 0);
      dummy.updateMatrix();
      mesh.current.setMatrixAt(i, dummy.matrix);
    }
    mesh.current.instanceMatrix.needsUpdate = true;
  });

  return (
    <instancedMesh ref={mesh} args={[undefined, undefined, FOAM]} frustumCulled={false}>
      <sphereGeometry args={[1, 10, 8]} />
      <meshPhysicalMaterial color="#ffffff" roughness={0.45} clearcoat={0.6} />
    </instancedMesh>
  );
}

// ---- Car -------------------------------------------------------------------------------------

function Car({
  mask,
  onSpray,
  onOut,
  onLoaded,
}: {
  mask: THREE.Texture;
  onSpray: (e: ThreeEvent<PointerEvent>) => void;
  onOut: () => void;
  onLoaded: (car: THREE.Object3D) => void;
}) {
  const { scene } = useGLTF(MODEL);

  const car = useMemo(() => {
    const clone = scene.clone(true);
    const seen = new Map<THREE.Material, THREE.Material>();
    clone.traverse((obj) => {
      const mesh = obj as THREE.Mesh;
      if (!mesh.isMesh) return;
      const source = mesh.material as THREE.MeshPhysicalMaterial;
      let material = seen.get(source) as THREE.MeshPhysicalMaterial | undefined;
      if (!material) {
        material = source.clone();
        seen.set(source, material);
        const name = source.name.toLowerCase();
        if (name.startsWith('paint')) {
          // Kleano purple with a deep lacquer. The model's orange-peel normal map stays subtle.
          material.color.set(PAINT);
          material.map = null;
          material.metalness = 0.55;
          material.roughness = 0.34;
          if ('clearcoat' in material) {
            material.clearcoat = 1;
            material.clearcoatRoughness = 0.06;
          }
          material.iridescence = 0;
          material.sheen = 0; // the model's sheen tints the dirt pink
        }
        if (name === 'glass') {
          // Tinted glass with no live see-through: it looks sharp and costs far less to draw.
          material.transmission = 0;
          material.color.set('#090a10');
          material.metalness = 0.9;
          material.roughness = 0.06;
          material.clearcoat = 1;
        }
        if (!CLEAN_PARTS.has(name)) addDirt(material, mask);
      }
      mesh.material = material;
      mesh.castShadow = false;
      mesh.receiveShadow = false;
    });

    // Point the nose along +x, centre it, stand it on the ground and set a real-car length.
    const holder = new THREE.Group();
    clone.rotation.y = Math.PI / 2;
    holder.add(clone);
    holder.updateMatrixWorld(true);
    const box = new THREE.Box3().setFromObject(holder, true); // exact: the quick box is far too big here
    const size = box.getSize(new THREE.Vector3());
    const center = box.getCenter(new THREE.Vector3());
    const scale = CAR_LENGTH / Math.max(size.x, size.z);
    holder.scale.setScalar(scale);
    holder.position.set(-center.x * scale, -box.min.y * scale, -center.z * scale);
    return holder;
  }, [scene, mask]);

  // One frame later, so the Bvh below has built its search trees before the car is measured.
  useEffect(() => {
    const id = requestAnimationFrame(() => onLoaded(car));
    return () => cancelAnimationFrame(id);
  }, [car, onLoaded]);

  return (
    <Bvh firstHitOnly>
      <primitive object={car} onPointerMove={onSpray} onPointerDown={onSpray} onPointerOut={onOut} />
    </Bvh>
  );
}

// ---- Floor -------------------------------------------------------------------------------------

/** A soft pool of light under the car, in Kleano purple, so it stands on something. */
function Floor() {
  const texture = useMemo(() => {
    const c = document.createElement('canvas');
    c.width = c.height = 256;
    const ctx = c.getContext('2d') as CanvasRenderingContext2D;
    const g = ctx.createRadialGradient(128, 128, 0, 128, 128, 128);
    g.addColorStop(0, 'rgba(150,100,180,0.34)');
    g.addColorStop(0.55, 'rgba(150,100,180,0.1)');
    g.addColorStop(1, 'rgba(150,100,180,0)');
    ctx.fillStyle = g;
    ctx.fillRect(0, 0, 256, 256);
    const t = new THREE.CanvasTexture(c);
    t.colorSpace = THREE.SRGBColorSpace;
    return t;
  }, []);
  return (
    <mesh rotation={[-Math.PI / 2, 0, 0]} position={[0, 0.001, 0]} raycast={() => null}>
      <planeGeometry args={[8.6, 5.4]} />
      <meshBasicMaterial map={texture} transparent depthWrite={false} toneMapped={false} />
    </mesh>
  );
}

// ---- Camera ----------------------------------------------------------------------------------

/** Frames the car for any shape of screen and turns gently as the page scrolls. */
function CameraRig({ progress }: { progress: MotionValue<number> }) {
  useFrame(({ camera, size }) => {
    const aspect = size.width / size.height;
    const half = 2.8; // half the car's length, plus a margin
    const tan = Math.tan(THREE.MathUtils.degToRad(13));
    const distance = Math.max(half / (tan * aspect), 1.66 / tan);
    const angle = Math.atan2(VIEW.x, VIEW.z) + (progress.get() - 0.5) * 0.42;
    const flat = Math.cos(0.27);
    camera.position.set(Math.sin(angle) * distance * flat, Math.sin(0.27) * distance + 0.5, Math.cos(angle) * distance * flat);
    camera.lookAt(0, 0.56, 0);
  });
  return null;
}

// ---- Scene -----------------------------------------------------------------------------------

function Scene({
  progress,
  spray,
  resetKey,
  onCleaned,
  onReady,
}: {
  progress: MotionValue<number>;
  spray: RefObject<SprayState>;
  resetKey: number;
  onCleaned: (fraction: number) => void;
  onReady: () => void;
}) {
  const foam = useRef<Foam | null>(null);
  const carRef = useRef<THREE.Object3D | null>(null);
  const cells = useRef<{ wanted: Set<number>; done: Set<number> }>({ wanted: new Set(), done: new Set() });
  const finished = useRef(false);
  const lastHit = useRef<{ u: number; v: number } | null>(null);
  const sparkle = useRef<THREE.Group>(null);
  const shine = useRef(0);

  const { ctx, texture } = useMemo(() => {
    const c = document.createElement('canvas');
    c.width = MASK;
    c.height = MASK;
    return { ctx: c.getContext('2d') as CanvasRenderingContext2D, texture: new THREE.CanvasTexture(c) };
  }, []);

  /** Finds which parts of the mask lie on the car: only those count as dirt to clean. */
  const measure = useMemo(
    () => (car: THREE.Object3D) => {
      carRef.current = car;
      car.updateWorldMatrix(true, true);
      const ray = new THREE.Raycaster();
      (ray as THREE.Raycaster & { firstHitOnly: boolean }).firstHitOnly = true;
      const dir = VIEW.clone().negate();
      const origin = new THREE.Vector3();
      const wanted = new Set<number>();
      for (let a = -3; a <= 3; a += 6 / GRID) {
        for (let b = -3; b <= 3; b += 6 / GRID) {
          origin.copy(VIEW).multiplyScalar(8).addScaledVector(AXIS_U, a).addScaledVector(AXIS_V, b);
          ray.set(origin, dir);
          if (ray.intersectObject(car, true).length) {
            wanted.add(Math.floor(((a + 3) / 6) * GRID) + Math.floor(((b + 3) / 6) * GRID) * GRID);
          }
        }
      }
      cells.current = { wanted, done: new Set() };
      onCleaned(0);
      onReady();
    },
    [onCleaned, onReady],
  );

  useEffect(() => {
    paintDirt(ctx);
    texture.needsUpdate = true;
    finished.current = false;
    shine.current = 0;
    if (sparkle.current) sparkle.current.visible = false;
    if (carRef.current) cells.current.done = new Set();
    onCleaned(0);
  }, [resetKey, ctx, texture, onCleaned]);

  const onSpray = (e: ThreeEvent<PointerEvent>) => {
    spray.current.onCar = true;
    const { u, v } = toMask(e.point);
    // Fill the gap since the last hit, so a fast hand leaves a line and not a row of dots.
    const last = lastHit.current;
    const gap = last ? Math.hypot(u - last.u, v - last.v) : 0;
    const steps = last && gap < 0.3 ? Math.ceil(gap / (BRUSH * 0.5)) : 0;
    const hits = [{ u, v }];
    for (let i = 1; i < steps; i++) hits.push({ u: last!.u + ((u - last!.u) * i) / steps, v: last!.v + ((v - last!.v) * i) / steps });
    lastHit.current = { u, v };
    for (const hit of hits) eraseAt(ctx, hit.u, hit.v);
    texture.needsUpdate = true;
    foam.current?.spawn(e.point);
    if (finished.current) return;

    const { wanted, done } = cells.current;
    // Counted a little inside the brush's soft edge, so the number matches what looks clean.
    const reach = Math.ceil(BRUSH * GRID * 0.7);
    for (const hit of hits) {
      const cu = Math.floor(hit.u * GRID);
      const cv = Math.floor(hit.v * GRID);
      for (let a = -reach; a <= reach; a++) {
        for (let b = -reach; b <= reach; b++) {
          const key = cu + a + (cv + b) * GRID;
          if (a * a + b * b <= reach * reach && wanted.has(key)) done.add(key);
        }
      }
    }
    const fraction = wanted.size ? done.size / wanted.size : 0;
    if (fraction >= CLEAN_AT) {
      // The last of the dirt rinses off and the car shines.
      finished.current = true;
      ctx.fillStyle = '#000';
      ctx.fillRect(0, 0, MASK, MASK);
      texture.needsUpdate = true;
      shine.current = 1;
      if (sparkle.current) sparkle.current.visible = true;
      onCleaned(1);
    } else {
      onCleaned(fraction);
    }
  };

  const onOut = () => {
    spray.current.onCar = false;
    lastHit.current = null;
  };

  // A sweep of brighter reflections when the car comes clean.
  const sweep = useRef<THREE.DirectionalLight>(null);
  useFrame((_, dt) => {
    shine.current = Math.max(0, shine.current - dt * 0.35);
    if (sweep.current) sweep.current.intensity = shine.current * 5;
  });

  return (
    <>
      <CameraRig progress={progress} />
      <ambientLight intensity={0.35} />
      <directionalLight position={[3, 6, 5]} intensity={1.1} />
      <directionalLight ref={sweep} position={[-3, 5, 6]} intensity={0} />

      {/* A studio made of soft lights, for the long reflections on the paint. No file is downloaded. */}
      <Environment resolution={256} frames={1}>
        <color attach="background" args={['#08070b']} />
        <Lightformer form="rect" intensity={5} position={[0, 6, 0]} scale={[12, 3.2, 1]} rotation={[Math.PI / 2, 0, 0]} />
        <Lightformer form="rect" intensity={1.6} position={[0, 2.4, 7]} scale={[14, 0.9, 1]} />
        <Lightformer form="rect" intensity={2.6} color="#e4d8ec" position={[-8, 1.6, 2]} scale={[8, 1.4, 1]} rotation={[0, Math.PI / 2, 0]} />
        <Lightformer form="rect" intensity={2} position={[8, 2, -1]} scale={[8, 1.6, 1]} rotation={[0, -Math.PI / 2, 0]} />
        <Lightformer form="rect" intensity={1.8} position={[-3, 5, -7]} scale={[12, 2.4, 1]} rotation={[0.6, Math.PI, 0]} />
        <Lightformer form="ring" intensity={1.4} color="#ffffff" position={[3, 3, 6]} scale={3} />
      </Environment>

      <Suspense fallback={null}>
        <Car mask={texture} onSpray={onSpray} onOut={onOut} onLoaded={measure} />
        {/* Drawn once, so it must arrive together with the car. */}
        <ContactShadows renderOrder={1} position={[0, 0.004, 0]} opacity={0.8} width={10} height={7} blur={1.8} far={1.6} resolution={512} frames={1} color="#000000" />
      </Suspense>
      <FoamParticles handle={foam} />
      <group ref={sparkle} visible={false}>
        <Sparkles count={70} scale={[5.2, 1.6, 2.6]} position={[0, 0.8, 0]} size={5} speed={0.5} color="#ffffff" />
      </group>
      <Floor />
    </>
  );
}

const WashScene = memo(function WashScene({
  active,
  progress,
  spray,
  resetKey,
  onCleaned,
  onReady,
}: {
  active: boolean;
  progress: MotionValue<number>;
  spray: RefObject<SprayState>;
  resetKey: number;
  onCleaned: (fraction: number) => void;
  onReady: () => void;
}) {
  return (
    <Canvas
      frameloop={active ? 'always' : 'never'}
      dpr={[1, typeof window !== 'undefined' && window.innerWidth < 768 ? 1.5 : 2]}
      camera={{ fov: 26, near: 0.5, far: 80, position: [6, 3, 9] }}
      gl={{ antialias: true, alpha: true, powerPreference: 'high-performance', toneMapping: THREE.ACESFilmicToneMapping, toneMappingExposure: 1.05 }}
      style={{ touchAction: 'pan-y' }}
    >
      <Scene progress={progress} spray={spray} resetKey={resetKey} onCleaned={onCleaned} onReady={onReady} />
    </Canvas>
  );
});

export default WashScene;
