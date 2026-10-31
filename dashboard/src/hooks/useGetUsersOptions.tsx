import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import useSWR from 'swr';

import staticService from '@services/static.service';
import { IUsers } from '@servicesTypes/static.types';

const useGetUsersOptions = () => {
  const { i18n } = useTranslation();

  const [usersOptions, setUsersOptions] = useState<{ value: string; label: string }[]>([]);

  const { error, isLoading } = useSWR(['get-users'], () =>
    staticService.getUsersOptions().then((data) => {
      const options = [];
      (data?.data as IUsers[])?.map((e: IUsers) =>
        options.push({
          label: e?.userName,
          value: e?._id,
        })
      );
      setUsersOptions(options);
    })
  );

  return {
    usersOptions,
    loadingUsersOptions: isLoading,
    errorUsersOptions: error,
  };
};

export default useGetUsersOptions;
