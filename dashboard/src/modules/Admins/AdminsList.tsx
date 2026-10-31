import React, { useState } from 'react';
import { generatePath, useNavigate, useSearchParams } from 'react-router-dom';
import { Button, EmtyState, DataTable } from '@UI/Index';
import adminsService from '@services/admins.service';
import useSWR from 'swr';
import { useTranslation } from 'react-i18next';
import { ROUTES } from '@constants/routes';
import PaginationComponent from '@UI/paginationComponent/PaginationComponent';
import { Tabs, TabsList, TabsTrigger } from '@shadecn/components/ui/tabs';

import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from '@shadecn/components/ui/sheet';
import { Input } from '@shadecn/components/ui/input';
import { createAdminColumns } from '@UI/DataTable/columns/adminColumns';
import { IAdmin } from '@servicesTypes/admins.types';
import AdminModelForm from './_Components/AdminModelForm';
import useDebounce from '@/hooks/useDebounce';

const AdminsList = () => {
  const navigate = useNavigate();
  const { t } = useTranslation();
  const [pageIndex, setPageIndex] = useState(1);
  const [searchParams, setSearchParams] = useSearchParams();
  const [search, setSearch] = useState('');
  const debouncedSearch = useDebounce(search, 800);
  const { data: adminsList, isLoading } = useSWR(
    ['get-all-admins-list', debouncedSearch, pageIndex, searchParams],
    () =>
      adminsService
        .getAllAdmins({
          page: pageIndex,
          perPage: 10,
          status: searchParams.get('status') as 'SUSPENDED' | 'ACTIVE',
          search: debouncedSearch,
        })
        .then((data) => {
          return data;
        })
  );
  const [openSheet, setOpenSheet] = useState(false);

  // Create columns for the DataTable
  const columns = createAdminColumns(t);

  const tabs = [
    { title: 'all', status: '' },
    { title: 'active', status: 'ACTIVE' },
    { title: 'suspend', status: 'SUSPENDED' },
  ];

  const handleTabChange = (tab) => {
    const newParams = new URLSearchParams(searchParams);
    if (tab.status !== '') {
      newParams.set('status', tab.status);
      setSearchParams(newParams);
    } else {
      newParams.delete('status');
      setSearchParams(newParams);
    }
  };

  const handleRowClick = (admin: IAdmin) => {
    navigate(generatePath(ROUTES.ADMIN_DETAILS, { adminId: admin._id }));
  };
  return (
    <div className="min-h-screen bg-slate-50">
      {/* Professional Header */}
      <div className="border-b border-slate-200 bg-white shadow-sm">
        <div className="px-6 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <div>
                <h1 className="text-xl font-semibold tracking-tight text-slate-900">{t('admins')}</h1>
                <p className="mt-1 text-sm text-slate-500">Manage admin users and permissions</p>
              </div>
            </div>
            <div className="flex items-center space-x-4">
              <div className="relative">
                <Input
                  onChange={(e) => setSearch(e.target.value)}
                  value={search}
                  placeholder="Search admins..."
                  className="w-64"
                />
              </div>
              <Button onClick={() => setOpenSheet(true)} className="bg-primary">
                {t('addNewAdmin')}
              </Button>
            </div>
          </div>
        </div>
      </div>

      {/* Main Content */}
      <div className="p-6">
        <div className="mx-auto max-w-[95%]">
          {/* Filter Tabs */}
          <div className="mb-6">
            <Tabs
              defaultValue={tabs[0].status}
              onValueChange={(value) => handleTabChange(tabs.find((tab) => tab.status === value))}>
              <TabsList className="grid w-full grid-cols-3 border border-slate-200 bg-white">
                {tabs.map((tab, index) => (
                  <TabsTrigger
                    value={tab.status}
                    key={index}
                    className="data-[state=active]:bg-primary data-[state=active]:text-white">
                    {t(tab.title)}
                  </TabsTrigger>
                ))}
              </TabsList>
            </Tabs>
          </div>

          {/* Data Table */}
          <div className="mb-6">
            <DataTable
              columns={columns}
              data={adminsList?.data || []}
              isLoading={isLoading}
              onRowClick={handleRowClick}
              emptyStateComponent={<EmtyState />}
            />
          </div>

          {/* Pagination */}
          {adminsList && (
            <div className="flex justify-center">
              <PaginationComponent
                page={adminsList.page}
                pages={adminsList.totalPages}
                setPageIndex={setPageIndex}
              />
            </div>
          )}
        </div>
      </div>

      {/* Add Admin Sheet */}
      <Sheet open={openSheet} onOpenChange={() => setOpenSheet(false)} modal={true}>
        <SheetContent>
          <SheetHeader>
            <SheetTitle>{t('manageAdmin')}</SheetTitle>
            <SheetDescription>
              <AdminModelForm setOpenSheet={setOpenSheet} />
            </SheetDescription>
          </SheetHeader>
        </SheetContent>
      </Sheet>
    </div>
  );
};

export default AdminsList;
