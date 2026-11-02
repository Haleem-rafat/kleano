// import noInternet from '@assets/animations/no-internet.json';
// import { ReactComponent as MainZapicon } from '@assets/icons/main_zap_icon.svg';

const NoInternet = (): JSX.Element => {
  return (
    <div className=" flex flex-col items-center justify-center pb-8">
      {/* <MainZapicon className="mx-5 my-10 min-h-[80px] min-w-[60px] self-start" /> */}
      {/* <Lottie animationData={noInternet} className="!cursor-default" /> */}
      <p className="mx-auto py-2 text-center text-xl font-medium text-primary">
        No, internet connections
      </p>
      <p className="text-primary-Variant text-center">
        Check your ethernet or wifi and connect again
      </p>
    </div>
  );
};

export default NoInternet;
