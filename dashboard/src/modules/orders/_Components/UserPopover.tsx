import { Button } from '@UI/Index';
import { Input } from '@shadecn/components/ui/input';
import { useTranslation } from 'react-i18next';
import { useForm } from 'react-hook-form';
import { mutate } from 'swr';
import { toast } from 'react-toastify';
import ordersService from '@services/orders.service';
import { useState } from 'react';
import { Label } from '@/shadecn/components/ui/label';
import { Popover, PopoverContent, PopoverTrigger } from '@/shadecn/components/ui/popover';

type CancelOrderForm = {
  totalAmount: number;
  cancellationReason: string;
};

const UserPopover = ({ orderId }: { orderId: string }) => {
  const { t, i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';
  const [isloading, setIsLoading] = useState(false);

  const {
    register,
    handleSubmit,
    formState: { isSubmitting },
  } = useForm<CancelOrderForm>();

  const handleClick = (event: React.MouseEvent) => {
    event.stopPropagation(); // Prevent row click from triggering navigation
  };

  const handleCancelOrder = (data: CancelOrderForm) => {
    setIsLoading(true);

    ordersService
      .cancelOrderByAdmin({
        totalAmount: data.totalAmount,
        order: orderId,
        cancellationReason: data.cancellationReason,
      })
      .then(() => {
        toast.success(t('Order canceled successfully'));
        mutate((key: string) => key.includes('get-all-order-list'));
        mutate((key: string) => key.includes('get-all-order-details'));
      })
      .catch(({ response }) => {
        const messages = response?.data?.message;
        const errList = Array.isArray(messages)
          ? messages.map((e, index) => <p key={index}>{e}</p>)
          : messages?.[lang] || 'An error occurred';
        toast.error(<div>{errList}</div>);
      })
      .finally(() => setIsLoading(false));
  };

  return (
    <Popover>
      <PopoverTrigger asChild>
        <Button onClick={handleClick} loading={isloading} disabled={isSubmitting}>
          {t('cancel')}
        </Button>
      </PopoverTrigger>
      <PopoverContent className="w-64 p-4">
        <form onSubmit={handleSubmit(handleCancelOrder)} className="flex flex-col gap-3">
          <div>
            <Label htmlFor="refundAmount" className="text-sm font-medium">
              {t('refundAmount')}
            </Label>
            <Input
              onClick={handleClick}
              type="number"
              placeholder={t('enterAmount')}
              {...register('totalAmount', { required: true })}
            />
          </div>
          <div>
            <Label htmlFor="reason" className="text-sm font-medium">
              {t('reasonForCancellation')}
            </Label>
            <Input
              onClick={handleClick}
              type="text"
              placeholder={t('enterReason')}
              {...register('cancellationReason', { required: true })}
            />
          </div>
          <Button onClick={handleClick} type="submit" loading={isloading} disabled={isSubmitting}>
            {t('confirm')}
          </Button>
        </form>
      </PopoverContent>
    </Popover>
  );
};

export default UserPopover;
