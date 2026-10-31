import { useEffect, useState } from 'react';

function useInfiniteScroll(swrData, swrMutate, setPageIndex, isLoading) {
  const [dataList, setDataList] = useState<any[]>([]);

  const hasMore = swrData ? swrData?.page < swrData?.pages : false;

  const handleLoadMore = () => {
    if (swrData && swrData?.page < swrData?.pages) {
      setPageIndex((prevIndex) => prevIndex + 1);
      swrMutate();
    }
  };

  useEffect(() => {
    if (swrData && swrData?.page === 1 && !isLoading) {
      setDataList(swrData?.data);
    } else if (!isLoading && swrData && swrData?.page > 1) {
      setDataList((prevDataList) => [...prevDataList, ...(swrData?.data as any[])]);
    }
  }, [swrData]);

  return {
    hasMore,
    handleLoadMore,
    dataList,
  };
}

export default useInfiniteScroll;
