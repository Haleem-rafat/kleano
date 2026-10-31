import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import useSWR from 'swr';

import staticService from '@services/static.service';
import { Icities } from '@servicesTypes/cities.types';

const useGetAreasOptions = (citieId) => {
  const { i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';

  const [AreasOptions, setAreasOptions] = useState<{ value: string; label: string }[]>([]);

  const { error, isLoading } = useSWR(
    ['get-Areas', citieId],
    () =>
      citieId &&
      staticService.getAreasOptions(citieId).then((data) => {
        const options = [];
        (data?.data as Icities[])?.map((e: Icities) =>
          options.push({
            label: e?.name[lang],
            value: e?._id,
          })
        );
        setAreasOptions(options);
      })
  );

  return {
    AreasOptions,
    loadingAreasOptions: isLoading,
    errorAreasOptions: error,
  };
};

export default useGetAreasOptions;
