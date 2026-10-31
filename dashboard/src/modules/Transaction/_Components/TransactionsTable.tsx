import { formatDate } from '@app/utils/helper';
import { AdminStatus, EmtyState, MainAvatar } from '@UI/Index';
import { useTranslation } from 'react-i18next';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/shadecn/components/ui/table';

const TransactionsTable = ({ data = [] }: { data }) => {
  const { t, i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';

  return (
    <div>
      <Table>
        <TableHeader>
          <TableRow>
            {[t('name'),
              t('phone'),
              t('bikerName'),
              t('discount'),
              t('paied'), 
              t('refundAmount'), 
              t('createddate'), 
              t('paymentStatus'), 
              t('status')]
              .map((head, index) => (
                <TableHead key={index}>{head}</TableHead>
              ))}
          </TableRow>
        </TableHeader>
        <TableBody>
          {data?.data?.map((transaction) => {
            const order = transaction?.order; // Extract order from transaction

            return (
              <TableRow key={transaction._id}>
                <TableCell>
                  <div className="flex items-center gap-3">
                    <MainAvatar
                      src={order?.user?.imageLink}
                      name={order?.user?.userName}
                      className="h-10 w-10"
                    />
                    <p className="font-medium text-slate-900">{order?.user?.userName}</p>
                  </div>
                </TableCell>
                <TableCell>{order?.user?.phone}</TableCell>
                <TableCell>{order?.biker?.userName || "—"}</TableCell>
                <TableCell>{order?.discount}</TableCell>
                <TableCell>{order?.totalPay}</TableCell>
                <TableCell>{order?.refundAmount}</TableCell>
                <TableCell>{formatDate(order.createdAt)}</TableCell>
                <TableCell>{t(order?.paymentStatus)}</TableCell>
                <TableCell>{<AdminStatus status={order?.status} />}</TableCell>
              </TableRow>
            );
          })}
        </TableBody>
      </Table>
      {data?.data?.length === 0 && <EmtyState />}
    </div>
  );
};

export default TransactionsTable;
