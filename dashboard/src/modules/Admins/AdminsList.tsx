import { IoSearchOutline } from 'react-icons/io5';
import React, { useState } from 'react';
import { generatePath, useNavigate, useSearchParams } from 'react-router-dom';
import {
  Button,
  EmtyState,
  DataTable,
  FormSheet,
  PageHeader,
  FilterPanel,
  FilterSearch,
} from '@UI/Index';
import adminsService from '@services/admins.service';
import useSWR from 'swr';
import { useTranslation } from 'react-i18next';
import { ROUTES } from '@constants/routes';
import PaginationComponent from '@UI/paginationComponent/PaginationComponent';
import { Tabs, TabsList, TabsTrigger } from '@shadecn/components/ui/tabs';

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
    <div className="space-y-4">
      <PageHeader
        title={t('admins')}
        description={t('Manage admin users and permissions')}
        actions={<Button onClick={() => setOpenSheet(true)}>{t('addNewAdmin')}</Button>}
      />
      {/* Main Content */}
      <div>
        <div>
          <FilterPanel
            className="mb-5"
            tabs={
              <Tabs
                defaultValue={tabs[0].status}
                onValueChange={(value) =>
                  handleTabChange(tabs.find((tab) => tab.status === value))
                }>
                <TabsList>
                  {tabs.map((tab, index) => (
                    <TabsTrigger value={tab.status} key={index}>
                      {t(tab.title)}
                    </TabsTrigger>
                  ))}
                </TabsList>
              </Tabs>
            }>
            <FilterSearch value={search} onChange={setSearch} placeholder={t('search')} />
          </FilterPanel>

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
      <FormSheet open={openSheet} onOpenChange={() => setOpenSheet(false)} title={t('manageAdmin')}>
        <AdminModelForm setOpenSheet={setOpenSheet} />
      </FormSheet>
    </div>
  );
};

export default AdminsList;
