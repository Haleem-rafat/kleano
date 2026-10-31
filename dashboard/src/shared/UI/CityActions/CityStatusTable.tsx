import React from 'react';
import { Button, ThreeDotsLoader } from '@UI/Index';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@shadecn/components/ui/table';
import { useTranslation } from 'react-i18next';

export default function CityStatusTable({ citiesData, isLoading, handleArchive, handleActivate }) {
  const { t, i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';

  return (
    <Table className="scrollbar-hide">
      {isLoading && <ThreeDotsLoader />}
      <TableHeader>
        <TableRow>
          <TableHead className="min-w-[100px]">{t('cityName')}</TableHead>
          <TableHead className="min-w-[100px]">{t('cityState')}</TableHead>
          <TableHead className="min-w-[100px]">{t('cityActions')}</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        {citiesData?.map((city) => (
          <TableRow key={city?.city._id}>
            <TableCell>{city.city.name[lang]}</TableCell>
            <TableCell>
              {city?.isArchived ? (
                <div className="rounded-full bg-yellow-500 px-5 py-1 text-center text-white">
                  {t('archive')}
                </div>
              ) : (
                <div className="rounded-full bg-green-400 px-5 py-1 text-center text-white">
                  {t('active')}
                </div>
              )}
            </TableCell>
            <TableCell className="space-x-3">
              {city?.isArchived ? (
                <Button
                  onClick={() => handleActivate(city?.city._id)}
                  variant="secondary"
                  size="sm"
                >
                  {t('active')}
                </Button>
              ) : (
                <Button onClick={() => handleArchive(city?.city._id)} variant="secondary" size="sm">
                  {t('archive')}
                </Button>
              )}
            </TableCell>
          </TableRow>
        ))}
      </TableBody>
    </Table>
  );
}
