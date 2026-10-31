import ordersService from '@services/orders.service';
import { IOrderList } from '@servicesTypes/order.types';
import { AdminStatus, Button, ThreeDotsLoader, ImageModal, StarRating } from '@UI/Index';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import {
  IoArrowBackCircleOutline,
  IoPersonOutline,
  IoCarOutline,
  IoLocationOutline,
  IoTimeOutline,
  IoCashOutline,
  IoCheckmarkCircleOutline,
  IoInformationCircleOutline,
} from 'react-icons/io5';
import { useNavigate, useParams } from 'react-router-dom';
import useSWR from 'swr';
import { formatDate } from '@app/utils/helper';
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from '@shadecn/components/ui/sheet';
import { Badge } from '@shadecn/components/ui/badge';
import AssignedBikerTable from '../_Components/AssignedBikerTable';
import UserPopover from '../_Components/UserPopover';

export default function OrderDetails() {
  const navigate = useNavigate();
  const { orderId } = useParams();

  const [openSheet, setOpenSheet] = useState(false);

  const { t, i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';

  const { data, isLoading } = useSWR(
    ['get-all-order-details', orderId],
    () =>
      orderId &&
      ordersService.getOrdersDetails(orderId).then((data) => {
        return data.data as IOrderList;
      })
  );
  return (
    <div className="min-h-screen bg-slate-50">
      {isLoading && <ThreeDotsLoader />}

      {/* Professional Header */}
      <div className="sticky top-0 z-[50] border-b border-slate-200 bg-white shadow-sm">
        <div className="px-6 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <button
                type="button"
                onClick={() => navigate(-1)}
                className="inline-flex h-10 w-10 items-center justify-center rounded-lg bg-slate-100 transition-colors duration-200 hover:bg-slate-200">
                <IoArrowBackCircleOutline className="h-5 w-5 text-slate-600" />
              </button>
              <div>
                <h1 className="text-xl font-semibold tracking-tight text-slate-900">{t('orderDetails')}</h1>
                <div className="mt-1 flex items-center space-x-2">
                  <span className="text-sm text-slate-500">Order ID:</span>
                  <span className="rounded bg-slate-100 px-2 py-1 font-mono text-xs text-slate-700">
                    #{data?._id}
                  </span>
                </div>
              </div>
            </div>
            <div className="flex items-center space-x-3">
              <UserPopover orderId={data?._id} />

              {['WAITING_FOR_BIKER_BY_ADMIN', 'ACCEPTED_BY_BIKER'].includes(data?.status) && (
                <Button onClick={() => setOpenSheet(true)}>{t('assignedBiker')}</Button>
              )}
              <AdminStatus status={data?.status} />
            </div>
          </div>
        </div>
      </div>

      {/* Main Dashboard Content */}
      <div className="pt-4">
        {data && (
          <div className="w-full">
            <div className="space-y-6">
              {/* First Row: User Info, Biker Info, Vehicle Info */}
              <div className="grid grid-cols-1 gap-6 xl:grid-cols-3">
                {/* User Information Section */}
                <div className="overflow-hidden rounded-xl border border-slate-200 bg-white">
                  <div className="border-b border-slate-100 bg-white px-5 py-3">
                    <div className="flex items-center space-x-3">
                      <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-brandTint">
                        <IoPersonOutline className="h-4 w-4 text-primary" />
                      </div>
                      <div>
                        <h2 className="text-sm font-semibold text-slate-900">{t('userInfo')}</h2>
                        <p className="text-sm text-slate-500">Customer information</p>
                      </div>
                    </div>
                  </div>
                  <div className="p-6">
                    <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
                      <div className="space-y-4">
                        <div
                          className="cursor-pointer"
                          onClick={() => navigate(`/app/users/${data?.user?._id}`)}>
                          <label className="mb-1 block text-xs font-medium uppercase tracking-wide text-slate-500">
                            {t('name')}
                          </label>
                          <p className="text-sm font-semibold text-slate-900">
                            {data?.user?.userName}
                          </p>
                        </div>
                        <div>
                          <label className="mb-1 block text-xs font-medium uppercase tracking-wide text-slate-500">
                            {t('phone')}
                          </label>
                          <p className="text-sm font-semibold text-slate-900">
                            {data?.user?.phone}
                          </p>
                        </div>
                      </div>
                      <div className="space-y-4">
                        <div>
                          <label className="mb-1 block text-xs font-medium uppercase tracking-wide text-slate-500">
                            {t('orderDate')}
                          </label>
                          <p className="text-sm font-semibold text-slate-900">
                            {formatDate(data?.createdAt)}
                          </p>
                        </div>
                        <div>
                          <label className="mb-1 block text-xs font-medium  capitalize tracking-wide text-slate-500">
                            {t('orderCount')}
                          </label>
                          <p className="text-sm font-semibold text-slate-900">
                            {data?.userOrdersCount}
                          </p>
                        </div>
                      </div>{' '}
                      <div>
                        <label className="mb-1 block whitespace-nowrap text-xs font-medium uppercase tracking-wide text-slate-500">
                          {/* user rating for this order */}
                          {t('userRatingForThisOrder')}
                        </label>
                        <StarRating rating={data?.ratingOfUser || 0} size="sm" showValue={true} />
                      </div>
                    </div>
                    {data?.description && (
                      <div className="mt-6 border-t border-slate-200 pt-6">
                        <label className="mb-3 block text-xs font-medium uppercase tracking-wide text-slate-500">
                          {t('User Notes')}
                        </label>
                        <div className="rounded-lg bg-slate-50 p-4">
                          <p className="text-sm text-slate-700">{data?.description[lang]}</p>
                        </div>
                      </div>
                    )}
                  </div>
                </div>

                {/* Biker Information Section */}
                {data?.biker && (
                  <div className="overflow-hidden rounded-xl border border-slate-200 bg-white">
                    <div className="border-b border-slate-100 bg-white px-5 py-3">
                      <div className="flex items-center space-x-3">
                        <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-brandTint">
                          <ImageModal
                            src={data?.biker?.imageLink}
                            alt="biker profile"
                            className="h-12 w-12 rounded-full object-cover"
                          />
                        </div>
                        <div>
                          <h2 className=" text-sm font-semibold text-slate-900">{t('bikerInfo')}</h2>
                          <p className="text-sm text-slate-500">Assigned service provider</p>
                        </div>
                      </div>
                    </div>
                    <div className="p-6">
                      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                        <div onClick={() => navigate(`/app/bikers/${data?.biker?._id}`)}>
                          <label className="mb-1 block cursor-pointer text-xs font-medium uppercase tracking-wide text-slate-500">
                            {t('bikerName')}
                          </label>
                          <p className="text-sm font-semibold text-slate-900">
                            {data?.biker?.userName}
                          </p>
                        </div>
                        <div>
                          <label className="mb-1 block text-xs font-medium uppercase tracking-wide text-slate-500">
                            {t('phone')}
                          </label>
                          <p className="text-sm font-semibold text-slate-900">
                            {data?.biker?.phone}
                          </p>
                        </div>
                        <div>
                          <label className="mb-1 block text-xs font-medium uppercase tracking-wide text-slate-500">
                            {t('bikerCommission')}
                          </label>
                          <p className="text-sm font-semibold text-slate-900">
                            {data?.bikerCommission || 'N/A'}
                          </p>
                        </div>
                        <div>
                          <label className="mb-1 block whitespace-nowrap text-xs font-medium uppercase tracking-wide text-slate-500">
                            {t('bikerRatingForThisOrder')}
                          </label>
                          <StarRating
                            rating={data?.ratingOfBiker || 0}
                            size="sm"
                            showValue={true}
                          />
                        </div>
                      </div>
                    </div>
                  </div>
                )}

                {/* Vehicle Information Section */}
                <div className="overflow-hidden rounded-xl border border-slate-200 bg-white">
                  <div className="border-b border-slate-100 bg-white px-5 py-3">
                    <div className="flex items-center space-x-3">
                      <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-brandTint">
                        <IoCarOutline className="h-4 w-4 text-primary" />
                      </div>
                      <div>
                        <h2 className="text-sm font-semibold text-slate-900">{t('vehicleInfo')}</h2>
                        <p className="text-sm text-slate-500">Vehicle details</p>
                      </div>
                    </div>
                  </div>
                  <div className="p-6">
                    <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                      <div>
                        <label className="mb-1 block text-xs font-medium uppercase tracking-wide text-slate-500">
                          {t('brand')}
                        </label>
                        <p className="text-sm font-semibold text-slate-900">
                          {data?.vehicle?.brand}
                        </p>
                      </div>
                      <div>
                        <label className="mb-1 block text-xs font-medium uppercase tracking-wide text-slate-500">
                          {t('model')}
                        </label>
                        <p className="text-sm font-semibold text-slate-900">
                          {data?.vehicle?.model}
                        </p>
                      </div>
                      <div>
                        <label className="mb-1 block text-xs font-medium uppercase tracking-wide text-slate-500">
                          {t('color')}
                        </label>
                        <p className="text-sm font-semibold text-slate-900">
                          {data?.vehicle?.color}
                        </p>
                      </div>
                      <div>
                        <label className="mb-1 block text-xs font-medium uppercase tracking-wide text-slate-500">
                          {t('plateNumber')}
                        </label>
                        <p className="font-mono text-sm font-semibold text-slate-900">
                          {data?.vehicle?.plateNumber}
                        </p>
                      </div>
                    </div>
                    {data?.vehicle?.imageLink && (
                      <div className="mt-6 border-t border-slate-200 pt-6">
                        <label className="mb-3 block text-xs font-medium uppercase tracking-wide text-slate-500">
                          {t('image')}
                        </label>
                        <div className="flex justify-center">
                          <ImageModal
                            src={data?.vehicle?.imageLink}
                            alt={`${data?.vehicle?.brand} vehicle image`}
                            className="h-24 w-24 rounded-lg"
                            fallbackText="Vehicle image not available"
                          />
                        </div>
                      </div>
                    )}
                  </div>
                </div>
              </div>

              {/* Second Row: Location, Pricing, Car Picture */}
              <div className="grid grid-cols-1 gap-6 xl:grid-cols-3">
                {/* Location Information Section */}
                <div className="overflow-hidden rounded-xl border border-slate-200 bg-white">
                  <div className="border-b border-slate-100 bg-white px-5 py-3">
                    <div className="flex items-center space-x-3">
                      <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-brandTint">
                        <IoLocationOutline className="h-4 w-4 text-primary" />
                      </div>
                      <div>
                        <h2 className="text-sm font-semibold text-slate-900">{t('location')}</h2>
                        <p className="text-sm text-slate-500">Service location details</p>
                      </div>
                    </div>
                  </div>
                  <div className="p-6">
                    <div className="space-y-4">
                      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                        <div>
                          <label className="mb-1 block text-xs font-medium uppercase tracking-wide text-slate-500">
                            {t('cityName')}
                          </label>
                          <p className="text-sm font-semibold text-slate-900">
                            {data?.location?.city?.name[lang]}
                          </p>
                        </div>
                        <div>
                          <label className="mb-1 block text-xs font-medium uppercase tracking-wide text-slate-500">
                            {t('area')}
                          </label>
                          <p className="text-sm font-semibold text-slate-900">
                            {data?.location?.subAdministrativeArea}
                          </p>
                        </div>
                      </div>
                      <div>
                        <label className="mb-1 block text-xs font-medium uppercase tracking-wide text-slate-500">
                          {t('streetName')}
                        </label>
                        <p className="text-sm font-semibold text-slate-900">
                          {data?.location?.streetName}
                        </p>
                      </div>
                      {data?.googleMapsLink && (
                        <div className="mt-4 border-t border-slate-200 pt-4">
                          <a
                            href={data?.googleMapsLink}
                            target="_blank"
                            rel="noreferrer"
                            className="inline-flex items-center gap-2 rounded-lg bg-orange-50 px-4 py-2 text-sm font-medium text-orange-700 transition-colors hover:bg-orange-100">
                            <IoLocationOutline className="h-4 w-4" />
                            View on Google Maps
                          </a>
                        </div>
                      )}
                    </div>
                  </div>
                </div>

                {/* Pricing Information Section */}
                <div className="overflow-hidden rounded-xl border border-slate-200 bg-white">
                  <div className="border-b border-slate-100 bg-white px-5 py-3">
                    <div className="flex items-center space-x-3">
                      <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-brandTint">
                        <IoCashOutline className="h-4 w-4 text-primary" />
                      </div>
                      <div>
                        <h2 className="text-sm font-semibold text-slate-900">{t('pricing')}</h2>
                        <p className="text-sm text-slate-500">Order pricing breakdown</p>
                      </div>
                    </div>
                  </div>
                  <div className="p-6">
                    <div className="space-y-4">
                      <div className="rounded-lg bg-slate-50 p-4">
                        <div className="flex justify-between">
                          <span className="text-sm font-medium text-slate-600">
                            {t('total price')}
                          </span>
                          <span className="text-sm font-semibold text-slate-900">
                            {data?.totalPrice}
                          </span>
                        </div>
                      </div>
                      <div className="rounded-lg bg-slate-50 p-4">
                        <div className="flex justify-between">
                          <span className="text-sm font-medium text-slate-600">
                            {data?.isPointsApplied ? t('Points Discount') : t('Discount')}
                          </span>
                          <Badge className="bg-green-100 text-green-700">
                            {data?.isPointsApplied ? data?.pointsDiscount : data?.discount}{' '}
                          </Badge>
                        </div>
                      </div>
                      {data?.promoCode && (
                        <div className="rounded-lg bg-slate-50 p-4">
                          <div className="flex justify-between">
                            <span className="text-sm font-medium capitalize text-slate-600">
                              {t('promo Code')}
                            </span>
                            <Badge className="bg-green-100 text-green-700">
                              {data?.promoCode.code || 'N/A'}
                            </Badge>
                          </div>
                        </div>
                      )}
                      <div className="rounded-lg bg-slate-50 p-4">
                        <div className="flex justify-between">
                          <span className="text-sm font-medium text-slate-600">
                            {t('Payment Type')}
                          </span>
                          <span className="text-sm font-semibold text-slate-900">
                            {data?.paymentType || 'N/A'}
                          </span>
                        </div>
                      </div>
                      <div className="rounded-lg border border-green-200 bg-green-50 p-4">
                        <div className="flex justify-between">
                          <span className="font-semibold text-slate-900">{t('paied price')}</span>
                          <span className="text-xl font-bold text-green-600">{data?.totalPay}</span>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Subscription Information Section */}
                {data?.paymentType === 'SUBSCRIBED' && data?.subscription && (
                  <div className="overflow-hidden rounded-xl border border-slate-200 bg-white">
                    <div
                      className="px-6 py-4"
                      style={{
                        background: `linear-gradient(to right, ${
                          data?.subscription?.plan?.color || '#bb0707'
                        }, ${data?.subscription?.plan?.color || '#bb0707'}dd)`,
                      }}>
                      <div className="flex items-center space-x-3">
                        <div className="flex h-12 w-12 items-center justify-center rounded-full bg-white/20">
                          <IoCheckmarkCircleOutline className="h-6 w-6 text-white" />
                        </div>
                        <div>
                          <h2 className="text-lg font-semibold text-white">{t('subscription')}</h2>
                          <p className="text-sm text-white/80">{t('Subscription plan details')}</p>
                        </div>
                      </div>
                    </div>
                    <div className="p-6">
                      <div className="space-y-4">
                        <div className="rounded-lg bg-slate-50 p-4">
                          <div className="flex justify-between">
                            <span className="text-sm font-medium text-slate-600">
                              {t('Plan Name')}
                            </span>
                            <span className="text-sm font-semibold text-slate-900">
                              {data?.subscription?.plan?.type?.[lang] || 'N/A'}
                            </span>
                          </div>
                        </div>
                        <div className="rounded-lg bg-slate-50 p-4">
                          <div className="flex justify-between">
                            <span className="text-sm font-medium text-slate-600">{t('Price')}</span>
                            <span className="text-sm font-semibold text-slate-900">
                              {data?.subscription?.plan?.price || 'N/A'}
                            </span>
                          </div>
                        </div>
                        <div className="rounded-lg bg-slate-50 p-4">
                          <div className="flex justify-between">
                            <span className="text-sm font-medium text-slate-600">
                              {t('Total Washes')}
                            </span>
                            <span className="text-sm font-semibold text-slate-900">
                              {data?.subscription?.washesCount || 'N/A'}
                            </span>
                          </div>
                        </div>
                        <div className="rounded-lg bg-slate-50 p-4">
                          <div className="flex justify-between">
                            <span className="text-sm font-medium text-slate-600">
                              {t('Remaining Washes')}
                            </span>
                            <span className="text-sm font-semibold text-slate-900">
                              {data?.subscription?.remainingWashes || 'N/A'}
                            </span>
                          </div>
                        </div>
                        {/* washing services list */}
                        <div className="rounded-lg bg-slate-50 p-4">
                          <div className="flex justify-between">
                            <span className="text-sm font-medium text-slate-600">
                              {t('Washing Services')}
                            </span>
                          </div>
                          <div className="flex flex-wrap gap-2">
                            {data?.subscription?.plan?.washingServices?.map((service) => (
                              <Badge key={service._id} className="bg-brandTint text-primary">
                                {service?.name[lang] || service?.name}
                              </Badge>
                            ))}
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                )}

                {/* Car Pictures Section */}
                {(data?.carBeforeWashLink || data?.carAfterWashLink) && (
                  <div className="overflow-hidden rounded-xl border border-slate-200 bg-white">
                    <div className="border-b border-slate-100 bg-white px-5 py-3">
                      <div className="flex items-center space-x-3">
                        <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-brandTint">
                          <IoCarOutline className="h-4 w-4 text-primary" />
                        </div>
                        <div>
                          <h2 className="text-sm font-semibold text-slate-900">{t('carPictures')}</h2>
                          <p className="text-sm text-slate-500">Before and after wash photos</p>
                        </div>
                      </div>
                    </div>
                    <div className="p-6">
                      <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
                        {/* Before Wash Picture */}
                        {data?.carBeforeWashLink && (
                          <div className="space-y-3">
                            <label className="block text-sm font-medium text-slate-700">
                              {t('beforeWash')}
                            </label>
                            <div className="flex justify-center">
                              <ImageModal
                                src={data.carBeforeWashLink}
                                alt="Car before wash"
                                className="h-48 w-full rounded-lg object-cover shadow-md"
                                fallbackText="Before wash image not available"
                              />
                            </div>
                          </div>
                        )}

                        {/* After Wash Picture */}
                        {data?.carAfterWashLink && (
                          <div className="space-y-3">
                            <label className="block text-sm font-medium text-slate-700">
                              {t('afterWash')}
                            </label>
                            <div className="flex justify-center">
                              <ImageModal
                                src={data.carAfterWashLink}
                                alt="Car after wash"
                                className="h-48 w-full rounded-lg object-cover shadow-md"
                                fallbackText="After wash image not available"
                              />
                            </div>
                          </div>
                        )}
                      </div>
                    </div>
                  </div>
                )}
              </div>

              {/* Third Row: Combined Services & Add-ons */}
              <div className="overflow-hidden rounded-xl border border-slate-200 bg-white">
                <div className="border-b border-slate-100 bg-white px-5 py-3">
                  <div className="flex items-center space-x-3">
                    <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-brandTint">
                      <IoCheckmarkCircleOutline className="h-4 w-4 text-primary" />
                    </div>
                    <div>
                      <h2 className="text-sm font-semibold text-slate-900">
                        {t('washingServicesPlan')} & {t('addOns')}
                      </h2>
                      <p className="text-sm text-slate-500">
                        {data?.washingServices?.length || 0} service(s) &{' '}
                        {data?.addOns?.length || 0} add-on(s) selected
                      </p>
                    </div>
                  </div>
                </div>
                <div className="p-6">
                  <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
                    {/* Washing Services Section */}
                    <div>
                      <div className="mb-4 flex items-center gap-2">
                        <IoCheckmarkCircleOutline className="h-5 w-5 text-primary" />
                        <h3 className="text-sm font-semibold text-slate-900">
                          {t('washingServicesPlan')}
                        </h3>
                      </div>
                      <div className="space-y-4">
                        {data?.washingServices?.map((service) => (
                          <div
                            key={service._id}
                            className="rounded-lg border border-slate-200 bg-slate-50 p-4">
                            <div className="mb-3 flex items-center gap-3">
                              <ImageModal
                                src={service?.icon?.iconLink}
                                alt={`${service?.name[lang]} service icon`}
                                className="h-8 w-8 rounded"
                                showExpandIcon={false}
                                fallbackText="Service icon"
                              />
                              <h4 className="text-sm font-semibold text-slate-900">
                                {service?.name[lang]}
                              </h4>
                            </div>
                            <div className="grid grid-cols-1 gap-3 text-sm sm:grid-cols-2">
                              <div>
                                <span className="text-slate-500">{t('durationTime')}:</span>
                                <span className="ml-2 font-medium">{service?.duration} min</span>
                              </div>
                              <div>
                                <span className="text-slate-500">{t('price')}:</span>
                                <span className="ml-2 font-medium text-green-600">
                                  {service?.price}
                                </span>
                              </div>
                            </div>
                            {service?.description && service.description.length > 0 && (
                              <div className="mt-3">
                                <span className="text-sm text-slate-500">{t('description')}:</span>
                                <ul className="mt-1 text-sm text-slate-700">
                                  {service.description.map((desc, index) => (
                                    <li key={index} className="flex items-start gap-2">
                                      <span className="mt-1 text-primary">•</span>
                                      <span>{desc[lang] || desc}</span>
                                    </li>
                                  ))}
                                </ul>
                              </div>
                            )}
                          </div>
                        ))}
                      </div>
                      <div className="mt-6 rounded-lg bg-brandTint p-4">
                        <div className="flex items-center gap-2">
                          <IoTimeOutline className="h-5 w-5 text-primary" />
                          <span className="font-medium text-slate-900">{t('startTime')}:</span>
                          <span className="font-semibold text-primary">
                            {formatDate(data?.startTime)}
                          </span>
                        </div>
                      </div>
                    </div>

                    {/* Add-ons Section */}
                    <div>
                      <div className="mb-4 flex items-center gap-2">
                        <IoInformationCircleOutline className="h-5 w-5 text-purple-600" />
                        <h3 className="text-sm font-semibold text-slate-900">{t('addOns')}</h3>
                      </div>
                      {data?.addOns && data.addOns.length > 0 ? (
                        <div className="space-y-3">
                          {data.addOns.map((addon) => (
                            <div
                              key={addon._id}
                              className="flex items-center justify-between rounded-lg bg-slate-50 p-3">
                              <div className="flex items-center gap-3">
                                <ImageModal
                                  src={addon?.icon?.iconLink}
                                  alt={`${addon?.name} add-on icon`}
                                  className="h-6 w-6 rounded"
                                  showExpandIcon={false}
                                  fallbackText="Add-on icon"
                                />
                                <span className="font-medium text-slate-900">{addon?.name}</span>
                              </div>
                              <span className="font-semibold text-green-600">{addon?.price}</span>
                            </div>
                          ))}
                        </div>
                      ) : (
                        <div className="rounded-lg bg-slate-50 p-4 text-center">
                          <p className="text-sm text-slate-500">No add-ons selected</p>
                        </div>
                      )}
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
      <Sheet open={openSheet} onOpenChange={() => setOpenSheet(false)} modal={true}>
        <SheetContent className="w-full sm:max-w-lg">
          <SheetHeader className="pb-6">
            <SheetTitle className="text-xl">{t('AllBikeAvailable')}</SheetTitle>
            <SheetDescription className="text-gray-600">
              Select a biker to assign to this order
            </SheetDescription>
          </SheetHeader>
          <div className="mt-4">
            {data && (
              <AssignedBikerTable
                areaId={data?.location?.area?._id}
                orderId={orderId}
                setOpenSheet={setOpenSheet}
              />
            )}
          </div>
        </SheetContent>
      </Sheet>
    </div>
  );
}
