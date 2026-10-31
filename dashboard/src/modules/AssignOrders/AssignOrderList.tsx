import React, { useState } from 'react';
import { generatePath, useNavigate } from 'react-router-dom';
import { EmtyState, MainAvatar, ThreeDotsLoader } from '@UI/Index';
import useSWR from 'swr';
import { useTranslation } from 'react-i18next';
import { ROUTES } from '@constants/routes';
import { formatDate } from '@app/utils/helper';
import PaginationComponent from '@UI/paginationComponent/PaginationComponent';
import MainStatusChipe from '@UI/Status/MainStatusChipe';
import assignedOrdersService from '@services/assignedOrders.service';

import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/shadecn/components/ui/table';

const AssignOrderList = () => {
  const navigate = useNavigate();
  const { t } = useTranslation();
  const [pageIndex, setPageIndex] = useState(1);

  const { data: assignedOrdersList, isLoading } = useSWR(
    ['get-all-assign-orders-list', pageIndex],
    () =>
      assignedOrdersService
        .getAllAssingedOrders({
          page: pageIndex,
          perPage: 20,
        })
        .then((data) => {
          return data;
        })
  );

  return (
    <div className="relative flex h-full w-full flex-col gap-3">
      <div className="flex items-center justify-between pb-10">
        <p className="text-2xl font-semibold">{t('admins')}</p>
        <div></div>
      </div>
      <div className="h-[calc(100vh-300px)] overflow-y-scroll rounded-lg bg-white p-4 shadow">
        {isLoading && <ThreeDotsLoader />}
        <Table className="scrollbar-hide">
          <TableHeader>
            <TableRow>
              {[
                t('name'),
                t('phone'),
                t('bikerName'),
                t('bikerPhone'),
                t('createddate'),
                t('status'),
              ].map((head, index) => (
                <TableHead key={index}>{head}</TableHead>
              ))}
            </TableRow>
          </TableHeader>
          <TableBody>
            {assignedOrdersList &&
              assignedOrdersList?.data.map((order) => (
                <TableRow
                  key={order._id}
                  className="cursor-pointer hover:bg-primary/10"
                  onClick={() =>
                    navigate(generatePath(ROUTES.ORDER_DETAILS, { orderId: order._id }))
                  }>
                  <TableCell>
                    <div className="flex justify-center gap-x-10 md:justify-start">
                      <MainAvatar
                        src={order?.user?.imageLink}
                        name={order?.user?.userName}
                        className="h-10 w-10"
                      />
                      <p className="pt-2 text-start">{order?.user?.userName}</p>
                    </div>
                  </TableCell>
                  <TableCell>{order.user ? order.user.phone : '---'}</TableCell>
                  <TableCell>{order.biker ? order.biker.userName : '---'}</TableCell>
                  <TableCell>{order.biker ? order.biker.phone : '---'}</TableCell>
                  <TableCell>{formatDate(order.createdAt)}</TableCell>
                  <TableCell>{order.status && <MainStatusChipe status={order.status} />}</TableCell>
                </TableRow>
              ))}
          </TableBody>
        </Table>
        {assignedOrdersList?.data?.length === 0 && <EmtyState />}
      </div>
      {assignedOrdersList && (
        <PaginationComponent
          page={assignedOrdersList.pagination.page}
          pages={assignedOrdersList.pagination.totalPages}
          setPageIndex={setPageIndex}
        />
      )}
    </div>
  );
};

export default AssignOrderList;
