import React from 'react';
import { MapContainer, TileLayer, Marker, Popup } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import L from 'leaflet';

// Fix Leaflet marker icons for Vite/Webpack
import markerIcon2x from 'leaflet/dist/images/marker-icon-2x.png';
import markerIcon from 'leaflet/dist/images/marker-icon.png';
import markerShadow from 'leaflet/dist/images/marker-shadow.png';

const DefaultIcon = L.icon({
  iconUrl: markerIcon,
  iconRetinaUrl: markerIcon2x,
  shadowUrl: markerShadow,
  iconSize: [25, 41],
  iconAnchor: [12, 41],
});
L.Marker.prototype.options.icon = DefaultIcon;

type MapWithMarkersProps = {
  latitude: number;
  longitude: number;
  zoom?: number;
  height?: string;
  popupContent?: React.ReactNode;
  markerTitle?: string;
  className?: string;
};

const MapWithMarkers: React.FC<MapWithMarkersProps> = ({
  latitude,
  longitude,
  zoom = 13,
  popupContent,
  markerTitle,
  height = '500px',
  className,
}) => {
  if (!latitude || !longitude) {
    return <p>No markers to display</p>;
  }

  const center = [latitude, longitude] as [number, number];

  return (
    <div style={{ width: '100%', height }}>
      <MapContainer
        center={center}
        zoom={zoom}
        style={{ height: '100%', width: '100%', borderRadius: '12px' }}
        className={className}>
        <TileLayer
          url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
        />
        <Marker position={[latitude, longitude]} title={markerTitle}>
          <Popup>{popupContent} </Popup>
        </Marker>
      </MapContainer>
    </div>
  );
};

export default MapWithMarkers;
