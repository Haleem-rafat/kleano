import React from 'react';
import { Button, MainSelect } from '@UI/Index';
import { Form, FormControl, FormField, FormItem } from '@shadecn/components/ui/form';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';

export default function AddCityForm({ citiesOptions, onSubmit, isLoading }) {
  const { t } = useTranslation();
  const form = useForm({});

  return (
    <Form {...form}>
      <form
        onSubmit={form.handleSubmit(onSubmit)}
        className="flex items-end justify-between gap-4 rounded-md px-2 py-5 shadow-md">
        <FormField
          name="city"
          control={form.control}
          render={({ field }) => (
            <FormItem>
              <FormControl>
                <MainSelect
                  title={t('city')}
                  placeholder={t('city')}
                  options={citiesOptions}
                  field={{ ...field }}
                />
              </FormControl>
            </FormItem>
          )}
        />
        {/* we need to disable the button if the city is already added or if there is no selected city */}
        <Button
          type="submit"
          loading={isLoading}
          size="sm"
          disabled={!form.watch('city')}
          className={'disabled:bg-gray-300 disabled:text-gray-500'}>
          {form.watch('city') ? t('addCity') : t('selectCity')}
        </Button>
      </form>
    </Form>
  );
}
