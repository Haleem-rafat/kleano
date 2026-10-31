import { formatDate } from '@app/utils/helper';
import usersService from '@services/users.service';
import { IRootUser } from '@servicesTypes/user.types';
import { Button, ThreeDotsLoader, ImageModal, AdminStatus } from '@UI/Index';
import React, { useState, useMemo } from 'react';
import { useTranslation } from 'react-i18next';
import {
  IoArrowBackCircleOutline,
  IoPersonOutline,
  IoCarOutline,
  IoReceiptOutline,
  IoStatsChartOutline,
  IoCashOutline,
  IoTimeOutline,
  IoTrendingUpOutline,
  IoLocationOutline,
  IoCheckmarkCircleOutline,
  IoCloseCircleOutline,
  IoHourglassOutline,
  IoCarSportOutline,
  IoFilterOutline,
  IoSearchOutline,
  IoRefreshOutline,
  IoAddOutline,
} from 'react-icons/io5';
import { useNavigate, useParams } from 'react-router-dom';
import { toast } from 'react-toastify';
import useSWR from 'swr';
import { ROUTES } from '@constants/routes';
import { Blocks, Percent } from 'lucide-react';

// Helper function to get status styling
const getStatusConfig = (status) => {
  const statusConfigs = {
    WAITING_FOR_BIKER_BY_ADMIN: {
      color: 'orange',
      icon: IoHourglassOutline,
      bgColor: 'bg-orange-50',
      textColor: 'text-orange-700',
      borderColor: 'border-orange-200',
    },
    ACCEPTED_BY_BIKER: {
      color: 'blue',
      icon: IoCheckmarkCircleOutline,
      bgColor: 'bg-brandTint',
      textColor: 'text-primary',
      borderColor: 'border-primary/30',
    },
    BIKER_ON_THE_WAY: {
      color: 'purple',
      icon: IoCarSportOutline,
      bgColor: 'bg-purple-50',
      textColor: 'text-purple-700',
      borderColor: 'border-purple-200',
    },
    BIKER_ARRIVED: {
      color: 'indigo',
      icon: IoLocationOutline,
      bgColor: 'bg-brandTint',
      textColor: 'text-primary',
      borderColor: 'border-primary/30',
    },
    ON_WASHING: {
      color: 'yellow',
      icon: IoTimeOutline,
      bgColor: 'bg-yellow-50',
      textColor: 'text-yellow-700',
      borderColor: 'border-yellow-200',
    },
    COMPLETED: {
      color: 'green',
      icon: IoCheckmarkCircleOutline,
      bgColor: 'bg-green-50',
      textColor: 'text-green-700',
      borderColor: 'border-green-200',
    },
    CANCELLED_BY_USER: {
      color: 'red',
      icon: IoCloseCircleOutline,
      bgColor: 'bg-red-50',
      textColor: 'text-red-700',
      borderColor: 'border-red-200',
    },
    CANCELLED_BY_ADMIN: {
      color: 'red',
      icon: IoCloseCircleOutline,
      bgColor: 'bg-red-50',
      textColor: 'text-red-700',
      borderColor: 'border-red-200',
    },
  };

  return (
    statusConfigs[status] || {
      color: 'gray',
      icon: IoReceiptOutline,
      bgColor: 'bg-gray-50',
      textColor: 'text-gray-700',
      borderColor: 'border-gray-200',
    }
  );
};

export default function UsersDetails() {
  const navigate = useNavigate();
  const { userId } = useParams();
  const [loading, setLoading] = useState(false);
  const { i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';

  // Filter states
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [paymentTypeFilter, setPaymentTypeFilter] = useState('all');
  const [dateRangeFilter, setDateRangeFilter] = useState('all');
  const [showFilters, setShowFilters] = useState(false);

  const { t } = useTranslation();

  const {
    data: userDetails,
    isLoading,
    mutate,
  } = useSWR(
    ['get-user-details', userId],
    () =>
      userId &&
      usersService.getUsersDetails(userId).then((data) => {
        return data as IRootUser[];
      })
  );

  const user = userDetails?.[0] as IRootUser;

  // Filter orders based on current filter states
  const filteredOrders = useMemo(() => {
    if (!user?.orders) return [];

    return user.orders.filter((order) => {
      // Search filter
      if (searchTerm) {
        const searchLower = searchTerm.toLowerCase();
        const matchesSearch =
          order._id.toLowerCase().includes(searchLower) ||
          order.vehicle?.brand?.toLowerCase().includes(searchLower) ||
          order.vehicle?.model?.toLowerCase().includes(searchLower) ||
          order.type?.toLowerCase().includes(searchLower) ||
          order.paymentType?.toLowerCase().includes(searchLower);

        if (!matchesSearch) return false;
      }

      // Status filter
      if (statusFilter !== 'all' && order.status !== statusFilter) {
        return false;
      }

      // Payment type filter
      if (paymentTypeFilter !== 'all' && order.paymentType !== paymentTypeFilter) {
        return false;
      }

      // Date range filter
      if (dateRangeFilter !== 'all') {
        const orderDate = new Date(order.createdAt);
        const now = new Date();

        switch (dateRangeFilter) {
          case 'today': {
            const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
            if (orderDate < today) return false;
            break;
          }
          case 'week': {
            const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
            if (orderDate < weekAgo) return false;
            break;
          }
          case 'month': {
            const monthAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
            if (orderDate < monthAgo) return false;
            break;
          }
          case 'year': {
            const yearAgo = new Date(now.getTime() - 365 * 24 * 60 * 60 * 1000);
            if (orderDate < yearAgo) return false;
            break;
          }
          default:
            break;
        }
      }

      return true;
    });
  }, [user?.orders, searchTerm, statusFilter, paymentTypeFilter, dateRangeFilter]);

  // Get unique values for filter options
  const uniquePaymentTypes = useMemo(() => {
    if (!user?.orders) return [];
    return [...new Set(user.orders.map((order) => order.paymentType).filter(Boolean))];
  }, [user?.orders]);

  const handleChangeStatus = async (id, status) => {
    setLoading(true);
    await usersService
      .toggleUserStatus(id, status)
      .then(() => {
        toast.success('User status changed successfully');
        mutate();
        setLoading(false);
      })
      .catch((e) => {
        setLoading(false);

        toast.error(e.response.data.localizedMessage.en);
      });
  };
  if (isLoading || loading) return <ThreeDotsLoader />;

  return (
    <div className="min-h-screen bg-slate-50">
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
                <h1 className="text-xl font-semibold tracking-tight text-slate-900">{t('userDetails')}</h1>
                <div className="mt-1 flex items-center space-x-2">
                  <span className="text-sm text-slate-500">{t('userId')}:</span>
                  <span className="rounded bg-slate-100 px-2 py-1 font-mono text-xs text-slate-700">
                    #{user?.serialNumber}
                  </span>
                </div>
              </div>
            </div>

            <div className="flex items-center space-x-3">
              <Button
                variant={user?.isSuspended ? 'danger' : 'primary'}
                onClick={() =>
                  handleChangeStatus(user._id, user.isSuspended ? 'unsuspend' : 'suspend')
                }
                className="px-4 py-2 text-sm font-medium">
                {user?.isSuspended ? t('unsuspend') : t('suspend')}
              </Button>
            </div>
          </div>
        </div>
      </div>

      {/* Main Dashboard Content */}
      <div className="p-6">
        {user && (
          <div className="w-full">
            <div className="mb-5 grid grid-cols-1 gap-6 xl:grid-cols-3">
              {/* User Profile Section */}
              <div className="colspa overflow-hidden rounded-xl border border-slate-200 bg-white">
                <div className="border-b border-slate-100 bg-white px-5 py-3">
                  <div className="flex items-center space-x-3">
                    <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-brandTint">
                      <IoPersonOutline className="h-4 w-4 text-primary" />
                    </div>
                    <div>
                      <h2 className="text-sm font-semibold text-slate-900">{t('userInfo')}</h2>
                      <p className="text-sm text-slate-500">User profile information</p>
                    </div>
                  </div>
                </div>
                <div className="p-6">
                  <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
                    <div className="space-y-4">
                      <div>
                        <label className="mb-1 block text-xs font-medium uppercase tracking-wide text-slate-500">
                          {t('name')}
                        </label>
                        <p className="text-sm font-semibold text-slate-900">{user.userName}</p>
                      </div>
                      <div>
                        <label className="mb-1 block text-xs font-medium uppercase tracking-wide text-slate-500">
                          {t('phone')}
                        </label>
                        <p className="text-sm font-semibold text-slate-900">{user.phone}</p>
                      </div>
                    </div>
                    <div className="space-y-4">
                      <div>
                        <label className="mb-1 block text-xs font-medium uppercase tracking-wide text-slate-500">
                          {t('walletBalance')}
                        </label>
                        <p className="font-mono text-2xl font-bold text-green-600">
                          {user.walletBalance.toFixed(2)}
                        </p>
                      </div>
                      <div>
                        <label className="mb-1 block text-xs font-medium uppercase tracking-wide text-slate-500">
                          {t('createddate')}
                        </label>
                        <p className="text-sm font-semibold text-slate-900">
                          {formatDate(user.createdAt)}
                        </p>
                      </div>
                    </div>
                  </div>

                  <div className="mt-6 border-t border-slate-200 pt-6">
                    <label className="mb-3 block text-xs font-medium uppercase tracking-wide text-slate-500">
                      {t('plans')}
                    </label>
                    <div className="flex flex-wrap gap-2">
                      {user.plans.map((plan, index) => (
                        <span
                          key={index}
                          className="inline-flex items-center rounded-full border border-primary/30 bg-brandTint px-3 py-1 text-sm font-medium text-primary">
                          {typeof plan.plan?.type === 'string'
                            ? plan.plan?.type
                            : plan.plan?.type[lang] || '--'}
                        </span>
                      ))}
                    </div>
                  </div>
                </div>
              </div>

              {/* Vehicles Section */}
              <div className="overflow-hidden rounded-xl border border-slate-200 bg-white">
                <div className="border-b border-slate-100 bg-white px-5 py-3">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center space-x-3">
                      <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-brandTint">
                        <IoCarOutline className="h-4 w-4 text-primary" />
                      </div>
                      <div>
                        <h2 className="text-sm font-semibold text-slate-900">{t('vehicles')}</h2>
                        <p className="text-sm text-slate-500">
                          {user.vehicles.length} vehicle(s) registered
                        </p>
                      </div>
                    </div>
                  </div>
                </div>
                <div className="p-6">
                  <div className="space-y-4">
                    {user.vehicles.map((vehicle, index) => (
                      <div
                        key={vehicle._id}
                        className="rounded-lg border border-slate-200 bg-slate-50 p-4">
                        <div className="flex items-start justify-between">
                          <div className="flex-1">
                            <div className="mb-4 grid grid-cols-2 gap-4">
                              <div>
                                <label className="mb-1 block text-xs font-medium uppercase tracking-wide text-slate-500">
                                  {t('brand')}
                                </label>
                                <p className="text-sm font-semibold text-slate-900">
                                  {vehicle.brand}
                                </p>
                              </div>
                              <div>
                                <label className="mb-1 block text-xs font-medium uppercase tracking-wide text-slate-500">
                                  {t('model')}
                                </label>
                                <p className="text-sm font-semibold text-slate-900">
                                  {vehicle.model}
                                </p>
                              </div>
                              <div>
                                <label className="mb-1 block text-xs font-medium uppercase tracking-wide text-slate-500">
                                  {t('plateNumber')}
                                </label>
                                <p className="font-mono text-sm font-semibold text-slate-900">
                                  {vehicle.plateNumber}
                                </p>
                              </div>
                              <div>
                                <label className="mb-1 block text-xs font-medium uppercase tracking-wide text-slate-500">
                                  {t('color')}
                                </label>
                                <p className="text-sm font-semibold text-slate-900">
                                  {vehicle.color}
                                </p>
                              </div>
                            </div>
                          </div>
                          {vehicle.imageLink && (
                            <div className="ml-4">
                              <ImageModal
                                src={vehicle.imageLink}
                                alt={`${vehicle.brand} vehicle image`}
                                className="h-16 w-16 rounded-lg"
                                fallbackText="No image"
                              />
                            </div>
                          )}
                        </div>
                        {index !== user.vehicles.length - 1 && (
                          <div className="mt-4 border-t border-slate-200"></div>
                        )}
                      </div>
                    ))}
                  </div>
                </div>
              </div>

              {/* Order Statistics Section */}
              <div className="overflow-hidden rounded-xl border border-slate-200 bg-white">
                <div className="border-b border-slate-100 bg-white px-5 py-3">
                  <div className="flex items-center space-x-3">
                    <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-brandTint">
                      <IoStatsChartOutline className="h-4 w-4 text-primary" />
                    </div>
                    <div>
                      <h2 className="text-sm font-semibold text-slate-900">Order Statistics</h2>
                      <p className="text-sm text-slate-500">Overall order performance metrics</p>
                    </div>
                  </div>
                </div>
                <div className="p-6">
                  <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 ">
                    {/* Total Orders */}
                    <div className="text-center">
                      <div className="mx-auto mb-3 flex h-8 w-8 items-center justify-center rounded-lg bg-brandTint">
                        <IoReceiptOutline className="h-4 w-4 text-primary" />
                      </div>
                      <p className="text-2xl font-bold text-slate-900">{user.ordersCount}</p>
                      <p className="text-sm text-slate-500">Total Orders</p>
                    </div>

                    {/* Total Spent */}
                    <div className="text-center">
                      <div className="mx-auto mb-3 flex h-12 w-12 items-center justify-center rounded-full bg-green-100">
                        <IoCashOutline className="h-6 w-6 text-green-600" />
                      </div>
                      <p className="text-2xl font-bold text-slate-900">{user.totalOrdersPrice}</p>
                      <p className="text-sm text-slate-500">Total Spent</p>
                    </div>
                    {/* Average Order Value */}
                    <div className="text-center">
                      <div className="mx-auto mb-3 flex h-12 w-12 items-center justify-center rounded-full bg-purple-100">
                        <IoTrendingUpOutline className="h-6 w-6 text-purple-600" />
                      </div>
                      <p className="text-2xl font-bold text-slate-900">
                        {user.orders.length > 0
                          ? (
                              user.orders.reduce(
                                (total, order) => total + (parseFloat(`${order.totalPay}`) || 0),
                                0
                              ) / user.orders.length
                            ).toFixed(2)
                          : '0.00'}
                      </p>
                      <p className="text-sm text-slate-500">Avg Order Value</p>
                    </div>
                    {/* Add ons count */}

                    <div className="text-center">
                      <div className="mx-auto mb-3 flex h-12 w-12 items-center justify-center rounded-full bg-purple-100">
                        <Blocks size={24} color="#6b7280" />
                      </div>
                      <p className="text-2xl font-bold text-slate-900">{user.addOnsCount}</p>
                      <p className="text-sm text-slate-500">Add ons Count</p>
                    </div>
                    {/* toal add ons price */}
                    <div className="text-center">
                      <div className="mx-auto mb-3 flex h-12 w-12 items-center justify-center rounded-full bg-purple-100">
                        <IoAddOutline className="h-6 w-6 text-purple-600" />
                      </div>
                      <p className="text-2xl font-bold text-slate-900">{user.totalAddOnsPrice}</p>
                      <p className="text-sm text-slate-500">Total Add ons Price</p>
                    </div>
                    <div className="text-center">
                      <div className="mx-auto mb-3 flex h-12 w-12 items-center justify-center rounded-full bg-purple-100">
                        <Percent className="h-6 w-6 text-purple-600" />
                      </div>
                      <p className="text-2xl font-bold text-slate-900">
                        {' '}
                        {user.orders
                          .reduce(
                            (total, order) => total + (parseFloat(`${order.discount}`) || 0),
                            0
                          )
                          .toFixed(2)}
                      </p>
                      <p className="text-sm text-slate-500">Total Discounts</p>
                    </div>
                  </div>

                  {/* Additional Stats Row */}
                  <div className="mt-6 grid grid-cols-1 gap-4 sm:grid-cols-2">
                    {/* Most Common Vehicle */}
                    <div className="rounded-lg bg-slate-50 p-4">
                      <h4 className="mb-2 text-sm font-semibold text-slate-700">
                        Most Used Vehicle
                      </h4>
                      <p className="text-lg font-bold text-slate-900">
                        {(() => {
                          if (user.orders.length === 0) return 'N/A';
                          const brandCounts = user.orders.reduce((acc, order) => {
                            const brand = order?.vehicle?.brand || 'Unknown';
                            acc[brand] = (acc[brand] || 0) + 1;
                            return acc;
                          }, {} as Record<string, number>);
                          const sortedBrands = Object.entries(brandCounts).sort(
                            ([, a], [, b]) => b - a
                          );
                          return sortedBrands[0]?.[0] || 'N/A';
                        })()}
                      </p>
                    </div>

                    {/* Payment Method Distribution */}
                    <div className="rounded-lg bg-slate-50 p-4">
                      <h4 className="mb-2 text-sm font-semibold text-slate-700">
                        Preferred Payment
                      </h4>
                      <p className="text-lg font-bold text-slate-900">
                        {(() => {
                          if (user.orders.length === 0) return 'N/A';
                          const methodCounts = user.orders.reduce((acc, order) => {
                            const method = order.paymentType || 'Unknown';
                            acc[method] = (acc[method] || 0) + 1;
                            return acc;
                          }, {} as Record<string, number>);
                          const sortedMethods = Object.entries(methodCounts).sort(
                            ([, a], [, b]) => b - a
                          );
                          return sortedMethods[0]?.[0] || 'N/A';
                        })()}
                      </p>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            {/* Orders Section */}
            <div className="xl:col-span-2">
              <div className="overflow-hidden rounded-xl border border-slate-200 bg-white">
                <div className="border-b border-slate-100 bg-white px-5 py-3">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center space-x-3">
                      <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-brandTint">
                        <IoReceiptOutline className="h-4 w-4 text-primary" />
                      </div>
                      <div>
                        <h2 className="text-sm font-semibold text-slate-900">{t('orders')}</h2>
                        <p className="text-sm text-slate-500">
                          {user.orders.length} order(s) placed
                        </p>
                      </div>
                    </div>
                  </div>
                </div>
                <div className="p-6">
                  {/* Filter Controls */}
                  <div className="mb-6 space-y-4">
                    {/* Filter Toggle and Search */}
                    <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
                      <div className="flex items-center gap-3">
                        <button
                          type="button"
                          onClick={() => setShowFilters(!showFilters)}
                          className="flex items-center gap-2 rounded-lg border border-slate-300 bg-white px-4 py-2 text-sm font-medium text-slate-700 transition-colors hover:bg-slate-50">
                          <IoFilterOutline className="h-4 w-4" />
                          Filters
                          {(statusFilter !== 'all' ||
                            paymentTypeFilter !== 'all' ||
                            dateRangeFilter !== 'all' ||
                            searchTerm) && (
                            <span className="ml-1 rounded-full bg-brandTint px-2 py-0.5 text-xs text-primary">
                              {
                                [
                                  statusFilter !== 'all',
                                  paymentTypeFilter !== 'all',
                                  dateRangeFilter !== 'all',
                                  searchTerm,
                                ].filter(Boolean).length
                              }
                            </span>
                          )}
                        </button>

                        <button
                          type="button"
                          onClick={() => {
                            setSearchTerm('');
                            setStatusFilter('all');
                            setPaymentTypeFilter('all');
                            setDateRangeFilter('all');
                          }}
                          className="flex items-center gap-2 rounded-lg border border-slate-300 bg-white px-4 py-2 text-sm font-medium text-slate-700 transition-colors hover:bg-slate-50">
                          <IoRefreshOutline className="h-4 w-4" />
                          Clear All
                        </button>
                      </div>

                      {/* Search Input */}
                      <div className="relative max-w-md flex-1">
                        <IoSearchOutline className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />
                        <input
                          type="text"
                          placeholder="Search orders..."
                          value={searchTerm}
                          onChange={(e) => setSearchTerm(e.target.value)}
                          className="w-full rounded-lg border border-slate-300 bg-white py-2 pl-10 pr-4 text-sm placeholder-slate-500 focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary/40"
                        />
                      </div>
                    </div>

                    {/* Advanced Filters */}
                    {showFilters && (
                      <div className="rounded-lg border border-slate-200 bg-slate-50 p-4">
                        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
                          {/* Status Filter */}
                          <div>
                            <label className="mb-2 block text-sm font-medium text-slate-700">
                              Status
                            </label>
                            <select
                              value={statusFilter}
                              onChange={(e) => setStatusFilter(e.target.value)}
                              className="w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary/40">
                              <option value="all">All Statuses</option>
                              <option value="WAITING_FOR_BIKER_BY_ADMIN">Waiting for Biker</option>
                              <option value="ACCEPTED_BY_BIKER">Accepted by Biker</option>
                              <option value="BIKER_ON_THE_WAY">Biker on the Way</option>
                              <option value="BIKER_ARRIVED">Biker Arrived</option>
                              <option value="ON_WASHING">On Washing</option>
                              <option value="COMPLETED">Completed</option>
                              <option value="CANCELLED_BY_USER">Cancelled by User</option>
                              <option value="CANCELLED_BY_ADMIN">Cancelled by Admin</option>
                            </select>
                          </div>

                          {/* Payment Type Filter */}
                          <div>
                            <label className="mb-2 block text-sm font-medium text-slate-700">
                              Payment Type
                            </label>
                            <select
                              value={paymentTypeFilter}
                              onChange={(e) => setPaymentTypeFilter(e.target.value)}
                              className="w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary/40">
                              <option value="all">All Payment Types</option>
                              {uniquePaymentTypes.map((type) => (
                                <option key={type} value={type}>
                                  {type}
                                </option>
                              ))}
                            </select>
                          </div>

                          {/* Date Range Filter */}
                          <div>
                            <label className="mb-2 block text-sm font-medium text-slate-700">
                              Date Range
                            </label>
                            <select
                              value={dateRangeFilter}
                              onChange={(e) => setDateRangeFilter(e.target.value)}
                              className="w-full rounded-lg border border-slate-300 bg-white px-3 py-2 text-sm focus:border-primary focus:outline-none focus:ring-1 focus:ring-primary/40">
                              <option value="all">All Time</option>
                              <option value="today">Today</option>
                              <option value="week">Last 7 Days</option>
                              <option value="month">Last 30 Days</option>
                              <option value="year">Last Year</option>
                            </select>
                          </div>

                          {/* Results Count */}
                          <div className="flex items-end">
                            <div className="rounded-lg bg-white px-3 py-2 text-sm text-slate-600">
                              <span className="font-medium text-slate-900">
                                {filteredOrders.length}
                              </span>{' '}
                              of {user.orders.length} orders
                            </div>
                          </div>
                        </div>
                      </div>
                    )}
                  </div>

                  {/* Orders List */}
                  {filteredOrders.length > 0 ? (
                    <div className="max-h-[699px] space-y-4 overflow-y-scroll px-3">
                      {filteredOrders.map((order) => {
                        const statusConfig = getStatusConfig(order.status);
                        const StatusIcon = statusConfig.icon;

                        return (
                          <div
                            key={order._id}
                            onClick={() =>
                              navigate(ROUTES.ORDER_DETAILS.replace(':orderId', order._id))
                            }
                            className={`group cursor-pointer overflow-hidden rounded-xl border-2 ${statusConfig.borderColor} bg-white p-6 shadow-sm transition-all duration-300 hover:shadow-lg hover:shadow-${statusConfig.color}-100 hover:scale-[1.02]`}>
                            {/* Header Section */}
                            <div className="mb-4 flex items-start justify-between">
                              <div className="flex items-center space-x-4">
                                <div
                                  className={`flex h-12 w-12 items-center justify-center rounded-full ${statusConfig.bgColor}`}>
                                  <StatusIcon className={`h-6 w-6 ${statusConfig.textColor}`} />
                                </div>
                                <div>
                                  <h3 className="text-lg font-bold text-slate-900">
                                    Order #{order._id.slice(-8).toUpperCase()}
                                  </h3>
                                  <p className="text-sm text-slate-500">
                                    Created on {formatDate(order.createdAt)}
                                  </p>
                                </div>
                              </div>

                              {/* Status Badge */}
                              <div
                                className={`inline-flex items-center rounded-full px-3 py-1 text-xs font-medium ${statusConfig.bgColor} ${statusConfig.textColor}`}>
                                <StatusIcon className="mr-1 h-3 w-3" />
                                <AdminStatus status={order.status} />
                              </div>
                            </div>

                            {/* Main Content Grid */}
                            <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
                              {/* Vehicle Information */}
                              <div className="space-y-3">
                                <h4 className="text-sm font-semibold uppercase tracking-wide text-slate-700">
                                  Vehicle
                                </h4>
                                <div className="space-y-2">
                                  <div className="flex items-center space-x-2">
                                    <IoCarOutline className="h-4 w-4 text-slate-400" />
                                    <span className="text-sm text-slate-600">
                                      {order.vehicle?.brand} {order.vehicle?.model}
                                    </span>
                                  </div>
                                  <div className="flex items-center space-x-2">
                                    <IoLocationOutline className="h-4 w-4 text-slate-400" />
                                    <span className="text-sm text-slate-600">
                                      {order.location?.city || 'N/A'}
                                    </span>
                                  </div>
                                </div>
                              </div>

                              {/* Services Information */}
                              <div className="space-y-3">
                                <h4 className="text-sm font-semibold uppercase tracking-wide text-slate-700">
                                  Services
                                </h4>
                                <div className="space-y-2">
                                  <div className="flex items-center space-x-2">
                                    <IoTimeOutline className="h-4 w-4 text-slate-400" />
                                    <span className="text-sm text-slate-600">
                                      {order.washingServices?.length || 0} service(s)
                                    </span>
                                  </div>
                                  <div className="flex items-center space-x-2">
                                    <IoReceiptOutline className="h-4 w-4 text-slate-400" />
                                    <span className="text-sm text-slate-600">
                                      {order.type || 'Standard'}
                                    </span>
                                  </div>
                                </div>
                              </div>

                              {/* Pricing Information */}
                              <div className="space-y-3">
                                <h4 className="text-sm font-semibold uppercase tracking-wide text-slate-700">
                                  Pricing
                                </h4>
                                <div className="space-y-2">
                                  <div className="flex items-center justify-between">
                                    <span className="text-sm text-slate-500">Total Price</span>
                                    <span className="text-sm font-semibold text-slate-900">
                                      {order.totalPrice}
                                    </span>
                                  </div>
                                  <div className="flex items-center justify-between">
                                    <span className="text-sm text-slate-500">Discount</span>
                                    <span className="text-sm font-semibold text-green-600">
                                      -{order.discount}
                                    </span>
                                  </div>
                                  <div className="flex items-center justify-between border-t border-slate-200 pt-2">
                                    <span className="text-sm font-semibold text-slate-700">
                                      Amount Paid
                                    </span>
                                    <span className="text-lg font-bold text-green-600">
                                      {order.totalPay}
                                    </span>
                                  </div>
                                </div>
                              </div>
                            </div>

                            {/* Additional Information */}
                            <div className="mt-4 flex items-center justify-between rounded-lg bg-slate-50 p-4">
                              <div className="flex items-center space-x-6">
                                <div className="flex items-center space-x-2">
                                  <IoCashOutline className="h-4 w-4 text-slate-400" />
                                  <span className="text-sm text-slate-600">
                                    {order.paymentType || 'N/A'}
                                  </span>
                                </div>
                                <div className="flex items-center space-x-2">
                                  <IoTimeOutline className="h-4 w-4 text-slate-400" />
                                  <span className="text-sm text-slate-600">
                                    {order.startTime
                                      ? formatDate(order.startTime)
                                      : 'Not scheduled'}
                                  </span>
                                </div>
                              </div>

                              {order.addOns && order.addOns.length > 0 && (
                                <div className="flex items-center space-x-2">
                                  <span className="text-xs text-slate-500">Add-ons:</span>
                                  <span className="text-sm font-medium text-slate-700">
                                    {order.addOns.length}
                                  </span>
                                </div>
                              )}
                            </div>

                            {/* Hover Effect Indicator */}
                            <div
                              className={`mt-4 h-1 w-0 rounded-full bg-gradient-to-r from-${statusConfig.color}-500 to-${statusConfig.color}-600 transition-all duration-300 group-hover:w-full`}></div>
                          </div>
                        );
                      })}
                    </div>
                  ) : user.orders.length === 0 ? (
                    <div className="py-12 text-center">
                      <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-slate-100">
                        <IoReceiptOutline className="h-8 w-8 text-slate-400" />
                      </div>
                      <h3 className="mb-1 text-lg font-medium text-slate-900">No orders found</h3>
                      <p className="text-slate-500">This user hasn&apos;t placed any orders yet.</p>
                    </div>
                  ) : (
                    <div className="py-12 text-center">
                      <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-slate-100">
                        <IoSearchOutline className="h-8 w-8 text-slate-400" />
                      </div>
                      <h3 className="mb-1 text-lg font-medium text-slate-900">
                        No orders match your filters
                      </h3>
                      <p className="text-slate-500">
                        Try adjusting your search criteria or clear the filters.
                      </p>
                      <button
                        type="button"
                        onClick={() => {
                          setSearchTerm('');
                          setStatusFilter('all');
                          setPaymentTypeFilter('all');
                          setDateRangeFilter('all');
                        }}
                        className="mt-4 inline-flex items-center gap-2 rounded-lg bg-primary px-4 py-2 text-sm font-medium text-white transition-colors hover:bg-primary">
                        <IoRefreshOutline className="h-4 w-4" />
                        Clear Filters
                      </button>
                    </div>
                  )}
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
