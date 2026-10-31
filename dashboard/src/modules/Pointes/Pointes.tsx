import pointesService from '@services/pointes.service';
import { IPoint } from '@servicesTypes/point.types';
import { Form, FormControl, FormField, FormItem } from '@shadecn/components/ui/form';
import { Button, MainInput, ThreeDotsLoader } from '@UI/Index';
import { useState, useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';
import { toast } from 'react-toastify';
import useSWR, { mutate } from 'swr';

export default function Pointes() {
  const { t, i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';

  const [isloading, setIsLoading] = useState(false);

  // Fetching data with SWR
  const { data, isLoading } = useSWR(['get-all-points'], () =>
    pointesService.getAllpoints().then((data) => data.data as IPoint)
  );

  const form = useForm({});

  useEffect(() => {
    form.setValue('totalPayPercentage', data?.totalPayPercentage);
    form.setValue('exchangePercentage', data?.exchangePercentage);
    form.setValue('redeemLimit', data?.redeemLimit);
  }, [data]);

  const handleOnSubmit = (values) => {
    setIsLoading(true);
    pointesService
      .updatePoints(values)
      .then(() => {
        mutate((key: string) => key.includes('get-all-points'));
        toast.success(t('pointsUpdatedSuccessfully'));
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
    <div className="relative flex h-full w-full flex-col gap-3 rounded-lg  p-4  shadow">
      {isLoading && <ThreeDotsLoader />}

      <div className="flex items-center justify-between pb-6">
        <p className="text-xl font-semibold capitalize tracking-tight text-slate-900">{t('pointes')}</p>
      </div>

      {/* Form Section */}
      <Form {...form}>
        <form onSubmit={form.handleSubmit(handleOnSubmit)} className="flex flex-col gap-4 py-5">
          {pointesService.pointsFormFields.map((formField) => (
            <FormField
              key={formField?.name}
              control={form?.control}
              name={formField?.name as 'totalPayPercentage' | 'exchangePercentage' | 'redeemLimit'}
              render={({ field }) => (
                <FormItem>
                  <FormControl>
                    <MainInput
                      label={formField.title}
                      placeholder={formField.placeholder}
                      field={{ ...field }}
                      type="number"
                    />
                  </FormControl>
                </FormItem>
              )}
            />
          ))}

          <div className=" bottom-0 left-0 w-full border-t-2 bg-white ">
            <Button type="submit" size="md" className="mt-3 w-full" loading={isloading}>
              {t('applyEdit')}
            </Button>
          </div>
        </form>
      </Form>
    </div>
  );
}
