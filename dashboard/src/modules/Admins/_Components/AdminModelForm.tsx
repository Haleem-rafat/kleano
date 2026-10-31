import { Form, FormControl, FormField, FormItem } from '@shadecn/components/ui/form';
import React, { SetStateAction, useState } from 'react';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';
import { mutate } from 'swr';
import { PhoneInput } from 'react-international-phone';
import { Button, MainInput, MainPhoneNumberInpute, MainSelect, ThreeDotsLoader } from '@UI/Index';
import i18n from '@app/locales/i18n';
import { EFormFieldType } from '@constants/enums';
import adminsService from '@services/admins.service';
import { toast } from 'react-toastify';
import useGetCitiesOptions from '@/hooks/useGetCitiesOptions';

interface IAdminModelFormProps {
  oldData?: any;
  setOpenSheet: React.Dispatch<SetStateAction<boolean>>;
}
const AdminModelForm = ({ oldData, setOpenSheet }: IAdminModelFormProps) => {
  const [isloading, setIsLoading] = useState(false);
  const [phone, setPhone] = useState('');

  const { citiesOptions, loadingCitiesOptions } = useGetCitiesOptions();

  const { t } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';

  const adminForm = useForm({
    defaultValues: {
      userName: oldData?.userName || '',
      password: oldData?.password || '',
      phone: oldData?.phone || '',
      nationalId: oldData?.nationalId || '',
      city: oldData?.city?.map((e) => ({ label: e?.name[lang], value: e?._id })) || [],
    },
  });

  const handelOnSubmit = (values) => {
    setIsLoading(true);
    const payload = {
      ...values,
      city: values.city.map((city) => city.value),
    };
    const api = oldData
      ? adminsService.editAdmin(oldData?._id, payload)
      : adminsService.createAdmin(payload);

    api
      .then(() => {
        mutate((key: string) => key.includes('get-all-admins-details'));
        mutate((key: string) => key.includes('get-all-admins-list'));
        toast.success(t('The admin has been successfully created'));
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

  const formFields = oldData ? adminsService.baseAdminFormFields : adminsService.adminFormFields;

  return (
    <div className="h-screen overflow-y-scroll pb-36 scrollbar-hide">
      {loadingCitiesOptions && <ThreeDotsLoader />}
      <Form {...adminForm}>
        <form
          onSubmit={adminForm.handleSubmit(handelOnSubmit)}
          className="flex flex-col gap-4 py-5 ">
          {formFields.map((adminFormField) => (
            <FormField
              key={adminFormField.name}
              control={adminForm.control}
              name={adminFormField.name as any}
              render={({ field }) => (
                <FormItem>
                  <FormControl>
                    {(() => {
                      switch (adminFormField.type) {
                        case EFormFieldType.MULTI_SELECT:
                          return (
                            <MainSelect
                              title={adminFormField.title}
                              placeholder={adminFormField.placeholder}
                              multiSelect
                              options={citiesOptions}
                              field={{ ...field }}
                            />
                          );
                        case EFormFieldType.PHONE_NUMBER:
                          return (
                            <MainPhoneNumberInpute
                              label="Phone number"
                              placeholder="Phone number"
                              field={{ ...field }}
                            />
                          );
                        case EFormFieldType.PASSWORD:
                          return !oldData ? (
                            <MainInput
                              label={adminFormField?.title}
                              placeholder={adminFormField?.placeholder}
                              type={adminFormField?.type}
                              field={{ ...field }}
                            />
                          ) : null;
                        default:
                          return (
                            <MainInput
                              label={adminFormField.title}
                              placeholder={adminFormField.placeholder}
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

export default AdminModelForm;
