import { ROUTES } from '@constants/routes';
import usersService from '@services/users.service';
import { Input } from '@shadecn/components/ui/input';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@shadecn/components/ui/table';

import { Button, EmtyState, ThreeDotsLoader } from '@UI/Index';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { generatePath, useNavigate } from 'react-router-dom';
import useSWR from 'swr';
import { toast } from 'react-toastify';
import { IoAddCircleOutline } from 'react-icons/io5';
import PaginationComponent from '@UI/paginationComponent/PaginationComponent';
import useDebounce from '@/hooks/useDebounce';
import {
  Select,
  SelectContent,
  SelectGroup,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/shadecn/components/ui/select';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/shadecn/components/ui/dialog';
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '@/shadecn/components/ui/alert-dialog';
import { Label } from '@/shadecn/components/ui/label';

export default function UsersList() {
  const navigate = useNavigate();
  const [search, setSearch] = useState('');
  const [filter, setFilter] = useState<'SUSPENDED' | 'ACTIVE'>('ACTIVE');
  const [page, setPage] = useState(1);
  const [loading, setloading] = useState(false);
  const [topUpDialogOpen, setTopUpDialogOpen] = useState(false);
  const [confirmDialogOpen, setConfirmDialogOpen] = useState(false);
  const [selectedUser, setSelectedUser] = useState<{ _id: string; userName: string } | null>(null);
  const [amount, setAmount] = useState('');
  const [notes, setNotes] = useState('');
  const [topUpLoading, setTopUpLoading] = useState(false);
  const debouncedSearch = useDebounce(search, 800);
  const { t, i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';
  const { data, isLoading, mutate } = useSWR(
    ['get-all-users-list', page, filter, debouncedSearch],
    () =>
      usersService
        .paginatedUsers({
          search: debouncedSearch,
          status: filter,
          perPage: 19,
          page: page,
        })
        .then((data) => {
          return data.data;
        })
  );

  const handelExport = async () => {
    setloading(true);
    try {
      const response = await usersService.getUsersExportExcel();
      const url = window.URL.createObjectURL(response);
      const link = document.createElement('a');
      link.href = url;
      link.setAttribute('download', 'users_export.xlsx');
      link.click();
      link.parentNode.removeChild(link);
      window.URL.revokeObjectURL(url);
    } catch ({ response }) {
      const messages = response?.data?.message;
      const errList = Array.isArray(messages)
        ? messages.map((e, index) => <p key={index}>{e}</p>)
        : messages?.[lang] || t('An error occurred');
      console.log(<p>{errList}</p>);
    } finally {
      setloading(false);
    }
  };

  const handleTopUpClick = (e: React.MouseEvent, user: { _id: string; userName: string }) => {
    e.stopPropagation();
    setSelectedUser(user);
    setAmount('');
    setNotes('');
    setTopUpDialogOpen(true);
  };

  const handleTopUpSubmit = () => {
    if (!amount || isNaN(Number(amount)) || Number(amount) <= 0) {
      return;
    }
    setTopUpDialogOpen(false);
    setConfirmDialogOpen(true);
  };

  const handleConfirmTopUp = async () => {
    if (!selectedUser || !amount) return;

    setTopUpLoading(true);
    try {
      await usersService.addUserBalance(selectedUser._id, {
        amount: Number(amount),
        notes: notes || undefined,
      });
      setConfirmDialogOpen(false);
      setSelectedUser(null);
      setAmount('');
      setNotes('');
      mutate();
      toast.success(t('topUpPointsSuccess'));
    } catch ({ response }) {
      const messages = response?.data?.message;
      const errList = Array.isArray(messages)
        ? messages.map((e, index) => <p key={index}>{e}</p>)
        : messages?.[lang] || t('An error occurred');
      toast.error(<div>{errList}</div>);
    } finally {
      setTopUpLoading(false);
    }
  };

  return (
    <div className="relative">
      <div className="flex flex-wrap items-center justify-between gap-3 pb-6">
        <p className="text-xl font-semibold capitalize tracking-tight text-slate-900">{t('users')}</p>
        <div className="flex items-center justify-center gap-4">
          <Select onValueChange={(e) => setFilter(e as 'SUSPENDED' | 'ACTIVE')}>
            <SelectTrigger className="h-[48px] w-[180px]">
              <SelectValue placeholder="Select a Status" />
            </SelectTrigger>
            <SelectContent>
              <SelectGroup>
                <SelectItem value="ACTIVE">active</SelectItem>
                <SelectItem value="SUSPENDED">blocked</SelectItem>
              </SelectGroup>
            </SelectContent>
          </Select>
          <Input
            onChange={(e) => setSearch(e.target.value)}
            value={search}
            placeholder="search..."
          />
        </div>
        <div>
          <Button loading={loading} onClick={() => handelExport()}>
            {t('Export')}
          </Button>
        </div>
      </div>
      <div>
        {isLoading && <ThreeDotsLoader />}
        <Table className="scrollbar-hide">
          <TableHeader>
            <TableRow>
              {[t('userId'), t('name'), t('email'), t('phone'), t('action') || 'Actions'].map(
                (head, index) => (
                  <TableHead className="" key={index}>
                    {head}
                  </TableHead>
                )
              )}
            </TableRow>
          </TableHeader>
          <TableBody>
            {data?.dataList.map((user) => (
              <TableRow
                key={user._id}
                className="cursor-pointer hover:bg-primary/10"
                onClick={() => navigate(generatePath(ROUTES.USERS_DETAILS, { userId: user._id }))}>
                <TableCell className="font-medium">{user?.serialNumber}</TableCell>
                <TableCell className="font-medium">{user?.userName}</TableCell>
                <TableCell className="font-medium">{user?.email}</TableCell>
                <TableCell className="font-medium">{user?.phone}</TableCell>
                <TableCell onClick={(e) => e.stopPropagation()}>
                  <Button
                    variant="secondary"
                    size="sm"
                    onClick={(e) => handleTopUpClick(e, user)}
                    className="flex items-center gap-2">
                    <IoAddCircleOutline className="h-4 w-4" />
                    {t('topUp') || 'Top Up'}
                  </Button>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
        {data?.paginationData && (
          <PaginationComponent
            page={data?.paginationData?.page}
            pages={data?.paginationData?.totalPages}
            setPageIndex={setPage}
          />
        )}
        {data?.data?.length === 0 && <EmtyState />}
      </div>

      <Dialog open={topUpDialogOpen} onOpenChange={setTopUpDialogOpen}>
        <DialogContent className="sm:max-w-[425px]">
          <DialogHeader>
            <DialogTitle>{t('topUpPoints') || 'Top Up Points'}</DialogTitle>
            <DialogDescription>
              {t('topUpPointsDescription') || `Add points to ${selectedUser?.userName || 'user'}`}
            </DialogDescription>
          </DialogHeader>
          <div className="grid gap-4 py-4">
            <div className="grid gap-2">
              <Label htmlFor="amount">{t('amount') || 'Amount'}</Label>
              <Input
                id="amount"
                type="number"
                min="1"
                value={amount}
                onChange={(e) => setAmount(e.target.value)}
                placeholder={t('enterAmount') || 'Enter amount'}
              />
            </div>
            <div className="grid gap-2">
              <Label htmlFor="notes">
                {t('notes') || 'Notes'} ({t('optional') || 'Optional'})
              </Label>
              <Input
                id="notes"
                value={notes}
                onChange={(e) => setNotes(e.target.value)}
                placeholder={t('enterNotes') || 'Enter notes (optional)'}
              />
            </div>
          </div>
          <DialogFooter>
            <Button variant="secondary" onClick={() => setTopUpDialogOpen(false)}>
              {t('cancel')}
            </Button>
            <Button
              onClick={handleTopUpSubmit}
              disabled={!amount || isNaN(Number(amount)) || Number(amount) <= 0}>
              {t('continue')}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <AlertDialog open={confirmDialogOpen} onOpenChange={setConfirmDialogOpen}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>{t('confirmationMessage') || 'Confirm Top Up'}</AlertDialogTitle>
            <AlertDialogDescription>
              {amount && selectedUser
                ? t('confirmTopUp', { amount, userName: selectedUser.userName }) ||
                  `Are you sure you want to add ${amount} points to ${selectedUser.userName}?`
                : t('confirmTopUp') || 'Are you sure you want to proceed with this top-up?'}
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel disabled={topUpLoading}>{t('cancel')}</AlertDialogCancel>
            <AlertDialogAction onClick={handleConfirmTopUp} disabled={topUpLoading}>
              {topUpLoading ? (
                <span className="flex items-center gap-2">
                  <ThreeDotsLoader />
                  {t('processing') || 'Processing...'}
                </span>
              ) : (
                t('continue')
              )}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}
