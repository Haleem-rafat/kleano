import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@shadecn/components/ui/table';
import { Button, EmtyState, ThreeDotsLoader } from '@UI/Index';
import { t } from 'i18next';
import { useState } from 'react';
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from '@shadecn/components/ui/sheet';
import iconsService from '@services/icons.service';
import { toast } from 'react-toastify';
import { mutate } from 'swr';
import { useTranslation } from 'react-i18next';
import IconsForm from './_components/IconsForm';
import useGetIconsOptions from '@/hooks/useGetIconsOptions';

export default function Icons() {
  const [openSheet, setOpenSheet] = useState(false);
  const [isloading, setIsLoading] = useState(false);

  const { iconsOptions, loadingiconsOptions } = useGetIconsOptions();

  const { t, i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';

  const handelDelete = (id) => {
    setIsLoading(true);
    iconsService
      .deleteIcons(id)
      .then((e) => {
        mutate((key: string) => key.includes('get-icons'));
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
    <div className="relative">
      <div className="flex items-center justify-between pb-6">
        <p className="text-2xl font-semibold capitalize text-slate-900">{t('Icons')}</p>
        <div>
          <Button onClick={() => setOpenSheet(true)}>{t('AddNewIcons')}</Button>
        </div>
      </div>
      <div className="max-h-[calc(100vh-200px)] overflow-auto rounded-xl border border-slate-200 bg-white p-2">
        {loadingiconsOptions && <ThreeDotsLoader />}
        <Table className="scrollbar-hide">
          <TableHeader>
            <TableRow>
              {[t('Title'), t('delete')].map((head, index) => (
                <TableHead key={index}>{head}</TableHead>
              ))}
            </TableRow>
          </TableHeader>
          <TableBody>
            {iconsOptions.map((e) => (
              <TableRow key={e.value} className="cursor-pointer hover:bg-primary/10">
                <TableCell className="font-medium">{e.label}</TableCell>
                <TableCell className="font-medium">
                  <Button variant="danger" size="sm" loading={isloading} onClick={() => handelDelete(e?.value)}>
                    {t("Deleteimg")}
                  </Button>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
        {iconsOptions?.length === 0 && <EmtyState />}
      </div>

      <Sheet open={openSheet} onOpenChange={() => setOpenSheet(false)} modal={true}>
        <SheetContent>
          <SheetHeader>
            <SheetTitle>{t('AddNewIcons')}</SheetTitle>
            <SheetDescription>
              <IconsForm setOpenSheet={setOpenSheet} />
            </SheetDescription>
          </SheetHeader>
        </SheetContent>
      </Sheet>
    </div>
  );
}
