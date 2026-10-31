import { formatDate } from '@app/utils/helper';
import { ROUTES } from '@constants/routes';
import plansService from '@services/plans.service';
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from '@shadecn/components/ui/sheet';
import { Button, EmtyState, ThreeDotsLoader } from '@UI/Index';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { generatePath, useNavigate } from 'react-router-dom';
import useSWR from 'swr';
import PlansModelForm from './_Components/PlansModelForm';

import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/shadecn/components/ui/table';

export default function Plans() {
  const navigate = useNavigate();

  const [openSheet, setOpenSheet] = useState(false);
  const { t, i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';

  const { data, isLoading } = useSWR(['get-all-plans-list'], () =>
    plansService.getAllPlansList().then((data) => data)
  );

  return (
    <div className="relative">
      <div className="flex items-center justify-between pb-6">
        <p className="text-2xl font-semibold capitalize text-slate-900">{t('plans')}</p>
        <div>
          <Button onClick={() => setOpenSheet(true)}>{t('AddNewPlan')}</Button>
        </div>
      </div>
      <div className="max-h-[calc(100vh-200px)] overflow-auto rounded-xl border border-slate-200 bg-white p-2">
        {isLoading && <ThreeDotsLoader />}
        <Table className="scrollbar-hide">
          <TableHeader>
            <TableRow>
              {[
                t('planType'),
                t('durationByMonth'),
                t('servesPrice'),
                t('usageCount'),
                t('createddate'),
              ].map((head, index) => (
                <TableHead key={index}>{head}</TableHead>
              ))}
            </TableRow>
          </TableHeader>
          <TableBody>
            {data?.data?.map((plan) => (
              <TableRow
                key={plan._id}
                className="cursor-pointer hover:bg-primary/10"
                onClick={() => navigate(generatePath(ROUTES.PLANS_DETAILS, { plansId: plan._id }))}>
                <TableCell className="font-medium">
                  <div className="flex items-center justify-start gap-2">
                    <div
                      className="h-10 w-10 rounded-full"
                      style={{
                        backgroundColor: `${plan.color}`,
                      }}></div>
                    <p>{plan.type?.[lang] || plan.type}</p>
                  </div>
                </TableCell>
                <TableCell>{plan.duration} month</TableCell>
                <TableCell>{plan.price} R.S</TableCell>
                <TableCell>{plan.usageCount}</TableCell>
                <TableCell>{formatDate(plan.createdAt)}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
        {data?.data?.length === 0 && <EmtyState />}
      </div>

      <Sheet open={openSheet} onOpenChange={() => setOpenSheet(false)} modal={true}>
        <SheetContent>
          <SheetHeader>
            <SheetTitle>{t('AddNewPlan')}</SheetTitle>
            <SheetDescription>
              <PlansModelForm setOpenSheet={setOpenSheet} />
            </SheetDescription>
          </SheetHeader>
        </SheetContent>
      </Sheet>
    </div>
  );
}
