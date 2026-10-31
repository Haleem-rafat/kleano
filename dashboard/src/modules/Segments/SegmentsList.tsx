import useSWR from 'swr';

import { Button, EmtyState, ThreeDotsLoader } from '@UI/Index';
import { generatePath, useNavigate } from 'react-router-dom';
import { ROUTES } from '@constants/routes';
import segmentsService from '@services/segments.service';
import { useTranslation } from 'react-i18next';

import { formatDate } from '@app/utils/helper';
import { useState } from 'react';
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from '@shadecn/components/ui/sheet';
import SegmentsDialogeWrapper from './_Components/SegmentsDialogeWrapper';
import ViewUsers from './_Components/ViewUsers';
import SegmentModelForm from './_Components/SegmentModelForm';

import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/shadecn/components/ui/table';

const SegmentsList = () => {
  const navigate = useNavigate();
  const { t } = useTranslation();
  const [openSheet, setOpenSheet] = useState(false);

  const { data, isLoading } = useSWR(['get-all-segments-list'], () =>
    segmentsService.getAllSegments().then((data) => data)
  );

  return (
    <div className="relative">
      {isLoading && <ThreeDotsLoader />}
      <div className="flex items-center justify-between pb-6">
        <p className="text-2xl font-semibold capitalize text-slate-900">{t('segments')}</p>
        <div>
          <Button onClick={() => setOpenSheet(true)}>{t('addNewSegments')}</Button>
        </div>
      </div>
      <div className="max-h-[calc(100vh-200px)] overflow-auto rounded-xl border border-slate-200 bg-white p-2">
        <Table className="scrollbar-hide">
          <TableHeader>
            <TableRow>
              {[t('name'), t('createddate'), t('selectedUser')].map((item, index) => (
                <TableHead key={index}>{item}</TableHead>
              ))}
            </TableRow>
          </TableHeader>
          <TableBody>
            {data &&
              data?.data?.map((segment) => (
                <TableRow
                  className="cursor-pointer hover:bg-primary/10"
                  onClick={() =>
                    navigate(generatePath(ROUTES.SEGMENTS_DETAILS, { segmenId: segment._id }))
                  }
                  key={segment._id}>
                  <TableCell>{segment.name}</TableCell>
                  <TableCell>{formatDate(segment.createdAt)}</TableCell>
                  <TableCell className="cursor-pointer underline">
                    <SegmentsDialogeWrapper
                      modal
                      triggerButtonElement={
                        <Button
                          onClick={(e) => e.stopPropagation()}
                          variant="secondary"
                          size="sm"
                          className="">
                          {segment.users.length} users
                        </Button>
                      }>
                      <ViewUsers segmentId={segment._id} />
                    </SegmentsDialogeWrapper>
                  </TableCell>
                </TableRow>
              ))}
          </TableBody>
        </Table>
        {data?.data?.length === 0 && <EmtyState />}
      </div>

      <Sheet open={openSheet} onOpenChange={() => setOpenSheet(false)} modal={true}>
        <SheetContent>
          <SheetHeader>
            <SheetTitle>{t('addNewSegments')}</SheetTitle>
            <SheetDescription>
              <SegmentModelForm setOpenSheet={setOpenSheet} />
            </SheetDescription>
          </SheetHeader>
        </SheetContent>
      </Sheet>
    </div>
  );
};

export default SegmentsList;
