import { useState } from 'react';
import useSWR from 'swr';

import { IIcons } from '@servicesTypes/static.types';
import iconsService from '@services/icons.service';

const useGetIconsOptions = () => {
  const [iconsOptions, setIconsOptions] = useState<{ value: string; label: string }[]>([]);

  const { error, isLoading } = useSWR(['get-icons'], () =>
    iconsService.getIcons().then((data) => {
      const options = [];
      (data?.data as IIcons[])?.map((e: IIcons) =>
        options.push({
          label: <img src={e?.iconLink} className="max-h-[50px] max-w-[50px]" />,
          value: e?._id,
        })
      );
      setIconsOptions(options);
    })
  );

  return {
    iconsOptions,
    loadingiconsOptions: isLoading,
    erroriconsOptions: error,
  };
};

export default useGetIconsOptions;
