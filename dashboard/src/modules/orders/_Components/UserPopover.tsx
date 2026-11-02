import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useForm } from 'react-hook-form';
import { yupResolver } from '@hookform/resolvers/yup';
import * as Yup from 'yup';
import { mutate } from 'swr';
import { toast } from 'react-toastify';
import ordersService from '@services/orders.service';
import { Button } from '@UI/Index';
import { Input } from '@shadecn/components/ui/input';
import { Textarea } from '@shadecn/components/ui/textarea';
import { Label } from '@/shadecn/components/ui/label';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/shadecn/components/ui/dialog';

type CancelOrderForm = {
  totalAmount: number;
  cancellationReason: string;
};

interface ICancelOrderProps {
  orderId: string;
  /** What the customer paid; caps the refund and fills "Full refund". */
  paid?: number;
  /** Smaller trigger for table rows. */
  compact?: boolean;
}

/**
 * Cancel an order: a centred dialog (never clipped by table columns) with the
 * refund amount, a reason, and a clear confirm. Closes and refreshes on success.
 */
const CancelOrderDialog = ({ orderId, paid, compact = false }: ICancelOrderProps) => {
  const { t, i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';
  const [open, setOpen] = useState(false);
  const [saving, setSaving] = useState(false);
  const maxRefund = Number(paid) > 0 ? Number(paid) : undefined;

  const schema = Yup.object({
    totalAmount: Yup.number()
      .transform((v, o) => (o === '' || o === null ? undefined : v))
      .typeError('validation.number')
      .required('validation.required')
      .min(0, 'validation.min0')
      .test(
        'max',
        'refundTooHigh',
        (v) => maxRefund === undefined || v === undefined || v <= maxRefund
      ),
    cancellationReason: Yup.string()
      .trim()
      .required('validation.required')
      .max(300, 'validation.maxLength'),
  });

  const {
    register,
    handleSubmit,
    setValue,
    reset,
    formState: { errors },
  } = useForm<CancelOrderForm>({
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    resolver: yupResolver(schema) as any,
  });

  const stop = (e: React.MouseEvent) => e.stopPropagation();

  const onSubmit = (data: CancelOrderForm) => {
    setSaving(true);
    ordersService
      .cancelOrderByAdmin({
        totalAmount: data.totalAmount,
        order: orderId,
        cancellationReason: data.cancellationReason,
      })
      .then(() => {
        toast.success(t('Order canceled successfully'));
        setOpen(false);
        reset();
        mutate((key: unknown) => Array.isArray(key) && key.includes('get-all-order-list'));
        mutate((key: unknown) => Array.isArray(key) && key.includes('get-all-order-details'));
      })
      .catch(({ response }) => {
        const messages = response?.data?.message;
        const errList = Array.isArray(messages)
          ? messages.map((e, index) => <p key={index}>{e}</p>)
          : messages?.[lang] || t('somethingWentWrong');
        toast.error(<div>{errList}</div>);
      })
      .finally(() => setSaving(false));
  };

  const errorText = (msg?: string) =>
    msg && (
      <p role="alert" className="text-[13px] font-medium text-destructive">
        {t(msg, { max: maxRefund })}
      </p>
    );

  return (
    <div onClick={stop} className="contents">
      <Button
        variant="dangerOutline"
        size={compact ? 'sm' : 'md'}
        onClick={(e) => {
          stop(e);
          setOpen(true);
        }}>
        {t('cancel')}
      </Button>

      <Dialog
        open={open}
        onOpenChange={(v) => {
          if (saving) return;
          setOpen(v);
          if (!v) reset();
        }}>
        <DialogContent className="sm:max-w-md" onClick={stop}>
          <DialogHeader>
            <DialogTitle>{t('cancelOrderTitle', { id: orderId.slice(-6) })}</DialogTitle>
            <DialogDescription>
              {maxRefund !== undefined
                ? t('cancelOrderPaid', { amount: maxRefund })
                : t('cancelOrderHint')}
            </DialogDescription>
          </DialogHeader>

          <form id={`cancel-${orderId}`} onSubmit={handleSubmit(onSubmit)} className="space-y-4">
            <div className="space-y-2">
              <div className="flex items-center justify-between gap-2">
                <Label htmlFor={`refund-${orderId}`}>{t('refundAmount')}</Label>
                <div className="flex gap-1">
                  <button
                    type="button"
                    onClick={() => setValue('totalAmount', 0, { shouldValidate: true })}
                    className="rounded-full border border-input px-2.5 py-0.5 text-xs text-foreground hover:bg-accent">
                    {t('noRefund')}
                  </button>
                  {maxRefund !== undefined && (
                    <button
                      type="button"
                      onClick={() => setValue('totalAmount', maxRefund, { shouldValidate: true })}
                      className="rounded-full border border-input px-2.5 py-0.5 text-xs text-foreground hover:bg-accent">
                      {t('fullRefund')}
                    </button>
                  )}
                </div>
              </div>
              <div className="relative">
                <Input
                  id={`refund-${orderId}`}
                  type="number"
                  inputMode="decimal"
                  min={0}
                  max={maxRefund}
                  step="0.01"
                  placeholder={t('enterAmount')}
                  aria-invalid={!!errors.totalAmount}
                  className="pe-14"
                  {...register('totalAmount')}
                />
                <span className="pointer-events-none absolute end-3 top-1/2 -translate-y-1/2 text-[13px] text-muted-foreground">
                  {t('SAR')}
                </span>
              </div>
              {errorText(errors.totalAmount?.message)}
            </div>

            <div className="space-y-2">
              <Label htmlFor={`reason-${orderId}`}>{t('reasonForCancellation')}</Label>
              <Textarea
                id={`reason-${orderId}`}
                rows={3}
                placeholder={t('enterReason')}
                aria-invalid={!!errors.cancellationReason}
                {...register('cancellationReason')}
              />
              {errorText(errors.cancellationReason?.message)}
            </div>
          </form>

          <DialogFooter className="gap-2 sm:gap-0">
            <Button variant="secondary" onClick={() => setOpen(false)} disabled={saving}>
              {t('keepOrder')}
            </Button>
            <Button variant="danger" type="submit" form={`cancel-${orderId}`} loading={saving}>
              {t('cancelOrder')}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
};

export default CancelOrderDialog;
