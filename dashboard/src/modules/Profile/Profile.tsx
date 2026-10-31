import settingsService from '@services/settings.service';
import { Button, ThreeDotsLoader } from '@UI/Index';
import { toast } from 'react-toastify';
import useSWR from 'swr';
import { Input } from '@shadecn/components/ui/input';
import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { yupResolver } from '@hookform/resolvers/yup';
import * as yup from 'yup';
import { useTranslation } from 'react-i18next';
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@shadecn/components/ui/form';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/shadecn/components/ui/dialog';
const Profile = () => {
  const [open, setOpen] = useState(false);
  const [loading, setLoading] = useState(false);
  const { i18n, t } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';
  const fetchProfile = async () => {
    return await settingsService
      .getProfile()
      .then((data) => {
        return data.data;
      })
      .catch((e) => {
        toast.error(e.response.localizedMessage['en']);
      });
  };
  const { data, isLoading } = useSWR('get-amin-profile', fetchProfile);

  const newPasswrodForm = useForm({
    defaultValues: {
      password: '',
    },
    resolver: yupResolver(
      yup.object({
        password: yup
          .string()
          .required('Required')
          .min(8, 'Password must be at least 8 characters'),
      })
    ),
  });
  const onEditPassword = async (data) => {
    setLoading(true);
    await settingsService
      .resetMpassword(data)
      .then(() => {
        setLoading(false);
        setOpen(false);
        toast.success('Password updated successfully');
      })
      .catch((e) => {
        setLoading(false);

        toast.error(e.response.localizedMessage['en']);
      });
  };
  if (isLoading) return <ThreeDotsLoader />;
  return (
    <div>
      <div className="w-full rounded-xl border border-slate-200 bg-white p-6">
        <div className="flex w-full justify-between">
          <h1 className="mb-4 text-2xl font-bold text-gray-700">{t('User Profile')}</h1>
          <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild>
              <Button>{t('Reset password')}</Button>
            </DialogTrigger>
            <DialogContent className="sm:max-w-[425px]">
              <DialogHeader>
                <DialogTitle>{t('Reset password')}</DialogTitle>
                <DialogDescription>
                  Make changes to your Password here. Click save when you&lsquo;re done.
                </DialogDescription>
              </DialogHeader>

              <div className=" w-full">
                <Form {...newPasswrodForm}>
                  <form
                    className="flex w-full flex-col gap-3"
                    onSubmit={newPasswrodForm.handleSubmit(onEditPassword)}>
                    <FormField
                      control={newPasswrodForm.control}
                      name="password"
                      render={({ field }) => (
                        <FormItem>
                          <FormLabel />
                          <FormControl>
                            <Input type="password" {...field} />
                          </FormControl>

                          <FormMessage />
                        </FormItem>
                      )}
                    />{' '}
                    <Button disabled={loading} loading={loading} type="submit" className="w-full">
                      {t('Save changes')}
                    </Button>
                  </form>
                </Form>
              </div>
            </DialogContent>
          </Dialog>
        </div>
        <div className="mb-4">
          <h2 className="text-sm font-medium text-gray-500">{t('User Name')}</h2>
          <p className="text-lg font-semibold text-gray-800">{data?.userName}</p>
        </div>

        <div className="mb-4 grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <h2 className="text-sm font-medium text-gray-500">{t('Language')}</h2>
            <p className="text-sm font-medium text-slate-900">{data?.lang.toUpperCase()}</p>
          </div>
          <div>
            <h2 className="text-sm font-medium text-gray-500">{t('Status')}</h2>
            <p
              className={`text-lg font-semibold ${
                data?.status === 'ACTIVE' ? 'text-green-600' : 'text-red-600'
              }`}>
              {data?.status}
            </p>
          </div>
        </div>

        <div className="mb-4 grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <h2 className="text-sm font-medium text-gray-500">is SuperAdmin</h2>
            <p className="text-sm font-medium text-slate-900">{data?.isSuperAdmin ? 'Yes' : 'No'}</p>
          </div>
          <div>
            <h2 className="text-sm font-medium text-gray-500">{t('Is Deleted')}</h2>
            <p className="text-sm font-medium text-slate-900">{data?.isDeleted ? 'Yes' : 'No'}</p>
          </div>
        </div>

        <div className="mb-4">
          <h2 className="text-sm font-medium text-gray-500">{t('Suspend Reason')}</h2>
          <p className="text-sm font-medium text-slate-900">{data?.suspendReason || '—'}</p>
        </div>

        <div className="mb-4">
          <h2 className="text-sm font-medium text-gray-500">{t('City')}</h2>
          <p className="text-sm font-medium text-slate-900">
            {data?.city.length ? data?.city?.map((item) => item.name[lang]).join(', ') : '—'}
          </p>
        </div>

        <div className="mb-4">
          <h2 className="text-sm font-medium text-gray-500">{t('Created At')}</h2>
          <p className="text-sm font-medium text-slate-900">{new Date(data?.createdAt).toLocaleDateString()}</p>
        </div>

        <div>
          <h2 className="text-sm font-medium text-gray-500">{t('Last Updated')}</h2>
          <p className="text-sm font-medium text-slate-900">{new Date(data?.updatedAt).toLocaleDateString()}</p>
        </div>
      </div>
    </div>
  );
};

export default Profile;
