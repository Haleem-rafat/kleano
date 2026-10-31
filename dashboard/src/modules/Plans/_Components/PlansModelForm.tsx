import { SetStateAction, useState } from 'react';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';

import { EFormFieldType } from '@constants/enums';
import plansService from '@services/plans.service';

import { IPlan } from '@servicesTypes/plan.types';
import { Form, FormControl, FormField, FormItem } from '@shadecn/components/ui/form';
import {
  Button,
  MainColorInput,
  MainInput,
  MainSelect,
  ThreeDotsLoader,
  MainMultiLangInput,
  MultiLangDescriptionListInputs,
} from '@UI/Index';
import { t } from 'i18next';
import { toast } from 'react-toastify';
import { mutate } from 'swr';
import useGetWashingServicesIcons from '@/hooks/useGetWashingServicesIcons';
import useGetCitiesOptions from '@/hooks/useGetCitiesOptions';
import useGetIconsOptions from '@/hooks/useGetIconsOptions';

interface IPlansModelFormProps {
  setOpenSheet: React.Dispatch<SetStateAction<boolean>>;
  oldData?: IPlan;
}
const PlansModelForm = ({ setOpenSheet, oldData }: IPlansModelFormProps) => {
  const [isloading, setIsLoading] = useState(false);

  const { citiesOptions, loadingCitiesOptions } = useGetCitiesOptions();
  const { iconsOptions, loadingiconsOptions } = useGetIconsOptions();
  const { washingServicesIoncsOptions, loadingwashingServicesIoncsOptions } =
    useGetWashingServicesIcons();
  console.log(washingServicesIoncsOptions);
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

  // Convert old type format (string) to new format ({ en, ar })
  const convertType = (type: string | { en?: string; ar?: string } | undefined) => {
    if (!type) return { en: '', ar: '' };

    // Check if it's already in the new format
    if (typeof type === 'object' && ('en' in type || 'ar' in type)) {
      return type;
    }

    // Convert old format (string) to new format
    return {
      en: typeof type === 'string' ? type : '',
      ar: '',
    };
  };

  const addPlanForm = useForm({
    defaultValues: {
      type: convertType(oldData?.type),
      color: oldData?.color || '',
      icon: { label: '', value: oldData?.icon?._id },
      description: convertDescriptions(oldData?.description),
      price: oldData?.price || 0,
      duration: oldData?.duration || 0,
      durationUnit: oldData?.durationUnit || 'month',
      usageCount: oldData?.usageCount || 0,
      pointsToPay: oldData?.pointsToPay || 0,
      washingServices:
        oldData?.washingServices?.map((e) => ({
          label: e?.name[lang] || e?.name,
          value: e?._id,
        })) || [],
      selectAll: false,
      cities:
        oldData?.cities?.map((e) => ({ label: e?.city?.name[lang], value: e?.city?._id })) ||
        [] ||
        [],
    },
  });
  console.log(addPlanForm.getValues());
  const handelOnSubmit = (values) => {
    setIsLoading(true);

    const destructedCites = values.cities.map((city) => city.value);
    const destructedServices = values.washingServices.map((service) => service.value);

    const payload = {
      ...values,
      washingServices: destructedServices,
      cities: destructedCites,
      icon: values.icon.value,
    };

    const api = oldData
      ? plansService.editPlan(oldData?._id, payload)
      : plansService.createPlan(payload);

    api
      .then(() => {
        mutate((key: string) => key.includes('get-all-plans-details'));
        mutate((key: string) => key.includes('get-all-plans-list'));
        toast.success('Plan Edited Successfully');
        setIsLoading(false);
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

  const viewPlansFormFields = oldData
    ? plansService.editPlansFormFields
    : plansService.addPlansFormFields;

  return (
    <div className="h-screen overflow-y-scroll pb-36 scrollbar-hide">
      {loadingCitiesOptions && loadingwashingServicesIoncsOptions && loadingiconsOptions && (
        <ThreeDotsLoader />
      )}
      <Form {...addPlanForm}>
        <form
          onSubmit={addPlanForm.handleSubmit(handelOnSubmit)}
          className="flex flex-col gap-4 py-5 ">
          {viewPlansFormFields.map((plansFormField) => (
            <FormField
              key={plansFormField.name}
              control={addPlanForm.control}
              name={plansFormField.name as any}
              render={({ field }) => (
                <FormItem>
                  <FormControl>
                    {(() => {
                      switch (plansFormField.type) {
                        case EFormFieldType.COLOR_PICKER:
                          return (
                            <MainColorInput
                              label={plansFormField.title}
                              placeholder={plansFormField.placeholder}
                              field={{ ...field }}
                            />
                          );
                        case EFormFieldType.NUMBER:
                          return (
                            <MainInput
                              label={plansFormField.title}
                              placeholder={plansFormField.placeholder}
                              type="number"
                              field={{ ...field }}
                            />
                          );
                        case EFormFieldType.MULTI_SELECT:
                          return (
                            <MainSelect
                              title={plansFormField.title}
                              placeholder={plansFormField.placeholder}
                              multiSelect
                              options={
                                plansFormField.name === 'cities'
                                  ? citiesOptions
                                  : washingServicesIoncsOptions.map((option) => ({
                                      ...option,
                                      label: (
                                        <div className="flex items-center gap-2">
                                          {lang === 'en' ? option.label.en : option.label.ar}
                                        </div>
                                      ),
                                    }))
                              }
                              field={{ ...field }}
                            />
                          );
                        case EFormFieldType.DESCRIPTIONS:
                          return (
                            <MultiLangDescriptionListInputs
                              label={plansFormField.title}
                              placeholderEn={`${plansFormField.placeholder} (English)`}
                              placeholderAr={`${plansFormField.placeholder} (اللغة العربية)`}
                              field={{ ...field }}
                            />
                          );
                        case EFormFieldType.SELECT:
                          return (
                            <MainSelect
                              title={plansFormField.title}
                              placeholder={plansFormField.placeholder}
                              options={iconsOptions}
                              field={{ ...field }}
                            />
                          );
                        default:
                          return plansFormField.name === 'type' ? (
                            <MainMultiLangInput
                              label={plansFormField.title}
                              placeholderEn={`${plansFormField.placeholder} (English)`}
                              placeholderAr={`${plansFormField.placeholder} (اللغة العربية)`}
                              field={{ ...field }}
                            />
                          ) : (
                            <MainInput
                              label={plansFormField.title}
                              placeholder={plansFormField.placeholder}
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
};

export default PlansModelForm;
