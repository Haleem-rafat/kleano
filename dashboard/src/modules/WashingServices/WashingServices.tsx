import { useState } from 'react';
import { IwshaingServicesList } from '@servicesTypes/wshaingServices.types';
import { useTranslation } from 'react-i18next';

import useSWR from 'swr';
import washingServicesService from '@services/washingServices.service';

import pointIcon from '@assets/icons/point-icon.svg';
import { Button, EmtyState, ThreeDotsLoader } from '@UI/Index';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@shadecn/components/ui/table';
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from '@shadecn/components/ui/sheet';
import { generatePath, useNavigate } from 'react-router-dom';
import { ROUTES } from '@constants/routes';
import { formatDate } from '@app/utils/helper';
import WashingServicesForm from './_components/WashingServicesForm';

export default function WashingServices() {
  const [openSheet, setOpenSheet] = useState(false);

  const navigate = useNavigate();
  const { t, i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';

  const { data, isLoading } = useSWR(['get-washing-services-list'], () =>
    washingServicesService.getWashingServicesList().then((data) => data)
  );

  return (
    <div className="relative">
      <div className="flex items-center justify-between pb-6">
        <p className="text-xl font-semibold capitalize tracking-tight text-slate-900">{t('washingServices')}</p>
        <div>
          <Button onClick={() => setOpenSheet(true)}>{t('addNewServices')}</Button>
        </div>
      </div>
      <div className="max-h-[calc(100vh-200px)] overflow-auto rounded-xl border border-slate-200 bg-white p-2">
        {isLoading && <ThreeDotsLoader />}
        <Table className="scrollbar-hide">
          <TableHeader>
            <TableRow>
              <TableHead className="min-w-[150px]"> {t('servesName')}</TableHead>
              <TableHead className="min-w-[100px]"> {t('durationTime')}</TableHead>
              <TableHead className="min-w-[100px]"> {t('servesPrice')} </TableHead>
              <TableHead className="min-w-[100px]"> {t('type')} </TableHead>
              <TableHead className="min-w-[100px]"> {t('createddate')}</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {(data?.data as IwshaingServicesList[])?.map((wshaingServices) => (
              <TableRow
                key={wshaingServices?._id}
                onClick={() =>
                  navigate(
                    generatePath(ROUTES.WASHING_SERVICES_DETAILS, {
                      washingServicesId: wshaingServices._id,
                    })
                  )
                }
                className="cursor-pointer hover:bg-primary/10">
                <TableCell className="flex gap-2 text-center">
                  <img
                    className="h-10 w-10 rounded-full "
                    src={wshaingServices?.icon?.iconLink}
                    alt="biker img"
                  />
                  <p className="pt-2">{wshaingServices?.name?.[lang] || wshaingServices?.name}</p>
                </TableCell>
                <TableCell> {wshaingServices.duration} min</TableCell>
                <TableCell>{wshaingServices?.price} SAR</TableCell>
                <TableCell>{wshaingServices?.type}</TableCell>
                <TableCell>{formatDate(wshaingServices?.createdAt)}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
        {data?.data?.length === 0 && <EmtyState />}
      </div>

      <Sheet open={openSheet} onOpenChange={() => setOpenSheet(false)} modal={true}>
        <SheetContent>
          <SheetHeader>
            <SheetTitle>{t('addNewServices')}</SheetTitle>
            <SheetDescription>
              <WashingServicesForm setOpenSheet={setOpenSheet} />
            </SheetDescription>
          </SheetHeader>
        </SheetContent>
      </Sheet>
    </div>
  );
}
