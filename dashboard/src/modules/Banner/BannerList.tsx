import { Button, DataTable, EmtyState, ImageModal, FormSheet } from '@UI/Index';
import { ColumnDef } from '@tanstack/react-table';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import useSWR from 'swr';
import bannerService from '@services/banner.service';
import { toast } from 'react-toastify';
import BannerForm from './_components/BannerForm';

const BannerList = () => {
  const [togglingId, setTogglingId] = useState<string | null>(null);
  const [selectedForEdit, setSelectedForEdit] = useState(null);
  const [open, setOpen] = useState(false);
  const { t } = useTranslation();

  const fetchBanners = async () => {
    return await bannerService
      .getBanners()
      .then((data) => {
        return data.data;
      })
      .catch((e) => {
        console.log(e);
      });
  };
  const { data, isLoading, mutate } = useSWR('get-all-banners', fetchBanners);

  const handleChangeStatus = async (id, status: 'activate' | 'deactivate') => {
    setTogglingId(id);
    await bannerService
      .toggleBannerStatus(id, status)
      .then(() => {
        toast.success('Banner status changed successfully');
        mutate();
        setTogglingId(null);
      })
      .catch((e) => {
        setTogglingId(null);
        toast.error(e?.response?.data?.localizedMessage?.en || t('somethingWentWrong'));
      });
  };
  const resourceLabel = (resource?: string) =>
    resource === 'PROMO_CODE' ? t('Promo Code') : resource === 'PLAN' ? t('Plan') : resource || '—';

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const columns: ColumnDef<any>[] = [
    { id: 'title', header: t('title'), accessorKey: 'title' },
    {
      id: 'description',
      header: t('description'),
      accessorKey: 'description',
      cell: ({ row }) => (
        <span className="max-w-[16rem] block truncate">{row.original?.description}</span>
      ),
    },
    {
      id: 'externalUrl',
      header: t('External Link'),
      accessorKey: 'externalUrl',
      cell: ({ row }) =>
        row.original?.externalUrl ? (
          <a
            href={row.original.externalUrl}
            target="_blank"
            rel="noopener noreferrer"
            onClick={(e) => e.stopPropagation()}
            className="max-w-[14rem] block truncate text-primary hover:underline">
            {row.original.externalUrl}
          </a>
        ) : (
          <span className="text-muted-foreground">—</span>
        ),
    },
    {
      id: 'image',
      header: t('image'),
      enableSorting: false,
      enableGlobalFilter: false,
      cell: ({ row }) => (
        <ImageModal
          src={row.original.imageLink}
          alt={`${row.original.title} banner image`}
          className="h-12 w-12 rounded-md"
          fallbackText="No image"
        />
      ),
    },
    {
      id: 'imageAr',
      header: t('image (Arabic)'),
      enableSorting: false,
      enableGlobalFilter: false,
      cell: ({ row }) => (
        <ImageModal
          src={row.original.imageLinkAr}
          alt={`${row.original.title} banner image (Arabic)`}
          className="h-12 w-12 rounded-md"
          fallbackText="No image"
        />
      ),
    },
    {
      id: 'resource',
      header: t('Resource'),
      accessorFn: (banner) => (banner?.externalUrl ? '—' : resourceLabel(banner?.resource)),
    },
    {
      id: 'status',
      header: t('status'),
      accessorFn: (banner) => (banner?.isActive ? 'active' : 'inactive'),
      cell: ({ row }) => {
        const banner = row.original;
        return (
          <button
            type="button"
            disabled={togglingId === banner._id}
            onClick={() =>
              handleChangeStatus(banner._id, banner.isActive ? 'deactivate' : 'activate')
            }
            title={banner.isActive ? t('deactivate') : t('activate')}
            className={`rounded-full px-3 py-1 text-xs font-semibold transition-opacity disabled:opacity-50 ${
              banner.isActive
                ? 'bg-success/10 text-success hover:bg-success/20'
                : 'bg-destructive/10 text-destructive hover:bg-destructive/20'
            }`}>
            {banner.isActive ? t('active') : t('inactive')}
          </button>
        );
      },
    },
    {
      id: 'actions',
      header: t('actions'),
      enableSorting: false,
      enableGlobalFilter: false,
      cell: ({ row }) => (
        <Button
          variant="secondary"
          size="sm"
          onClick={() => {
            setSelectedForEdit(row.original);
            setOpen(true);
          }}>
          {t('edit')}
        </Button>
      ),
    },
  ];

  return (
    <div className="relative">
      <div className="flex flex-wrap items-center justify-between gap-3 pb-6">
        <h1 className="text-xl font-semibold tracking-tight text-foreground">{t('banners')}</h1>

        <Button onClick={() => setOpen(true)}>{t('Add banner')}</Button>
      </div>
      <div>
        <DataTable
          columns={columns}
          data={data || []}
          isLoading={isLoading}
          searchable
          showColumnToggle={false}
          emptyStateComponent={<EmtyState />}
        />

        <FormSheet
          open={open}
          onOpenChange={() => {
            setOpen(false);
            setSelectedForEdit(null);
          }}
          title={selectedForEdit ? t('editBanner') : t('addBanner')}>
          <BannerForm oldData={selectedForEdit} setOpen={setOpen} />
        </FormSheet>
      </div>
    </div>
  );
};

export default BannerList;
