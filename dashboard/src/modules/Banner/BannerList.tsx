import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@shadecn/components/ui/table';

import { Button, EmtyState, ImageModal, ThreeDotsLoader } from '@UI/Index';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import useSWR, { mutate } from 'swr';
import bannerService from '@services/banner.service';
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from '@shadecn/components/ui/sheet';
import { toast } from 'react-toastify';
import BannerForm from './_components/BannerForm';

const BannerList = () => {
  const [loading, setLoading] = useState(false);
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
    setLoading(true);
    await bannerService
      .toggleBannerStatus(id, status)
      .then(() => {
        toast.success('Banner status changed successfully');
        mutate();
        setLoading(false);
      })
      .catch((e) => {
        setLoading(false);
        toast.error(e.response.data.localizedMessage.en);
      });
  };
  return (
    <div className="relative">
      <div className="flex flex-wrap items-center justify-between gap-3 pb-6">
        <p className="text-xl font-semibold capitalize tracking-tight text-slate-900">{t('banners')}</p>

        <Button onClick={() => setOpen(true)}>{t('Add banner')}</Button>
      </div>
      <div>
        {isLoading && <ThreeDotsLoader />}
        <Table className="scrollbar-hide">
          <TableHeader>
            <TableRow>
              <TableHead>{t('title')}</TableHead>
              <TableHead>{t('description')}</TableHead>
              <TableHead>{t('External Link') || 'External URL'}</TableHead>
              <TableHead>{t('image') || 'Image'}</TableHead>
              <TableHead>{t('image (Arabic)') || 'Image (Arabic)'}</TableHead>
              <TableHead>{t('Resource')}</TableHead>
              <TableHead>{t('status')}</TableHead>
              <TableHead>{t('actions')}</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {data?.map((banner) => (
              <TableRow key={banner._id} className="cursor-pointer hover:bg-primary/10">
                <TableCell className="font-medium">{banner?.title}</TableCell>
                <TableCell className="font-medium">{banner?.description}</TableCell>
                <TableCell className="font-medium">
                  {banner?.externalUrl ? (
                    <a
                      href={banner.externalUrl}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="text-primary hover:underline">
                      {banner.externalUrl.length > 40
                        ? `${banner.externalUrl.slice(0, 40)}...`
                        : banner.externalUrl}
                    </a>
                  ) : (
                    <span className="text-slate-400">N/A</span>
                  )}
                </TableCell>
                <TableCell className="font-medium">
                  <ImageModal
                    src={banner.imageLink}
                    alt={`${banner.title} banner image`}
                    className="h-16 w-16 rounded-lg"
                    fallbackText="No image"
                  />
                </TableCell>
                <TableCell className="font-medium">
                  <ImageModal
                    src={banner.imageLinkAr}
                    alt={`${banner.title} banner image (Arabic)`}
                    className="h-16 w-16 rounded-lg"
                    fallbackText="No image"
                  />
                </TableCell>
                <TableCell className="font-medium">
                  {banner?.externalUrl ? (
                    <span className="text-slate-400">N/A</span>
                  ) : (
                    <span>
                      {banner?.resource
                        ? banner.resource === 'PROMO_CODE'
                          ? t('Promo Code')
                          : banner.resource === 'PLAN'
                          ? t('Plan')
                          : banner.resource
                        : '--'}
                    </span>
                  )}
                </TableCell>

                <TableCell
                  onClick={() =>
                    handleChangeStatus(banner._id, banner.isActive ? 'deactivate' : 'activate')
                  }
                  className="font-medium">
                  <p
                    className={`${
                      banner?.isActive ? 'bg-green-500' : 'bg-red-500'
                    } !w-[5rem] rounded-md border p-3 text-center text-white`}>
                    {banner?.isActive ? 'Active' : 'Inactive'}
                  </p>
                </TableCell>
                <TableCell>
                  <Button
                    onClick={() => {
                      setSelectedForEdit(banner);
                      setOpen(true);
                    }}>
                    {t('edit')}
                  </Button>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
        {/* {data?.paginationData && (
          <PaginationComponent
            page={data?.paginationData?.page}
            pages={data?.paginationData?.totalPages}
            setPageIndex={setPage}
          />
        )} */}
        {data?.data?.length === 0 && <EmtyState />}

        <Sheet
          open={open}
          onOpenChange={() => {
            setOpen(false);
            setSelectedForEdit(null);
          }}
          modal={true}>
          <SheetContent>
            <SheetHeader>
              <SheetTitle>{selectedForEdit ? t('editBanner') : t('addBanner')}</SheetTitle>
              <SheetDescription>
                <BannerForm oldData={selectedForEdit} setOpen={setOpen} />
              </SheetDescription>
            </SheetHeader>
          </SheetContent>
        </Sheet>
      </div>
    </div>
  );
};

export default BannerList;
