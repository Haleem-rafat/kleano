import { useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';

import { formatDate } from '@app/utils/helper';
import plansService from '@services/plans.service';
import useSWR from 'swr';

import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from '@shadecn/components/ui/sheet';
import { Card, CardContent } from '@shadecn/components/ui/card';
import { Badge } from '@shadecn/components/ui/badge';

import { Button, CitiesDialoge, ThreeDotsLoader } from '@UI/Index';
import { useTranslation } from 'react-i18next';
import { FaEdit } from 'react-icons/fa';
import {
  IoArrowBackCircleOutline,
  IoCalendarOutline,
  IoCashOutline,
  IoLocationOutline,
  IoTimeOutline,
  IoWaterOutline,
} from 'react-icons/io5';
import { RxCountdownTimer } from 'react-icons/rx';

import PlansCitiesActions from '../_Components/PlansCitiesActions';
import PlansModelForm from '../_Components/PlansModelForm';

export default function PlansDetails() {
  const navigate = useNavigate();
  const { plansId } = useParams();

  const [openSheet, setOpenSheet] = useState(false);

  const { t, i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';

  const { data: planDetails, isLoading } = useSWR(
    ['get-all-plans-details', plansId],
    () =>
      plansId &&
      plansService.getAllPlansDetails(plansId).then((data) => {
        return data.data;
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
                <h1 className="text-xl font-semibold tracking-tight text-slate-900">{t('plansDetails')}</h1>
                <div className="mt-1 flex items-center space-x-2">
                  <span className="text-sm text-slate-500">{t('planID')}:</span>
                  <span className="rounded bg-slate-100 px-2 py-1 font-mono text-xs text-slate-700">
                    #{planDetails?._id?.slice(-8)}
                  </span>
                </div>
              </div>
            </div>

            <div className="flex items-center space-x-3">
              <Button onClick={() => setOpenSheet(true)} className="px-4 py-2 text-sm font-medium">
                <FaEdit className="mr-2 h-4 w-4" />
                {t('editPlan')}
              </Button>
            </div>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="p-6">
        <div className="w-full">
          <div className="grid grid-cols-1 gap-6">
            {/* Plan Information Card */}
            <div>
              <Card className="overflow-hidden rounded-xl border-slate-200 shadow-sm">
                <div className="border-b border-slate-100 bg-white px-5 py-3">
                  <div className="flex items-center space-x-3">
                    <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-brandTint">
                      {planDetails?.icon ? (
                        <img
                          src={planDetails.icon.iconLink}
                          alt="Plan icon"
                          className="rounded-full object-contain"
                        />
                      ) : (
                        <IoCalendarOutline className="h-4 w-4 text-primary" />
                      )}
                    </div>
                    <div>
                      <h2 className="text-sm font-semibold text-slate-900">{t('planInfo')}</h2>
                      <p className="text-sm text-slate-500">Plan details and configuration</p>
                    </div>
                  </div>
                </div>
                <CardContent className="p-6">
                  <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
                    {/* Color */}
                    <div className="rounded-lg bg-slate-50 p-4">
                      <h4 className="mb-2 text-sm font-semibold text-slate-700">{t('color')}</h4>
                      <div className="flex items-center space-x-3">
                        <div
                          style={{
                            backgroundColor: `${
                              planDetails?.color?.includes('#')
                                ? planDetails?.color
                                : `#${planDetails?.color}`
                            }`,
                          }}
                          className="h-8 w-8 rounded-full border-2 border-slate-200"
                        />
                        <span className="text-sm text-slate-600">
                          {planDetails?.color?.includes('#')
                            ? planDetails?.color
                            : `#${planDetails?.color}`}
                        </span>
                      </div>
                    </div>

                    {/* Plan Type */}
                    <div className="rounded-lg bg-slate-50 p-4">
                      <h4 className="mb-2 text-sm font-semibold text-slate-700">{t('planType')}</h4>
                      <Badge variant="secondary" className="text-sm">
                        {planDetails?.type?.[lang] || planDetails?.type}
                      </Badge>
                    </div>

                    {/* Duration */}
                    <div className="rounded-lg bg-slate-50 p-4">
                      <h4 className="mb-2 text-sm font-semibold text-slate-700">
                        {t('durationByMonth')}
                      </h4>
                      <div className="flex items-center space-x-2">
                        <IoTimeOutline className="h-4 w-4 text-slate-400" />
                        <span className="text-sm font-semibold text-slate-900">
                          {planDetails?.duration} month{planDetails?.duration > 1 ? 's' : ''}
                        </span>
                      </div>
                    </div>

                    {/* Price */}
                    <div className="rounded-lg bg-slate-50 p-4">
                      <h4 className="mb-2 text-sm font-semibold text-slate-700">{t('price')}</h4>
                      <div className="flex items-center space-x-2">
                        <IoCashOutline className="h-4 w-4 text-slate-400" />
                        <span className="text-sm font-semibold text-slate-900">
                          {planDetails?.price}
                        </span>
                      </div>
                    </div>

                    {/* Created Date */}
                    <div className="rounded-lg bg-slate-50 p-4 ">
                      <h4 className="mb-2 text-sm font-semibold text-slate-700">
                        {t('createddate')}
                      </h4>
                      <div className="flex items-center space-x-2">
                        <IoCalendarOutline className="h-4 w-4 text-slate-400" />
                        <span className="text-sm font-semibold text-slate-900">
                          {formatDate(planDetails?.createdAt)}
                        </span>
                      </div>
                    </div>
                    {/* usage count */}
                    <div className="rounded-lg bg-slate-50 p-4">
                      <h4 className="mb-2 text-sm font-semibold text-slate-700">
                        {t('usageCount')}
                      </h4>
                      <div className="flex items-center space-x-2">
                        <RxCountdownTimer className="h-4 w-4 text-slate-400" />
                        <span className="text-sm font-semibold text-slate-900">
                          {planDetails?.usageCount}
                        </span>
                      </div>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </div>

            {/* Washing Services Card */}
            <div>
              <Card className="overflow-hidden rounded-xl border-slate-200 shadow-sm">
                <div className="border-b border-slate-100 bg-white px-5 py-3">
                  <div className="flex items-center space-x-3">
                    <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-brandTint">
                      <IoWaterOutline className="h-4 w-4 text-primary" />
                    </div>
                    <div>
                      <h2 className="text-sm font-semibold text-slate-900">
                        {t('washingServicesPlan')}
                      </h2>
                      <p className="text-sm text-slate-500">Included services</p>
                    </div>
                  </div>
                </div>
                <CardContent className="p-6">
                  {planDetails?.washingServices?.length > 0 ? (
                    <div className="flex flex-wrap gap-3">
                      {planDetails.washingServices.map((service) => (
                        <Badge
                          key={service._id}
                          variant="default"
                          className="bg-green-100 px-4 py-2 text-sm text-green-800 hover:bg-green-200">
                          <IoWaterOutline className="mr-2 h-4 w-4" />
                          {service.name?.[lang] || service.name}
                        </Badge>
                      ))}
                    </div>
                  ) : (
                    <div className="py-8 text-center">
                      <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-slate-100">
                        <IoWaterOutline className="h-8 w-8 text-slate-400" />
                      </div>
                      <h3 className="mb-1 text-lg font-medium text-slate-900">No Services</h3>
                      <p className="text-slate-500">No washing services assigned to this plan</p>
                    </div>
                  )}
                </CardContent>
              </Card>
            </div>

            {/* Plan Description Card */}
            <div>
              <Card className="overflow-hidden rounded-xl border-slate-200 shadow-sm">
                <div className="border-b border-slate-100 bg-white px-5 py-3">
                  <div className="flex items-center space-x-3">
                    <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-brandTint">
                      <IoCalendarOutline className="h-4 w-4 text-primary" />
                    </div>
                    <div>
                      <h2 className="text-sm font-semibold text-slate-900">Plan Description</h2>
                      <p className="text-sm text-slate-500">Plan features and details</p>
                    </div>
                  </div>
                </div>
                <CardContent className="p-6">
                  {planDetails?.description?.length > 0 ? (
                    <div className="flex flex-wrap gap-3">
                      {planDetails.description.map((desc, index) => (
                        <Badge
                          key={index}
                          variant="default"
                          className="bg-purple-100 px-4 py-2 text-sm text-purple-800 hover:bg-purple-200">
                          <span className="mr-2 text-xs font-semibold">{index + 1}</span>
                          {typeof desc === 'object'
                            ? desc?.[lang] || desc?.en || desc?.ar
                            : desc}
                        </Badge>
                      ))}
                    </div>
                  ) : (
                    <div className="py-8 text-center">
                      <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-slate-100">
                        <IoCalendarOutline className="h-8 w-8 text-slate-400" />
                      </div>
                      <h3 className="mb-1 text-lg font-medium text-slate-900">No Description</h3>
                      <p className="text-slate-500">No description available for this plan</p>
                    </div>
                  )}
                </CardContent>
              </Card>
            </div>

            {/* Cities Card */}
            <div>
              <Card className="overflow-hidden rounded-xl border-slate-200 shadow-sm">
                <div className="border-b border-slate-100 bg-white px-5 py-3">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center space-x-3">
                      <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-brandTint">
                        <IoLocationOutline className="h-4 w-4 text-primary" />
                      </div>
                      <div>
                        <h2 className="text-sm font-semibold text-slate-900">{t('planCities')}</h2>
                        <p className="text-sm text-slate-500">Available locations</p>
                      </div>
                    </div>
                    <CitiesDialoge
                      buttonElement={
                        <Button
                          onClick={(e) => e.stopPropagation()}
                          variant="secondary"
                          size="sm"
                          className="flex items-center gap-2 bg-brandTint text-slate-900 hover:bg-white/30">
                          <FaEdit className="h-4 w-4" />
                          {t('edit')}
                        </Button>
                      }
                      title={t('servicesCitiesActions')}>
                      <PlansCitiesActions
                        servicesId={planDetails?._id}
                        cityData={planDetails?.cities}
                      />
                    </CitiesDialoge>
                  </div>
                </div>
                <CardContent className="p-6">
                  {planDetails?.cities?.length > 0 ? (
                    <div className="flex flex-wrap gap-3">
                      {planDetails.cities.map((city) => (
                        <Badge
                          key={city._id || city.city?.name?.[lang]}
                          variant={city?.isArchived ? 'secondary' : 'default'}
                          className={`px-4 py-2 text-sm ${
                            city?.isArchived
                              ? 'bg-slate-200 text-slate-500'
                              : 'bg-orange-100 text-orange-800 hover:bg-orange-200'
                          }`}>
                          {city?.city?.name?.[lang]}
                        </Badge>
                      ))}
                    </div>
                  ) : (
                    <div className="py-8 text-center">
                      <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-slate-100">
                        <IoLocationOutline className="h-8 w-8 text-slate-400" />
                      </div>
                      <h3 className="mb-1 text-lg font-medium text-slate-900">No Cities</h3>
                      <p className="text-slate-500">No cities assigned to this plan</p>
                    </div>
                  )}
                </CardContent>
              </Card>
            </div>
          </div>
        </div>
      </div>

      {/* Edit Plan Sheet */}
      <Sheet open={openSheet} onOpenChange={() => setOpenSheet(false)} modal={true}>
        <SheetContent>
          <SheetHeader>
            <SheetTitle>{t('editPlan')}</SheetTitle>
            <SheetDescription>
              {planDetails && <PlansModelForm setOpenSheet={setOpenSheet} oldData={planDetails} />}
            </SheetDescription>
          </SheetHeader>
        </SheetContent>
      </Sheet>
    </div>
  );
}
