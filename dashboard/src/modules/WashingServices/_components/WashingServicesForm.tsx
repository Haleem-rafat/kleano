import React, { Dispatch, SetStateAction, useState } from 'react';
import washingServicesService from '@services/washingServices.service';
import { Form, FormControl, FormField, FormItem } from '@shadecn/components/ui/form';
import { yupResolver } from '@hookform/resolvers/yup';
import { useForm } from 'react-hook-form';
import {
  Button,
  MainInput,
  MainSelect,
  ThreeDotsLoader,
  MainMultiLangInput,
  MultiLangDescriptionListInputs,
} from '@UI/Index'; // Ensure these components are correctly imported
import { EFormFieldType } from '@constants/enums';
import { toast } from 'react-toastify';
import { useTranslation } from 'react-i18next';
import { mutate } from 'swr';
import { IwshaingServicesList } from '@servicesTypes/wshaingServices.types';
import { t } from 'i18next';
import useGetCitiesOptions from '@/hooks/useGetCitiesOptions';
import useGetIconsOptions from '@/hooks/useGetIconsOptions';

interface IWashingServicesFormProps {
  setOpenSheet: Dispatch<SetStateAction<boolean>>;
  oldData?: IwshaingServicesList;
}
export default function WashingServicesForm({ setOpenSheet, oldData }: IWashingServicesFormProps) {
  const [isloading, setIsLoading] = useState(false);
  const selectAllCities = false;

  const { citiesOptions, loadingCitiesOptions } = useGetCitiesOptions();
  const { iconsOptions, loadingiconsOptions } = useGetIconsOptions();

  const { i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';

  // Convert old description format (string[]) to new format ({ en, ar }[])
  const convertDescriptions = (
    descriptions: Array<string | { en?: string; ar?: string }> | undefined
  ) => {
    if (!descriptions || descriptions.length === 0) return [];

    // Check if it's already in the new format
    if (typeof descriptions[0] === 'object' && 'en' in descriptions[0]) {
      return descriptions as Array<{ en?: string; ar?: string }>;
    }

    // Convert old format (string[]) to new format
    return descriptions.map((desc) => ({
      en: typeof desc === 'string' ? desc : '',
      ar: '',
    }));
  };

  const form = useForm({
    resolver: yupResolver(washingServicesService.WashingServicesFormSchema),
    defaultValues: {
      servicesName: typeof oldData?.name === 'object' ? oldData.name : { en: '', ar: '' },
      duration: `${oldData?.duration}` || '',
      price: `${oldData?.price}` || '',
      pointsToPay: `${oldData?.pointsToPay ?? 0}`,
      icon: { label: '', value: oldData?.icon._id },
      type: { label: oldData?.type, value: oldData?.type },
      city:
        oldData?.cities?.map((e) => ({ label: e?.city?.name[lang], value: e?.city?._id })) || [],
      description: convertDescriptions(oldData?.description),
    },
  });

  const handelOnSubmit = (values) => {
    setIsLoading(true);
    const body = {
      name: values.servicesName,
      duration: +values.duration,
      durationUnit: 'min',
      price: +values.price,
      pointsToPay: +values.pointsToPay || 0,
      type: values.type.value,
      icon: values.icon.value,
      cities: selectAllCities ? [] : values.city?.map((e) => e?.value),
      description: values.description,
      selectAll: selectAllCities,
    };

    const api = oldData
      ? washingServicesService.editWashingServices(oldData?._id, body)
      : washingServicesService.addWashingServices(body);

    api
      .then(() => {
        mutate((key: string) => key.includes('get-washing-services-list'));
        mutate((key: string) => key.includes('get-washing-services-Details'));
        setOpenSheet(false);
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

  return (
    <div className="h-screen overflow-y-scroll pb-36 scrollbar-hide">
      {loadingCitiesOptions && loadingiconsOptions && <ThreeDotsLoader />}
      <Form {...form}>
        <form onSubmit={form.handleSubmit(handelOnSubmit)} className="flex flex-col gap-4 py-5 ">
          {washingServicesService.WashingServicesFormFields.map((WashingServicesFormField) => (
            <FormField
              key={WashingServicesFormField.name}
              control={form.control}
              name={WashingServicesFormField.name as any}
              render={({ field }) => (
                <FormItem>
                  <FormControl>
                    {(() => {
                      switch (WashingServicesFormField.type) {
                        case EFormFieldType.NUMBER:
                          return (
                            <MainInput
                              label={WashingServicesFormField.title}
                              placeholder={WashingServicesFormField.placeholder}
                              type="number"
                              field={{ ...field }}
                            />
                          );

                        case EFormFieldType.MULTI_SELECT:
                          return (
                            <MainSelect
                              title={WashingServicesFormField.title}
                              placeholder={WashingServicesFormField.placeholder}
                              multiSelect={WashingServicesFormField.name === 'icon' ? false : true}
                              options={
                                WashingServicesFormField.name === 'icon'
                                  ? iconsOptions
                                  : citiesOptions
                              }
                              field={{ ...field }}
                            />
                          );
                        case EFormFieldType.SELECT:
                          return (
                            <MainSelect
                              title={WashingServicesFormField.title}
                              placeholder={WashingServicesFormField.placeholder}
                              multiSelect={false}
                              options={
                                WashingServicesFormField.name === 'type' && [
                                  {
                                    label: 'main',
                                    value: 'main',
                                  },
                                  {
                                    label: 'extra',
                                    value: 'extra',
                                  },
                                ]
                              }
                              field={{ ...field }}
                            />
                          );
                        case EFormFieldType.DESCRIPTIONS:
                          return (
                            <MultiLangDescriptionListInputs
                              label={WashingServicesFormField.title}
                              placeholderEn={`${WashingServicesFormField.placeholder} (English)`}
                              placeholderAr={`${WashingServicesFormField.placeholder} (اللغة العربية)`}
                              field={field}
                            />
                          );

                        default:
                          return WashingServicesFormField.name === 'servicesName' ? (
                            <MainMultiLangInput
                              label={WashingServicesFormField.title}
                              placeholderEn={`${WashingServicesFormField.placeholder} (English)`}
                              placeholderAr={`${WashingServicesFormField.placeholder} (اللغة العربية)`}
                              field={{ ...field }}
                            />
                          ) : (
                            <MainInput
                              label={WashingServicesFormField.title}
                              placeholder={WashingServicesFormField.placeholder}
                              field={{ ...field }}
                              type="text"
                            />
                          );
                      }
                    })()}
                  </FormControl>
                </FormItem>
              )}
            />
          ))}
          <div className="absolute bottom-0 left-0 w-full border-t-2 bg-white p-4">
            <Button type="submit" size="md" className="mt-3 w-full" loading={isloading}>
              {oldData ? t('applyEdit') : t('add')}
            </Button>
          </div>
        </form>
      </Form>
    </div>
  );
}
