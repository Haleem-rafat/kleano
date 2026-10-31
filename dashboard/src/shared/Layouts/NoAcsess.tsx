import Lottie from 'lottie-react';
// import noAcsess from '@assets/animations/no-acsess.json';

const NoAcsess = (): JSX.Element => {
  return (
    <div className=" mt-32 flex flex-col items-center justify-center pb-8">
      {/* <Lottie animationData={noAcsess} className="!cursor-default" /> */}
      <p className="mx-auto py-2 text-center text-xl font-medium text-primary">
        No, Access permission
      </p>
      <p className="text-primary-Variant text-center">check your admin to access in this action</p>
    </div>
  );
};

export default NoAcsess;
