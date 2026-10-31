import segmentsService from '@services/segments.service';
import { IAllSegment } from '@servicesTypes/segments.types';
import { useState } from 'react';
import useSWR from 'swr';

const useGetSegmentsOptions = (typeChange?: boolean) => {
  const [segmentsOptions, setSegmentsOptions] = useState<{ value: string; label: string }[]>([]);

  const { error, isLoading } = useSWR(
    ['get-Segments-options', typeChange],
    () =>
      typeChange &&
      segmentsService.getAllSegments().then((data) => {
        const options = [];
        (data?.data as IAllSegment[])?.map((e: IAllSegment) =>
          options.push({
            label: e?.name,
            value: e?._id,
          })
        );
        setSegmentsOptions(options);
      })
  );

  return {
    segmentsOptions,
    loadingSegmentsOptions: isLoading,
    errorSegmentsOptions: error,
  };
};

export default useGetSegmentsOptions;
