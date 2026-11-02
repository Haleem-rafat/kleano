import { v } from '@app/utils/validation';
import { yupResolver } from '@hookform/resolvers/yup';
import * as Yup from 'yup';
import { Button, ImgUpload, MainInput, MainSelect, SheetActions } from '@UI/Index';
import React, { SetStateAction, useState, useEffect, useRef } from 'react';
import { Form, FormControl, FormField, FormItem, FormLabel } from '@shadecn/components/ui/form';
import { RadioGroup, RadioGroupItem } from '@shadecn/components/ui/radio-group';
import { Label } from '@shadecn/components/ui/label';

import { useForm } from 'react-hook-form';
import type { ControllerRenderProps, FieldValues } from 'react-hook-form';
import { useTranslation } from 'react-i18next';
import { EFormFieldType } from '@constants/enums';
import bannerService from '@services/banner.service';
import staticService from '@services/static.service';
import useSWR, { mutate } from 'swr';
import { toast } from 'react-toastify';
import i18next from 'i18next';

interface BannerFormProps {
  setOpen: React.Dispatch<SetStateAction<boolean>>;
  oldData?: {
    title?: string;
    description?: string;
    imageLink?: string;
    imageLinkAr?: string;
    externalUrl?: string;
    resourceId?: string;
    resource?: 'PROMO_CODE' | 'PLAN';
    _id?: string;
  };
}

const BannerForm = ({ setOpen, oldData }: BannerFormProps) => {
  const [isLoading, setIsLoading] = React.useState(false);
  const { t } = useTranslation();
  const lang = i18next.language as 'en' | 'ar';
  const [linkType, setLinkType] = useState<'external' | 'internal'>(
    oldData?.externalUrl ? 'external' : oldData?.resourceId ? 'internal' : 'external'
  );
  const [selectedResource, setSelectedResource] = useState<'PROMO_CODE' | 'PLAN' | ''>(
    oldData?.resource || ''
  );

  // Store original values to preserve them when switching link types
  const preservedInternalData = useRef<{
    resource: string;
    resourceId: { label: string; value: string };
  }>({
    resource: oldData?.resource || '',
    resourceId: oldData?.resourceId
      ? { label: '', value: oldData.resourceId }
      : { label: '', value: '' },
  });

  const preservedExternalData = useRef<{
    externalUrl: string;
  }>({
    externalUrl: oldData?.externalUrl || '',
  });

  const form = useForm({
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    resolver: yupResolver(
      Yup.object({
        title: v.text(80),
        description: v.optionalText(300),
        image: v.file(),
        imageAr: v.file(),
        linkType: v.choice(),
        externalUrl: Yup.string().when('linkType', {
          is: 'external',
          then: () => v.url(),
          otherwise: (sch) => sch.notRequired(),
        }),
        resource: Yup.string().when('linkType', {
          is: 'internal',
          then: () => v.choice(),
          otherwise: (sch) => sch.notRequired(),
        }),
        resourceId: Yup.mixed().when('linkType', {
          is: 'internal',
          then: () => v.picked(),
          otherwise: (sch) => sch.notRequired(),
        }),
      })
    ) as any,
    defaultValues: {
      title: oldData?.title || '',
      description: oldData?.description || '',
      image: oldData?.imageLink || '',
      imageAr: oldData?.imageLinkAr || '',
      linkType: oldData?.externalUrl ? 'external' : oldData?.resourceId ? 'internal' : 'external',
      externalUrl: oldData?.externalUrl || '',
      resource: oldData?.resource || '',
      resourceId: oldData?.resourceId
        ? { label: '', value: oldData.resourceId }
        : { label: '', value: '' },
    },
  });

  const { data: promoCodeData } = useSWR(
    selectedResource === 'PROMO_CODE' ? ['get-all-promo-codes-dropdown'] : null,
    () => staticService.getAllPromoCode()
  );

  const { data: plansData } = useSWR(
    selectedResource === 'PLAN' ? ['get-all-plans-dropdown'] : null,
    () => staticService.getAllPlans()
  );

  const [promoCodeOptions, setPromoCodeOptions] = useState<{ label: string; value: string }[]>([]);
  const [plansOptions, setPlansOptions] = useState<{ label: string; value: string }[]>([]);

  const linkTypeValue = form.watch('linkType');
  const resourceValue = form.watch('resource');
  const resourceIdValue = form.watch('resourceId');
  const externalUrlValue = form.watch('externalUrl');

  useEffect(() => {
    if (promoCodeData?.data) {
      const dataArray =
        promoCodeData.data?.dataList ||
        (Array.isArray(promoCodeData.data) ? promoCodeData.data : [promoCodeData.data]) ||
        [];
      const options = dataArray.map(
        (item: {
          code?: string | { en: string; ar: string };
          name?: string | { en: string; ar: string };
          _id: string;
          type?: string | { en: string; ar: string };
        }) => {
          const codeLabel = typeof item.code === 'object' ? item.code[lang] : item.code;
          const nameLabel = typeof item.name === 'object' ? item.name[lang] : item.name;
          const typeLabel = typeof item.type === 'object' ? item.type[lang] : item.type;
          return {
            label: codeLabel || nameLabel || typeLabel || item._id,
            value: item._id,
          };
        }
      );
      setPromoCodeOptions(options);
    }
  }, [promoCodeData, lang]);

  useEffect(() => {
    if (plansData?.data) {
      const dataArray = Array.isArray(plansData.data) ? plansData.data : [plansData.data];
      const options = dataArray.map(
        (item: {
          type?: string | { en: string; ar: string };
          name?: string | { en: string; ar: string };
          _id: string;
        }) => {
          const typeLabel = typeof item.type === 'object' ? item.type[lang] : item.type;
          const nameLabel = typeof item.name === 'object' ? item.name[lang] : item.name;
          return {
            label: typeLabel || nameLabel || item._id,
            value: item._id,
          };
        }
      );
      setPlansOptions(options);
    }
  }, [plansData, lang]);

  useEffect(() => {
    setLinkType((linkTypeValue as 'external' | 'internal') || 'external');
  }, [linkTypeValue]);

  useEffect(() => {
    setSelectedResource((resourceValue as 'PROMO_CODE' | 'PLAN') || '');
    if (!resourceValue) {
      form.setValue('resourceId', { label: '', value: '' });
      // Update preserved data when resource is cleared
      preservedInternalData.current.resource = '';
      preservedInternalData.current.resourceId = { label: '', value: '' };
    } else {
      // Update preserved data when resource changes
      preservedInternalData.current.resource = resourceValue;
    }
  }, [resourceValue, form]);

  // Update preserved data when resourceId changes
  useEffect(() => {
    if (resourceIdValue?.value) {
      preservedInternalData.current.resourceId = resourceIdValue;
    }
  }, [resourceIdValue]);

  // Update preserved data when externalUrl changes
  useEffect(() => {
    if (externalUrlValue) {
      preservedExternalData.current.externalUrl = externalUrlValue;
    }
  }, [externalUrlValue]);
  const handelOnSubmit = (values) => {
    setIsLoading(true);
    const formData = new FormData();
    formData.append('image', values.image);
    formData.append('imageAr', values.imageAr);
    formData.append('description', values.description);
    formData.append('title', values.title);

    if (values.linkType === 'external') {
      formData.append('externalUrl', values.externalUrl || '');
    } else if (values.linkType === 'internal') {
      if (values.resource) {
        formData.append('resource', values.resource);
      }
      if (values.resourceId?.value) {
        formData.append('resourceId', values.resourceId.value);
      }
    }

    const api = oldData
      ? bannerService.editBanner(oldData?._id, formData)
      : bannerService.createBanner(formData);

    api
      .then(() => {
        mutate((key: string) => key.includes('get-all-banners'));

        setOpen(false);
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
  const formFields = [
    {
      name: 'image',
      type: 'img_upload',
      placeholder: t('image'),
      label: t('image'),
      title: t('image'),
    },
    {
      name: 'imageAr',
      type: 'img_upload',
      placeholder: t('image (Arabic)'),
      label: t('image (Arabic)'),
      title: t('image (Arabic)'),
    },
    {
      name: 'title',
      type: 'text',
      placeholder: t('title'),
      label: t('title'),
      title: t('title'),
    },
    {
      name: 'description',
      type: 'text',
      placeholder: t('description'),
      label: t('description'),
      title: t('description'),
    },
  ];

  return (
    <div>
      <Form {...form}>
        <form onSubmit={form.handleSubmit(handelOnSubmit)} className="flex flex-col gap-4 ">
          {formFields.map((formField) => (
            <FormField
              key={formField?.name}
              control={form?.control}
              name={formField?.name as 'title' | 'description' | 'image' | 'imageAr'}
              render={({ field }) => (
                <FormItem>
                  <FormControl>
                    {(() => {
                      switch (formField.type) {
                        case EFormFieldType.IMG_UPLOAD:
                          return (
                            <ImgUpload
                              title={formField.title}
                              textButton={t('upload banner')}
                              field={{ ...field }}
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
          {!oldData ? (
            <FormField
              control={form.control}
              name="linkType"
              render={({ field }) => (
                <FormItem>
                  <FormLabel className="text-start text-sm font-semibold text-foreground">
                    {t('Link Type')}
                  </FormLabel>
                  <FormControl>
                    <RadioGroup
                      onValueChange={(value) => {
                        field.onChange(value);
                        setLinkType(value as 'external' | 'internal');
                        if (value === 'external') {
                          // Preserve internal data before switching
                          const currentResource = form.getValues('resource');
                          const currentResourceId = form.getValues('resourceId');
                          if (currentResource || currentResourceId?.value) {
                            preservedInternalData.current = {
                              resource: currentResource || preservedInternalData.current.resource,
                              resourceId: currentResourceId?.value
                                ? currentResourceId
                                : preservedInternalData.current.resourceId,
                            };
                          }
                          // Restore external data if it exists
                          if (preservedExternalData.current.externalUrl) {
                            form.setValue('externalUrl', preservedExternalData.current.externalUrl);
                          }
                        } else {
                          // Preserve external data before switching
                          const currentExternalUrl = form.getValues('externalUrl');
                          if (currentExternalUrl) {
                            preservedExternalData.current = {
                              externalUrl: currentExternalUrl,
                            };
                          }
                          // Restore internal data if it exists
                          if (preservedInternalData.current.resource) {
                            form.setValue('resource', preservedInternalData.current.resource);
                          }
                          if (preservedInternalData.current.resourceId?.value) {
                            form.setValue('resourceId', preservedInternalData.current.resourceId);
                          }
                        }
                      }}
                      value={field.value}
                      className="flex gap-6">
                      <div className="flex items-center space-x-2">
                        <RadioGroupItem value="external" id="external" />
                        <Label htmlFor="external" className="cursor-pointer">
                          {t('External Link')}
                        </Label>
                      </div>
                      <div className="flex items-center space-x-2">
                        <RadioGroupItem value="internal" id="internal" />
                        <Label htmlFor="internal" className="cursor-pointer">
                          {t('Internal Link')}
                        </Label>
                      </div>
                    </RadioGroup>
                  </FormControl>
                </FormItem>
              )}
            />
          ) : (
            <FormItem>
              <FormLabel className="text-start text-sm font-semibold text-foreground">
                {t('Link Type')}
              </FormLabel>
              <div className="text-sm text-foreground">
                {linkType === 'external' ? t('External Link') : t('Internal Link')}
              </div>
            </FormItem>
          )}

          {linkType === 'external' && (
            <FormField
              control={form.control}
              name="externalUrl"
              render={({ field }) => (
                <FormItem>
                  <FormControl>
                    <MainInput
                      label={t('External URL')}
                      placeholder={t('Enter external URL')}
                      field={{ ...field }}
                      type="url"
                    />
                  </FormControl>
                </FormItem>
              )}
            />
          )}

          {linkType === 'internal' && (
            <>
              <FormField
                control={form.control}
                name="resource"
                render={({ field }) => (
                  <FormItem>
                    <FormControl>
                      <MainSelect
                        title={t('Resource')}
                        placeholder={t('Select resource')}
                        options={[
                          { label: t('Promo Code'), value: 'PROMO_CODE' },
                          { label: t('Plan'), value: 'PLAN' },
                        ]}
                        field={{
                          ...field,
                          onChange: (value: { label: string; value: string } | null) => {
                            field.onChange(value?.value || '');
                            form.setValue('resourceId', { label: '', value: '' });
                          },
                          value: field.value
                            ? {
                                label: field.value === 'PROMO_CODE' ? t('Promo Code') : t('Plan'),
                                value: field.value,
                              }
                            : { label: '', value: '' },
                        }}
                      />
                    </FormControl>
                  </FormItem>
                )}
              />

              {selectedResource && (
                <FormField
                  control={form.control}
                  name="resourceId"
                  render={({ field }) => (
                    <FormItem>
                      <FormControl>
                        <MainSelect
                          title={selectedResource === 'PROMO_CODE' ? t('Promo Code') : t('Plan')}
                          placeholder={
                            selectedResource === 'PROMO_CODE'
                              ? t('Select promo code')
                              : t('Select plan')
                          }
                          options={
                            selectedResource === 'PROMO_CODE' ? promoCodeOptions : plansOptions
                          }
                          field={field as unknown as ControllerRenderProps<FieldValues, string>}
                        />
                      </FormControl>
                    </FormItem>
                  )}
                />
              )}
            </>
          )}
          <SheetActions>
            <Button type="submit" size="md" className="mt-3 w-full" loading={isLoading}>
              {oldData ? t('edit') : t('add')}
            </Button>
          </SheetActions>
        </form>
      </Form>
    </div>
  );
};

export default BannerForm;
