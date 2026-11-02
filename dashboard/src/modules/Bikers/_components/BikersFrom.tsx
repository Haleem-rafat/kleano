import { Dispatch, SetStateAction, useState } from 'react';
import {
  Button,
  ImgUpload,
  MainInput,
  MainPhoneNumberInpute,
  MainSelect,
  SheetActions,
} from '@UI/Index';
import { Form, FormControl, FormField, FormItem } from '@shadecn/components/ui/form';
import { useForm } from 'react-hook-form';
import { yupResolver } from '@hookform/resolvers/yup';
import bikersService from '@services/bikers.service';
import { EFormFieldType } from '@constants/enums';
import { useTranslation } from 'react-i18next';
import { mutate } from 'swr';
import { toast } from 'react-toastify';
import { IBikers } from '@servicesTypes/bikers.types';
//import { FaMapMarkerAlt } from "react-icons/fa";
//import MapModal from "./MapModal";

interface IBikersFromProps {
  setOpenSheet: Dispatch<SetStateAction<boolean>>;
  oldData?: IBikers;
}

export default function BikersFrom({ setOpenSheet, oldData }: IBikersFromProps) {
  const [isloading, setIsLoading] = useState(false);

  const { t, i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';

  const form = useForm({
    defaultValues: {
      image: oldData?.imageLink,
      userName: oldData?.userName,
      nationalId: oldData?.nationalId,
      phone: oldData?.phone,
      commissionType: (oldData as any)?.commissionType || 'PERCENTAGE',
      commission: (oldData as any)?.commission ?? (oldData ? 0 : ''),
      ordersBeforeCommission: (oldData as any)?.ordersBeforeCommission ?? 0,
      minimumCommission: (oldData as any)?.minimumCommission ?? (oldData ? 0 : ''),
      weekendCommission: (oldData as any)?.weekendCommission ?? (oldData ? 0 : ''),
    },
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    resolver: (yupResolver as any)(
      oldData ? bikersService.editBikerSchema : bikersService.addBikerSchema
    ),
  });

  const handelOnSubmit = (values) => {
    setIsLoading(true);
    const formData = new FormData();
    formData.append('image', values.image);
    formData.append('userName', values.userName);
    oldData ? undefined : formData.append('password', values.password);
    formData.append('nationalId', values.nationalId);
    formData.append('phone', values.phone);
    formData.append('commissionType', values.commissionType);
    formData.append('commission', String(values.commission || 0));
    formData.append('ordersBeforeCommission', String(values.ordersBeforeCommission || 0));
    formData.append('weekendCommission', String(values.weekendCommission || 0));
    if (values.minimumCommission) {
      formData.append('minimumCommission', String(values.minimumCommission));
    }

    const api = oldData
      ? bikersService.editBiker(oldData?._id, formData)
      : bikersService.createBiker(formData);

    api
      .then(() => {
        toast.success(oldData ? 'Biker updated successfully!' : 'Biker created successfully!');
        mutate((key: string) => key.includes('get-all-bikers-list'));
        mutate((key: string) => key.includes('get-biker-details'));
        setOpenSheet(false);
      })
      .catch(({ response }) => {
        const messages = response?.data?.message;
        const errList = Array.isArray(messages)
          ? messages.join(', ')
          : messages?.[lang] || t('An error occurred');
        toast.error(errList);
      })
      .finally(() => {
        setIsLoading(false);
      });
  };

  const formFields = oldData
    ? bikersService?.editBikerFormFields
    : bikersService.addBikerFormFields;

  return (
    <div>
      <Form {...form}>
        <form onSubmit={form.handleSubmit(handelOnSubmit)} className="flex flex-col gap-4 ">
          {formFields.map((formField) => (
            <FormField
              key={formField?.name}
              control={form?.control}
              name={
                formField?.name as
                  | 'image'
                  | 'userName'
                  | 'nationalId'
                  | 'phone'
                  | 'commissionType'
                  | 'commission'
                  | 'ordersBeforeCommission'
                  | 'minimumCommission'
              }
              render={({ field }) => (
                <FormItem>
                  <FormControl>
                    {(() => {
                      switch (formField.type) {
                        case EFormFieldType.IMG_UPLOAD:
                          return (
                            <ImgUpload
                              title={formField.title}
                              textButton={t('uploadBikerImage')}
                              field={{ ...field }}
                            />
                          );

                        case EFormFieldType.PHONE_NUMBER:
                          return (
                            <MainPhoneNumberInpute
                              label={t('phone')}
                              placeholder={t('phone')}
                              field={{ ...field }}
                            />
                          );

                        case EFormFieldType.SELECT:
                          return (
                            <MainSelect
                              title={formField.title}
                              placeholder={formField.placeholder}
                              options={formField.options || []}
                              field={
                                {
                                  ...field,
                                  onChange: (value: { label: string; value: string } | null) => {
                                    field.onChange(value?.value || '');
                                  },
                                  value: field.value
                                    ? {
                                        label:
                                          formField.options?.find(
                                            (opt) => opt.value === field.value
                                          )?.label || String(field.value),
                                        value: String(field.value),
                                      }
                                    : { label: '', value: '' },
                                } as any
                              }
                            />
                          );

                        case EFormFieldType.NUMBER:
                          return (
                            <MainInput
                              label={formField.title}
                              placeholder={formField.placeholder}
                              field={{
                                ...field,
                                value: field.value ?? '',
                                onChange: (value: string) => {
                                  // MainInput passes the string value from e.target.value
                                  // Convert to number if valid, otherwise keep as empty string
                                  if (value === '' || value === null || value === undefined) {
                                    field.onChange('');
                                  } else {
                                    const numValue = Number(value);
                                    field.onChange(isNaN(numValue) ? '' : numValue);
                                  }
                                },
                              }}
                              type="number"
                            />
                          );

                        default:
                          return (
                            <MainInput
                              label={formField.title}
                              placeholder={formField.placeholder}
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
