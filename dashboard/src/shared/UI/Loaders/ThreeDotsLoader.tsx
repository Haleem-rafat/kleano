import { ThreeDots } from 'react-loader-spinner';

export default function ThreeDotsLoader() {
  return (
    <div className="absolute z-10 h-full w-full animate-pulse overflow-hidden bg-white ">
      <div
        className=" absolute"
        style={{
          left: '50%',
          top: '50%',
          transform: 'translate(-50%, -50%)',
        }}>
        <ThreeDots
          height={80}
          width={80}
          color="#533063"
          visible={true as any}
          ariaLabel="oval-loading"
        />
      </div>
    </div>
  );
}
