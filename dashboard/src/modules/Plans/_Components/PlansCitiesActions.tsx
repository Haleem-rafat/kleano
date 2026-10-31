import plansService from '@services/plans.service';
import washingServicesService from '@services/washingServices.service';
import { AddCityForm, CityStatusTable } from '@UI/Index';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { toast } from 'react-toastify';
import { mutate } from 'swr';
import useGetCitiesOptions from '@/hooks/useGetCitiesOptions';

export default function PlansCitiesActions({ servicesId, cityData }) {
  const [isLoading, setIsLoading] = useState(false);
  const { citiesOptions } = useGetCitiesOptions();

  const { t, i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';

  const handleAddCity = (values) => {
    setIsLoading(true);
    const body = {
      plan: servicesId,
      city: values.city.value,
    };

    plansService
      .addCityPlan(body)
      .then(() => {
        mutate((key: string) => key.includes('get-all-plans-details'));
        mutate((key: string) => key.includes('get-all-plans-list'));
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
    const body = { plan: servicesId, city: cityId };

    const apiCall =
      status === 'active' ? plansService.activeCityPlan(body) : plansService.archiveCityPlan(body);

    apiCall
      .then(() => {
        mutate((key: string) => key.includes('get-all-plans-list'));
        mutate((key: string) => key.includes('get-all-plans-details'));
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
