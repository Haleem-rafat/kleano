import washingServicesService from '@services/washingServices.service';
import { IwshaingServicesList } from '@servicesTypes/wshaingServices.types';
import { Button, CitiesDialoge, ThreeDotsLoader } from '@UI/Index';
import { useTranslation } from 'react-i18next';
import {
  IoArrowBackCircleOutline,
  IoCarOutline,
  IoDocumentTextOutline,
  IoLocationOutline,
  IoSettingsOutline,
} from 'react-icons/io5';
import { useNavigate, useParams } from 'react-router-dom';
import useSWR from 'swr';
import { FaEdit } from 'react-icons/fa';
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from '@shadecn/components/ui/sheet';
import { useState } from 'react';
import WashingServicesCitiesActionsTable from '../_components/WashingServicesCitiesActions';
import WashingServicesForm from '../_components/WashingServicesForm';

export default function WashingServicesDetails() {
  const [openSheet, setOpenSheet] = useState(false);

  const { washingServicesId } = useParams();
  const navigate = useNavigate();

  const { t, i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';

  const { data, isLoading } = useSWR(
    ['get-washing-services-Details', washingServicesId],
    () =>
      washingServicesId &&
      washingServicesService
        .getWashingServicesDetails(washingServicesId)
        .then((data) => data?.data as IwshaingServicesList)
  );

  return (
    <div className="space-y-1">
      {isLoading && <ThreeDotsLoader />}

      {/* Professional Header */}
      <div className="pb-4">
        <div>
          <div className="flex flex-wrap items-center justify-between gap-3">
            <div className="flex items-center space-x-4">
              <button
                type="button"
                onClick={() => navigate(-1)}
                className="flex h-10 w-10 items-center justify-center rounded-full bg-slate-100 transition-colors duration-200 hover:bg-slate-200">
                <IoArrowBackCircleOutline className="h-5 w-5 text-slate-600" />
              </button>
              <div>
                <h1 className="text-xl font-semibold tracking-tight text-slate-900">
                  {t('washingServicesDetails')}
                </h1>
                <p className="mt-1 text-sm text-slate-500">Service ID: #{data?._id?.slice(-4)}</p>
              </div>
            </div>
            <div className="flex items-center space-x-3">
              <Button onClick={() => setOpenSheet(true)}>{t('editServices')}</Button>
            </div>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="pt-1">
        <div className="w-full">
          <div className="grid grid-cols-1 gap-6 xl:grid-cols-3">
            {/* Service Information Card */}
            <div className="xl:col-span-2">
              <div className="overflow-hidden rounded-xl border border-slate-200 bg-white">
                {/* Gradient Header */}
                <div className="border-b border-slate-100 bg-white px-5 py-3">
                  <div className="flex items-center space-x-3">
                    <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-brandTint">
                      <IoCarOutline className="h-4 w-4 text-primary" />
                    </div>
                    <div>
                      <h2 className="text-sm font-semibold text-slate-900">{t('servicesInfo')}</h2>
                      <p className="text-sm text-slate-500">{t('Service details and pricing')}</p>
                    </div>
                  </div>
                </div>

                {/* Card Content */}
                <div className="p-6">
                  <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                    <div className="rounded-lg bg-slate-50 p-4">
                      <h4 className="mb-2 text-sm font-semibold text-slate-700">
                        {t('servicesIcon')}
                      </h4>
                      <div className="flex justify-center">
                        <img
                          src={data?.icon?.iconLink}
                          alt="Service icon"
                          className="h-16 w-16 rounded-full object-cover"
                        />
                      </div>
                    </div>
                    <div className="rounded-lg bg-slate-50 p-4">
                      <h4 className="mb-2 text-sm font-semibold text-slate-700">
                        {t('servesName')}
                      </h4>
                      <p className="text-lg font-bold text-slate-900">{data?.name?.[lang] || data?.name}</p>
                    </div>
                    <div className="rounded-lg bg-slate-50 p-4">
                      <h4 className="mb-2 text-sm font-semibold text-slate-700">
                        {t('durationTime')}
                      </h4>
                      <p className="text-lg font-bold text-slate-900">{data?.duration} min</p>
                    </div>
                    <div className="rounded-lg bg-slate-50 p-4">
                      <h4 className="mb-2 text-sm font-semibold text-slate-700">{t('price')}</h4>
                      <p className="text-lg font-bold text-slate-900">{data?.price} R.S</p>
                    </div>
                  </div>
                </div>
              </div>

              {/* Description Card */}
              <div className="mt-6 overflow-hidden rounded-xl border border-slate-200 bg-white">
                {/* Gradient Header */}
                <div className="border-b border-slate-100 bg-white px-5 py-3">
                  <div className="flex items-center space-x-3">
                    <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-brandTint">
                      <IoDocumentTextOutline className="h-4 w-4 text-primary" />
                    </div>
                    <div>
                      <h2 className="text-sm font-semibold text-slate-900">
                        {t('servicesDescription')}
                      </h2>
                      <p className="text-sm text-slate-500">{t('Service details and features')}</p>
                    </div>
                  </div>
                </div>

                {/* Card Content */}
                <div className="p-6">
                  <div className="space-y-3">
                    {data?.description?.map((description, index) => (
                      <div
                        key={index}
                        className="rounded-lg border-l-4 border-purple-200 bg-purple-50 p-4">
                        <p className="text-slate-700">
                          {description && typeof description === 'object'
                            ? (description as unknown as Record<string, string>)[lang]
                            : description}
                        </p>
                      </div>
                    ))}
                  </div>
                </div>
              </div>

              {/* Cities Card */}
              <div className="mt-6 overflow-hidden rounded-xl border border-slate-200 bg-white">
                {/* Gradient Header */}
                <div className="border-b border-slate-100 bg-white px-5 py-3">
                  <div className="flex flex-wrap items-center justify-between gap-3">
                    <div className="flex items-center space-x-3">
                      <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-brandTint">
                        <IoLocationOutline className="h-4 w-4 text-primary" />
                      </div>
                      <div>
                        <h2 className="text-sm font-semibold text-slate-900">{t('servicesCities')}</h2>
                        <p className="text-sm text-slate-500">{t('Available service locations')}</p>
                      </div>
                    </div>
                    <CitiesDialoge
                      buttonElement={
                        <Button
                          onClick={(e) => e.stopPropagation()}
                          variant="secondary"
                          size="sm"
                          className="flex gap-x-2 rounded-xl border-2 border-white bg-white p-3 text-orange-600 hover:bg-orange-50">
                          <p className="mt-0.5">{t('edit')}</p>
                          <FaEdit size={16} />
                        </Button>
                      }
                      title={t('servicesCitiesActions')}>
                      <WashingServicesCitiesActionsTable
                        servicesId={data?._id}
                        cityData={data?.cities}
                      />
                    </CitiesDialoge>
                  </div>
                </div>

                {/* Card Content */}
                <div className="p-6">
                  <div className="flex flex-wrap gap-3">
                    {data?.cities?.map((city) => (
                      <div
                        key={city.city._id}
                        className={`rounded-full border-2 px-4 py-2 text-sm font-medium transition-colors duration-200 ${
                          city?.isArchived
                            ? 'border-gray-300 bg-gray-200 text-gray-500'
                            : 'border-orange-200 bg-orange-50 text-orange-700 hover:bg-orange-100'
                        }`}>
                        {city?.city?.name?.[lang]}
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            </div>

            {/* Actions Card */}
            <div className="xl:col-span-1">
              <div className="overflow-hidden rounded-xl border border-slate-200 bg-white">
                {/* Gradient Header */}
                <div className="border-b border-slate-100 bg-white px-5 py-3">
                  <div className="flex items-center space-x-3">
                    <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-brandTint">
                      <IoSettingsOutline className="h-4 w-4 text-primary" />
                    </div>
                    <div>
                      <h2 className="text-sm font-semibold text-slate-900">{t('Service Actions')}</h2>
                      <p className="text-sm text-slate-500">{t('Manage service settings')}</p>
                    </div>
                  </div>
                </div>

                {/* Card Content */}
                <div className="space-y-4 p-6">
                  {/* Edit Service */}
                  <div className="flex items-center justify-between rounded-lg border border-slate-200 p-4 transition-all duration-200 hover:border-primary/30 hover:shadow-indigo-100">
                    <div>
                      <h4 className="text-sm font-semibold text-slate-700">{t('editServices')}</h4>
                      <p className="text-xs text-slate-500">{t('Update service information')}</p>
                    </div>
                    <Button size="sm" onClick={() => setOpenSheet(true)}>
                      {t('edit')}
                    </Button>
                  </div>

                  {/* Manage Cities */}
                  <div className="flex items-center justify-between rounded-lg border border-slate-200 p-4 transition-all duration-200 hover:border-primary/30 hover:shadow-indigo-100">
                    <div>
                      <h4 className="text-sm font-semibold text-slate-700">{t('Manage Cities')}</h4>
                      <p className="text-xs text-slate-500">{t('Add or remove service cities')}</p>
                    </div>
                    <CitiesDialoge
                      buttonElement={
                        <Button
                          onClick={(e) => e.stopPropagation()}
                          variant="secondary"
                          size="sm"
                          className="flex gap-x-2">
                          <FaEdit size={14} />
                          {t('edit')}
                        </Button>
                      }
                      title={t('servicesCitiesActions')}>
                      <WashingServicesCitiesActionsTable
                        servicesId={data?._id}
                        cityData={data?.cities}
                      />
                    </CitiesDialoge>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <Sheet open={openSheet} onOpenChange={() => setOpenSheet(false)} modal={true}>
        <SheetContent>
          <SheetHeader>
            <SheetTitle>{t('editServices')}</SheetTitle>
            <SheetDescription>
              <WashingServicesForm setOpenSheet={setOpenSheet} oldData={data} />
            </SheetDescription>
          </SheetHeader>
        </SheetContent>
      </Sheet>
    </div>
  );
}
