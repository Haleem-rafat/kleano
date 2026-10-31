import useSWR from 'swr';
import washingServicesService from '@services/washingServices.service';
import { IwshaingServicesList } from '@servicesTypes/wshaingServices.types';

const useGetWashingServicesIcons = () => {
  const { data, error, isLoading } = useSWR(['get-washing-services-icons'], () =>
    {
    return  washingServicesService.getWashingServicesList().then((res) => {
    return (
      res?.data?.map((e: IwshaingServicesList) => ({
      label: e.name , // Display the name as the label
      value: e._id,       // Set the value as the ID
    })) || []
    )})
  });
  return {
    washingServicesIoncsOptions: data || [], // Ensure we always return an array
    loadingwashingServicesIoncsOptions: isLoading,
    errorwashingServicesIoncsOptions: error,
  };
};

export default useGetWashingServicesIcons;
