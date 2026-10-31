import bikersService from '@services/bikers.service';
import { AdminStatus, Button, EmtyState, ThreeDotsLoader } from '@UI/Index';
import { useTranslation } from 'react-i18next';
import useSWR, { mutate } from 'swr';
import { IBikers } from '@servicesTypes/bikers.types';
import { RiFocus3Line } from 'react-icons/ri';
import ordersService from '@services/orders.service';
import { toast } from 'react-toastify';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/shadecn/components/ui/table';

const AssignedBikerTable = ({ orderId, setOpenSheet, areaId }) => {
  const { t, i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';

  const { data, isLoading } = useSWR(['get-bikers-by-area-id'], () =>
    bikersService.getBikersByAreaId(areaId).then((data) => {
      return data.data as IBikers[];
    })
  );

  const handelOnAssigne = (orderId, bikerId) => {
    ordersService
      .assignBikerOrder(orderId, { bikerId })
      .then(() => {
        mutate((key: string) => key.includes('get-all-order-details'));
        mutate((key: string) => key.includes('get-all-order-list'));
        toast.success(t('bikerAssigned'));
        setOpenSheet(false);
      })
      .catch(({ response }) => {
        const messages = response?.data?.message;
        const errList = Array.isArray(messages)
          ? messages.map((e, index) => <p key={index}>{e}</p>)
          : messages?.[lang] || t('An error occurred');
        toast.error(<div>{errList}</div>);
      });
  };

  return (
    <div className="relative">
      {isLoading && <ThreeDotsLoader />}
      <Table className="table-fixed">
        <TableHeader>
          <TableRow>
            {[t('name'), t('phone'), t('Assigne')].map((head, index) => (
              <TableHead key={index}>{head}</TableHead>
            ))}
          </TableRow>
        </TableHeader>
        <TableBody>
          {data &&
            data?.map((biker) => (
              <TableRow key={biker?._id}>
                <TableCell>{biker?.userName}</TableCell>
                <TableCell>{biker.phone}</TableCell>
                <TableCell>
                  <Button size="sm" onClick={() => handelOnAssigne(orderId, biker?._id)}>
                    <RiFocus3Line size={20} />
                  </Button>
                </TableCell>
              </TableRow>
            ))}
        </TableBody>
      </Table>
      {data?.length === 0 && <EmtyState />}
    </div>
  );
};

export default AssignedBikerTable;
