import { v } from '@app/utils/validation';
import { yupResolver } from '@hookform/resolvers/yup';
import * as Yup from 'yup';
import iconsService from '@services/icons.service';
import { Form, FormControl, FormField, FormItem } from '@shadecn/components/ui/form';
import { Button, ImgUpload, SheetActions } from '@UI/Index';
import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';
import { toast } from 'react-toastify';
import { mutate } from 'swr';

export default function IconsForm({ setOpenSheet }) {
  const [isLoading, setIsLoading] = useState(false);

  const { t, i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';

  const form = useForm({
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    resolver: yupResolver(Yup.object({ file: v.file() })) as any,
  });

  const handleOnSubmit = (values) => {
    setIsLoading(true);
    const formData = new FormData();
    formData.append('file', values.file);

    iconsService
      .addNewIcons(formData)
      .then(() => {
        mutate((key: string) => key.includes('get-icons'));
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
    <div>
      <Form {...form}>
        <form onSubmit={form.handleSubmit(handleOnSubmit)} className="flex flex-col gap-4">
          <FormField
            control={form.control}
            name="file"
            render={({ field }) => (
              <FormItem>
                <FormControl>
                  <ImgUpload title="Image" textButton={t('uploadImage')} field={{ ...field }} />
                </FormControl>
              </FormItem>
            )}
          />
          <SheetActions>
            <Button type="submit" className="mt-3 w-full" loading={isLoading}>
              {t('add')}
            </Button>
          </SheetActions>
        </form>
      </Form>
    </div>
  );
}
