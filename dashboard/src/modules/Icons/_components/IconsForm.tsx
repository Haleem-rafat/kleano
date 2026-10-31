import iconsService from '@services/icons.service';
import { Form, FormControl, FormField, FormItem } from '@shadecn/components/ui/form';
import { Button, ImgUpload } from '@UI/Index';
import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';
import { toast } from 'react-toastify';
import { mutate } from 'swr';

export default function IconsForm({ setOpenSheet }) {
  const [isLoading, setIsLoading] = useState(false);

  const { t, i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';

  const form = useForm();

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
    <div className="h-screen overflow-y-scroll pb-36 scrollbar-hide">
      <Form {...form}>
        <form onSubmit={form.handleSubmit(handleOnSubmit)} className="flex flex-col gap-4 py-5">
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
          <div className="absolute bottom-0 left-0 w-full border-t-2 bg-white p-4">
            <Button type="submit" className="mt-3 w-full" loading={isLoading}>
              {t('add')}
            </Button>
          </div>
        </form>
      </Form>
    </div>
  );
}
