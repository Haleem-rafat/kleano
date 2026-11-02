import { yupResolver } from '@hookform/resolvers/yup';
import { useAppDispatch } from '@hooks';
import authService from '@services/auth.service';
import { Form, FormControl, FormField, FormItem } from '@shadecn/components/ui/form';
import { loginAction } from '@store/slices/auth.slice';
import { Button, MainInput } from '@UI/Index';
import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';
import { useNavigate } from 'react-router-dom';
import { toast } from 'react-toastify';
import { ROUTES } from '@constants/routes';
import { t } from 'i18next';
import AuthLayout from './_Components/AuthLayout';

export default function Login() {
  const [isloading, setIsLoading] = useState(false);

  const dispatch = useAppDispatch();

  const navigate = useNavigate();

  const { i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';

  const form = useForm({ resolver: yupResolver(authService.loginSchema) });

  const handelOnSubmit = (values) => {
    setIsLoading(true);

    authService
      .login(values)
      .then((data) => {
        dispatch(loginAction(data));
        toast.success(` "Welcome back, ${data.userName}." `);
        navigate(ROUTES.DASH_BOARD);
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
    <AuthLayout>
      <div className="w-full max-w-sm rounded-2xl border border-border bg-card p-6 shadow-sm">
        <div>
          <Form {...form}>
            <form onSubmit={form.handleSubmit(handelOnSubmit)} className="flex flex-col gap-4 py-5">
              {authService.loginFormFields.map((loginFormField) => (
                <FormField
                  key={loginFormField.name}
                  control={form.control}
                  name={loginFormField.name as 'userName' | 'password'}
                  render={({ field }) => (
                    <FormItem>
                      <FormControl>
                        <MainInput
                          label={loginFormField?.title}
                          placeholder={loginFormField?.placeholder}
                          type={loginFormField?.type}
                          field={{ ...field }}
                        />
                      </FormControl>
                    </FormItem>
                  )}
                />
              ))}
              <Button type="submit" size="md" className="mt-3 w-full" loading={isloading}>
                {t('Log in')}
              </Button>
            </form>
          </Form>
        </div>
        <div className="flex items-center justify-center">
          <span className="w-full text-center text-sm text-muted-foreground">v1.3.0</span>
        </div>
      </div>
    </AuthLayout>
  );
}
