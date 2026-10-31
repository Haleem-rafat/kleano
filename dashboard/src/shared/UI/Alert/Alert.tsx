import React, { ReactElement, SetStateAction } from 'react';
import { useTranslation } from 'react-i18next';
import { Label } from '@shadecn/components/ui/label';

import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from '@/shadecn/components/ui/alert-dialog';

const Alert = ({
  buttonComponent,
  description,
  handler,
  id,
  hasReason = false,
  setInputValue,
}: {
  buttonComponent: ReactElement;
  description?: string;
  handler: (id?: any) => void;
  id: string;
  hasReason?: boolean;
  setInputValue?: React.Dispatch<SetStateAction<string>>;
}) => {
  const { t } = useTranslation();
  return (
    <AlertDialog>
      <AlertDialogTrigger asChild>{buttonComponent}</AlertDialogTrigger>
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>{t('confirmationMessage')}</AlertDialogTitle>
          <AlertDialogDescription>
            {description ?? t('cannotBeUndone')}
          </AlertDialogDescription>
          {hasReason && (
            <div className="my-4 flex w-full flex-col gap-4">
              <Label>{t('addReason')} :</Label>
              <textarea
                rows={8}
                className="border p-3"
                onChange={(e) => setInputValue(e.target.value)}
                placeholder={t('reasonPlaceHolder')}
              />
            </div>
          )}
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel>{t('cancel')}</AlertDialogCancel>
          <AlertDialogAction onClick={() => (id ? handler(id) : handler())}>
            {t('continue')}
          </AlertDialogAction>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  );
};

export default Alert;
