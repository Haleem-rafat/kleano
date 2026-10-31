import { AddCityForm, CityStatusTable } from '@UI/Index';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { toast } from 'react-toastify';
import { mutate } from 'swr';
import addOnsService from '@services/addOns.service';
import useGetCitiesOptions from '@/hooks/useGetCitiesOptions';

export default function AddOnsCitiesActions({ servicesId, cityData }) {
  const [isLoading, setIsLoading] = useState(false);
  const { citiesOptions } = useGetCitiesOptions();

  const { t, i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';

  const handleAddCity = (values) => {
    setIsLoading(true);
    const body = {
      addOns: servicesId,
      city: values.city.value,
    };

    addOnsService
      .addCityPlan(body)
      .then(() => {
        mutate((key: string) => key.includes('get-all-add-ons-details'));
        mutate((key: string) => key.includes('get-all-add-ons-list'));
      })
      .catch(({ response }) => {
        const messages = response?.data?.message;
        const errList = Array.isArray(messages)
          ? messages.map((e, index) => <p key={index}>{e}</p>)
          : messages?.[lang] || t('An error occurred');
        toast.error(<div>{errList}</div>);
      })
      .finally(() => {
        setIsLoading(false);
      });
  };

  const handleArchiveCity = (cityId) => {
    handleCityStatusChange('archive', cityId);
  };

  const handleActivateCity = (cityId) => {
    handleCityStatusChange('active', cityId);
  };

  const handleCityStatusChange = (status, cityId) => {
    setIsLoading(true);
    const body = { addOns: servicesId, city: cityId };

    const apiCall =
      status === 'active'
        ? addOnsService.activeCityPlan(body)
        : addOnsService.archiveCityPlan(body);

    apiCall
      .then(() => {
        mutate((key: string) => key.includes('get-all-add-ons-details'));
        mutate((key: string) => key.includes('get-all-add-ons-list'));
      })
      .catch((error) => {
        const errMessage = error.response?.data?.message || 'An error occurred';
        toast.error(errMessage);
      })
      .finally(() => {
        setIsLoading(false);
      });
  };

  return (
    <div className="relative rounded-lg bg-white p-4 shadow">
      {/* Table displaying city statuses */}
      <CityStatusTable
        citiesData={cityData}
        isLoading={isLoading}
        handleArchive={handleArchiveCity}
        handleActivate={handleActivateCity}
      />

      {/* Form for adding a new city */}
      <AddCityForm citiesOptions={citiesOptions} onSubmit={handleAddCity} isLoading={isLoading} />
    </div>
  );
}
