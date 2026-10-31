import { formatDate } from '@app/utils/helper';
import { ROUTES } from '@constants/routes';
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from '@shadecn/components/ui/sheet';
import { Button, EmtyState, ThreeDotsLoader } from '@UI/Index';
import { useState } from 'react';
import { generatePath, useNavigate } from 'react-router-dom';
import useSWR from 'swr';
import { useTranslation } from 'react-i18next';

import addOnsService from '@services/addOns.service';
import { IAddOns } from '@servicesTypes/addOns';
import AddOnsForm from './_components/AddOnsForm';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/shadecn/components/ui/table';

export default function AddOnsList() {
  const navigate = useNavigate();
  const { t, i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';
  const [openSheet, setOpenSheet] = useState(false);

  const { data, isLoading } = useSWR(['get-all-add-ons-list'], () =>
    addOnsService.getAllAddOnsList().then((data) => data.data)
  );

  return (
    <div className="relative">
      <div className="flex items-center justify-between pb-6">
        <p className="text-2xl font-semibold capitalize text-slate-900">{t('addOns')}</p>
        <div>
          <Button onClick={() => setOpenSheet(true)}>{t('addNewAddOns')}</Button>
        </div>
      </div>
      <div className="max-h-[calc(100vh-200px)] overflow-auto rounded-xl border border-slate-200 bg-white p-2">
        {isLoading && <ThreeDotsLoader />}
        <Table className="scrollbar-hide">
          <TableHeader>
            <TableRow>
              {[t('addOnsName'), t('addOnsPrice'), t('stock'), t('createddate')].map(
                (head, index) => (
                  <TableHead key={index}>{head}</TableHead>
                )
              )}
            </TableRow>
          </TableHeader>
          <TableBody>
            {data &&
              (data as IAddOns[])?.map((addOns) => (
                <TableRow
                  key={addOns._id}
                  className="cursor-pointer hover:bg-primary/10"
                  onClick={() =>
                    navigate(generatePath(ROUTES.ADD_ONS_DETAILS, { addOnsId: addOns._id }))
                  }>
                  <TableCell>
                    <div className="flex gap-x-10">
                      <img className="h-10 w-10 rounded-full " src={addOns?.icon?.iconLink} />
                      <p className="pt-2">{addOns?.name?.[lang] || addOns?.name}</p>
                    </div>
                  </TableCell>
                  <TableCell>{addOns?.price} SAR</TableCell>
                  <TableCell>{addOns?.stock}</TableCell>
                  <TableCell>{formatDate(addOns?.createdAt)}</TableCell>
                </TableRow>
              ))}
          </TableBody>
        </Table>
        {data?.length === 0 && <EmtyState />}
      </div>

      <Sheet open={openSheet} onOpenChange={() => setOpenSheet(false)} modal={true}>
        <SheetContent>
          <SheetHeader>
            <SheetTitle>{t('addNewAddOns')}</SheetTitle>
            <SheetDescription>
              <AddOnsForm setOpenSheet={setOpenSheet} />
            </SheetDescription>
          </SheetHeader>
        </SheetContent>
      </Sheet>
    </div>
  );
}
