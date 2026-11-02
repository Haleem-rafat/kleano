import { IAddOns } from '@servicesTypes/addOns';
import React, { SetStateAction, useState } from 'react';
import { useForm } from 'react-hook-form';
import { Form, FormControl, FormField, FormItem } from '@shadecn/components/ui/form';
import {
  Button,
  MainInput,
  MainSelect,
  MianDescriptionListInputs,
  MainMultiLangInput,
  SheetActions,
  FormSkeleton,
} from '@UI/Index';
import { EFormFieldType } from '@constants/enums';
import addOnsService from '@services/addOns.service';
import { t } from 'i18next';
import { useTranslation } from 'react-i18next';
import { mutate } from 'swr';
import { toast } from 'react-toastify';
import { yupResolver } from '@hookform/resolvers/yup';
import useGetIconsOptions from '@/hooks/useGetIconsOptions';
import useGetCitiesOptions from '@/hooks/useGetCitiesOptions';

interface IAddOnsFormProps {
  setOpenSheet: React.Dispatch<SetStateAction<boolean>>;
  oldData?: IAddOns;
}
export default function AddOnsForm({ setOpenSheet, oldData }: IAddOnsFormProps) {
  const [isloading, setIsLoading] = useState(false);

  const { citiesOptions, loadingCitiesOptions } = useGetCitiesOptions();
  const { iconsOptions, loadingiconsOptions } = useGetIconsOptions();

  const { i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';
  const form = useForm({
    resolver: yupResolver(
      oldData ? addOnsService.editAddOnsSchemas : addOnsService.addAddOnsSchemas
    ),
    defaultValues: {
      name: typeof oldData?.name === 'object' ? oldData.name : { en: '', ar: '' },
      price: oldData?.price ?? undefined,
      icon: { label: '', value: oldData?.icon?._id },
      stock: oldData?.stock,
    },
  });

  const handelOnSubmit = (values) => {
    setIsLoading(true);
    const body = {
      name: values?.name,
      price: +values?.price,
      icon: values.icon.value,
      stock: +values?.stock,
      cities: values?.cities?.map((city) => city?.value),
      selectAll: false,
    };

    const api = oldData
      ? addOnsService.editAddOns(oldData?._id, body)
      : addOnsService.creatAddOns(body);

    api
      .then(() => {
        mutate((key: string) => key.includes('get-all-add-ons-list'));
        mutate((key: string) => key.includes('get-all-add-ons-details'));
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
    ? addOnsService.editAddOnsFormFields
    : addOnsService.addAddOnsFormFields;

  return (
    <div>
      {(loadingCitiesOptions || loadingiconsOptions) && <FormSkeleton />}
      <Form {...form}>
        <form
          onSubmit={form.handleSubmit(handelOnSubmit)}
          className={`flex flex-col gap-4 ${
            loadingCitiesOptions || loadingiconsOptions ? 'hidden' : ''
          }`}>
          {viewPlansFormFields.map((plansFormField) => (
            <FormField
              key={plansFormField.name}
              control={form.control}
              name={plansFormField.name as 'name' | 'price' | 'icon' | 'stock'}
              render={({ field }) => (
                <FormItem>
                  <FormControl>
                    {(() => {
                      switch (plansFormField.type) {
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
                              options={citiesOptions}
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
                        case EFormFieldType.DESCRIPTIONS:
                          return (
                            <MianDescriptionListInputs
                              label={plansFormField.title}
                              placeholder={plansFormField.placeholder}
                              field={{ ...field }}
                            />
                          );
                        default:
                          return plansFormField.name === 'name' ? (
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
          <SheetActions>
            <Button type="submit" size="md" className="mt-3 w-full" loading={isloading}>
              {oldData ? t('applyEdit') : t('add')}
            </Button>
          </SheetActions>
        </form>
      </Form>
    </div>
  );
}
