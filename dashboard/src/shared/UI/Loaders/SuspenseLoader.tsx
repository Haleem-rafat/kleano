const SuspenseLoader = () => {
  return (
    <div className="flex h-screen w-screen items-center justify-center opacity-70">
      <div className="h-32 w-32 animate-pulse duration-150">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          preserveAspectRatio="xMidYMid"
          className="animate-spin"
          viewBox="0 0 100 100">
          <path fill="#533063" d="M10 50A40 40 0 0 0 90 50A40 42 0 0 1 10 50"></path>
        </svg>
      </div>
    </div>
  );
};

export default SuspenseLoader;
