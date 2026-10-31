import { EFormFieldType } from '@constants/enums';
import promoCodeService from '@services/promoCode.service';
import { Form, FormControl, FormField, FormItem } from '@shadecn/components/ui/form';
import { Button, MainInput, MainSelect, ThreeDotsLoader } from '@UI/Index';
import { Dispatch, SetStateAction, useEffect, useState } from 'react';
import { useForm } from 'react-hook-form';
import { useTranslation } from 'react-i18next';
import { mutate } from 'swr';
import { toast } from 'react-toastify';
import { t } from 'i18next';
import { yupResolver } from '@hookform/resolvers/yup';
import { Switch } from '@shadecn/components/ui/switch';
import useGetSegmentsOptions from '@/hooks/useGetSegmentsOptions';

interface IPromoCodeModelFormProps {
  setOpenSheet: Dispatch<SetStateAction<boolean>>;
}

export default function PromoCodeModelForm({ setOpenSheet }: IPromoCodeModelFormProps) {
  const [isloading, setIsLoading] = useState(false);

  const form = useForm({
    resolver: yupResolver(promoCodeService.addPromoCodeSchema),
  });
  const selectedPromoType = form.watch('SelectTypeOfPromo');
  const isPercentage = form.watch('isPercentage');
  const usesType = form.watch('usesType');
  const durationName = form.watch('durationName');
  const durationNumber = form.watch('durationNumber');

  // const {
  //   formState: { errors: formErrors },
  // } = form;

  const { segmentsOptions, loadingSegmentsOptions } = useGetSegmentsOptions(
    selectedPromoType?.value === 'segment'
  );

  const { i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';

  const getFormFields = () => {
    let fields = [...promoCodeService.commanPromoCodeFormFields];
    if (selectedPromoType?.value === 'allUsers') {
      fields = fields.concat(promoCodeService.alluserPromoCodeFormFields);
    } else if (selectedPromoType?.value === 'segment') {
      fields = fields.concat(promoCodeService.segmentPromoCodeFormFields);
    } else if (selectedPromoType?.value === 'newComers') {
      fields = fields.concat(promoCodeService.newComersPromoCodeFormFields);
    } else if (selectedPromoType?.value === 'aggregator') {
      fields = fields.concat(promoCodeService.aggregatorPromoCodeFormFields);
    } else if (selectedPromoType?.value === 'b2b') {
      fields = fields.concat(promoCodeService.b2bPromoCodeFormFields);
    }
    // Modify the duration field to be disabled when selectedPromoType is 'newComers'
    return fields.map((field) =>
      field.name === 'duration'
        ? { ...field, disabled: selectedPromoType?.value === 'newComers' }
        : field
    );
  };

  const handelOnSubmit = (values) => {
    setIsLoading(true);
    const body = {
      code: values.code,
      userLimits: usesType.value === 'PER_CODE' ? values.userLimits : undefined,
      usesType: values.usesType.value,
      discountPercentage: +values.discountPercentage || undefined,
      discountFixedNumber: +values.discountFixedNumber || undefined,
      numberOfUses: +values.numberOfUses,
      duration: selectedPromoType?.value === 'offline' ? undefined : +values.duration,
      segment: selectedPromoType?.value === 'segment' ? values.segment?.value : undefined,
      validWithin:
        selectedPromoType?.value === 'newComers'
          ? {
              durationName: values.durationName?.value,
              durationNumber: +values.durationNumber,
            }
          : undefined,
      expressionLeftSide:
        selectedPromoType?.value === 'aggregator' ? values.expressionLeftSide?.value : undefined,
      operator: selectedPromoType?.value === 'aggregator' ? values.operator?.value : undefined,
      expressionRightSide:
        selectedPromoType?.value === 'aggregator' ? +values.expressionRightSide : undefined,
      business: selectedPromoType?.value === 'b2b' ? values.business : undefined,
      quantity: selectedPromoType?.value === 'b2b' ? +values.quantity : undefined,
    };

    const endPoint =
      selectedPromoType?.value === 'allUsers'
        ? promoCodeService.addPromoCodeAllUser(body)
        : selectedPromoType?.value === 'segment'
        ? promoCodeService.addPromoCodeAllsegment(body)
        : selectedPromoType?.value === 'newComers'
        ? promoCodeService.addPromoCodeAllNewComers(body)
        : selectedPromoType?.value === 'offline'
        ? promoCodeService.addPromoCodeOffline(body)
        : selectedPromoType?.value === 'b2b'
        ? promoCodeService.addPromoCodeB2B(body)
        : promoCodeService.addPromoCodeAggregator(body);

    endPoint
      .then(() => {
        mutate((key: string) => key.includes('get-all-promo-codes'));
        toast.success(t('promoCreated'));
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

  useEffect(() => {
    if (isPercentage) {
      form.resetField('discountFixedNumber'); // Reset discountFixedNumber if switching to percentage
    } else {
      form.resetField('discountPercentage'); // Reset discountPercentage if switching to fixed number
    }
  }, [isPercentage, form.resetField]);

  // Effect to calculate Duration By Day automatically
  useEffect(() => {
    if (selectedPromoType?.value === 'newComers') {
      let calculatedDuration = 0;

      if (durationName?.value === 'day') {
        calculatedDuration = durationNumber || 0;
      } else if (durationName?.value === 'week') {
        calculatedDuration = (durationNumber || 0) * 7;
      } else if (durationName?.value === 'month') {
        calculatedDuration = (durationNumber || 0) * 30;
      } else if (durationName?.value === 'year') {
        calculatedDuration = (durationNumber || 0) * 365;
      }

      form.setValue('duration', calculatedDuration);
    }
  }, [durationName, durationNumber, selectedPromoType, form]);

  return (
    <div className="h-screen overflow-y-scroll pb-36 scrollbar-hide">
      {loadingSegmentsOptions && <ThreeDotsLoader />}
      <Form {...form}>
        <form onSubmit={form.handleSubmit(handelOnSubmit)} className="flex flex-col gap-4 py-5">
          {getFormFields().map((formField) => {
            // Conditionally render discount fields
            if (
              (formField.name === 'discountPercentage' && !isPercentage) ||
              (formField.name === 'discountFixedNumber' && isPercentage)
            ) {
              return null; // Skip rendering if the field is not active
            }

            return (
              <FormField
                key={formField?.name}
                control={form?.control}
                name={
                  formField?.name as
                    | 'SelectTypeOfPromo'
                    | 'code'
                    | 'discountPercentage'
                    | 'discountFixedNumber'
                    | 'duration'
                    | 'numberOfUses'
                    | 'segment'
                    | 'durationName'
                    | 'durationNumber'
                    | 'expressionLeftSide'
                    | 'operator'
                    | 'expressionRightSide'
                    | 'business'
                    | 'quantity'
                    | 'SelectTypeOfPromo.label'
                    | 'SelectTypeOfPromo.value'
                }
                render={({ field }) => (
                  <FormItem>
                    <FormControl>
                      {(() => {
                        switch (formField.type) {
                          case EFormFieldType.NUMBER:
                            return (
                              <MainInput
                                label={formField.title}
                                placeholder={formField.placeholder}
                                type="number"
                                min={+formField.min}
                                max={+formField.max}
                                field={{ ...field }}
                                disabled={formField.disabled}
                              />
                            );
                          case EFormFieldType.SELECT:
                            return (
                              <MainSelect
                                title={formField.title}
                                placeholder={formField.placeholder}
                                options={formField.options || segmentsOptions}
                                field={{ ...field }}
                              />
                            );
                          case EFormFieldType.RADIO:
                            return (
                              <div className="mb-4 flex items-center justify-between">
                                <span>{formField.title}</span>
                                <Switch checked={isPercentage} onCheckedChange={field.onChange} />
                              </div>
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
            );
          })}
          {usesType && usesType.value === 'PER_CODE' && (
            <FormField
              control={form?.control}
              name={'userLimits'}
              render={({ field }) => (
                <FormItem>
                  <FormControl>
                    <MainInput
                      label={'Number of uses per code'}
                      placeholder={'Number of uses per code'}
                      type="number"
                      field={{ ...field }}
                    />
                  </FormControl>
                </FormItem>
              )}
            />
          )}
          <div className="absolute bottom-0 left-0 w-full border-t-2 bg-white p-4">
            <Button type="submit" size="md" className="mt-3 w-full" loading={isloading}>
              {t('add')}
            </Button>
          </div>
        </form>
      </Form>
    </div>
  );
}
