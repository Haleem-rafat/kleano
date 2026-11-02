import { Loader2 } from 'lucide-react';
import { ROUTES } from '@constants/routes';
import usersService from '@services/users.service';
import { Input } from '@shadecn/components/ui/input';
import { ColumnDef } from '@tanstack/react-table';
import { Button, DataTable, EmtyState, MainAvatar, PageHeader } from '@UI/Index';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { generatePath, useNavigate } from 'react-router-dom';
import useSWR from 'swr';
import { toast } from 'react-toastify';
import { IoAddCircleOutline, IoSearchOutline } from 'react-icons/io5';
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
          perPage: 20,
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
      document.body.appendChild(link);
      link.click();
      link.remove();
      window.URL.revokeObjectURL(url);
    } catch ({ response }) {
      const messages = response?.data?.message;
      const errList = Array.isArray(messages)
        ? messages.map((e, index) => <p key={index}>{e}</p>)
        : messages?.[lang] || t('An error occurred');
      toast.error(<div>{errList}</div>);
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

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const columns: ColumnDef<any>[] = [
    { id: 'serialNumber', header: t('userId'), accessorKey: 'serialNumber' },
    {
      id: 'userName',
      header: t('name'),
      accessorKey: 'userName',
      cell: ({ row }) => (
        <div className="flex items-center gap-3">
          <MainAvatar
            src={row.original?.imageLink}
            name={row.original?.userName}
            className="h-8 w-8"
          />
          <span className="font-medium text-foreground">{row.original?.userName || '—'}</span>
        </div>
      ),
    },
    { id: 'email', header: t('email'), accessorFn: (user) => user?.email || '—' },
    { id: 'phone', header: t('phone'), accessorFn: (user) => user?.phone || '—' },
    {
      id: 'actions',
      header: t('action'),
      enableSorting: false,
      cell: ({ row }) => (
        <Button variant="secondary" size="sm" onClick={(e) => handleTopUpClick(e, row.original)}>
          <IoAddCircleOutline className="me-1.5 h-4 w-4" />
          {t('topUp')}
        </Button>
      ),
    },
  ];

  return (
    <div className="space-y-4">
      <PageHeader
        title={t('users')}
        actions={
          <Button variant="secondary" loading={loading} onClick={handelExport}>
            {t('Export')}
          </Button>
        }
      />
      <div className="flex flex-wrap items-center gap-2">
        <label className="relative w-full sm:w-72">
          <IoSearchOutline className="pointer-events-none absolute start-3 top-1/2 z-10 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <Input
            type="search"
            onChange={(e) => {
              setSearch(e.target.value);
              setPage(1);
            }}
            value={search}
            placeholder={t('search')}
            aria-label={t('search')}
            className="h-9 ps-9"
          />
        </label>
        <Select
          value={filter}
          onValueChange={(e) => {
            setFilter(e as 'SUSPENDED' | 'ACTIVE');
            setPage(1);
          }}>
          <SelectTrigger className="h-9 w-40" aria-label={t('status')}>
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            <SelectGroup>
              <SelectItem value="ACTIVE">{t('active')}</SelectItem>
              <SelectItem value="SUSPENDED">{t('suspended')}</SelectItem>
            </SelectGroup>
          </SelectContent>
        </Select>
      </div>
      <DataTable
        columns={columns}
        data={data?.dataList ?? []}
        isLoading={isLoading}
        showColumnToggle={false}
        onRowClick={(user) => navigate(generatePath(ROUTES.USERS_DETAILS, { userId: user._id }))}
        emptyStateComponent={<EmtyState />}
      />
      {data?.paginationData?.totalPages > 1 && (
        <PaginationComponent
          page={data.paginationData.page}
          pages={data.paginationData.totalPages}
          setPageIndex={setPage}
        />
      )}

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
                  <Loader2 className="h-4 w-4 animate-spin" />
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
