import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import useSWR from 'swr';

import staticService from '@services/static.service';
import { Icities } from '@servicesTypes/cities.types';

const useGetCitiesOptions = () => {
  const { i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';

  const [citiesOptions, setCitiesOptions] = useState<{ value: string; label: string }[]>([]);

  const { error, isLoading } = useSWR(['get-Cities'], () =>
    staticService.getCitiesOptions().then((data) => {
      const options = [];
      (data?.data as Icities[])?.map((e: Icities) =>
        options.push({
          label: e?.name[lang],
          value: e?._id,
        })
      );
      setCitiesOptions(options);
    })
  );

  return {
    citiesOptions,
    loadingCitiesOptions: isLoading,
    errorCitiesOptions: error,
  };
};

export default useGetCitiesOptions;
