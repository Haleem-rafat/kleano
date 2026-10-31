import React, { SetStateAction, useEffect } from 'react';
import { useSearchParams } from 'react-router-dom';
import { useTranslation } from 'react-i18next';

import { Button } from '@/shadecn/components/ui/button';
import {
  Pagination,
  PaginationContent,
  PaginationEllipsis,
  PaginationItem,
  PaginationNext,
  PaginationPrevious,
} from '@/shadecn/components/ui/pagination';

const PaginationComponent = ({
  pages,
  page,
  setPageIndex,
  isChart,
}: {
  pages: number;
  page: number;
  setPageIndex: React.Dispatch<SetStateAction<number>>;
  isChart?: boolean;
}) => {
  const generatePageNumbers = () => {
    const pageNumbers = [];
    const startPage = Math.max(page - 2, 1);
    const endPage = Math.min(page + 2, pages);

    for (let i = startPage; i <= endPage; i++) {
      pageNumbers.push(i);
    }

    return pageNumbers;
  };
  const [searchParams, setSearchParams] = useSearchParams();
  const { t } = useTranslation();
  useEffect(() => {
    if (!isChart) {
      const newParam = new URLSearchParams(searchParams);
      newParam.set('page', page.toString());
      setSearchParams(newParam);
    }
  }, [page]);

  return (
    <div className="flex  w-full items-center justify-start  rounded-lg py-3 shadow">
      <Pagination className="flex  ">
        <PaginationContent>
          <PaginationItem>
            <PaginationPrevious
              title={t('preivious')}
              className={`${
                page === 1
                  ? 'cursor-not-allowed hover:bg-secondary/50'
                  : 'cursor-pointer hover:bg-secondary'
              }  `}
              onClick={() => page > 1 && setPageIndex(page - 1)}
            />
          </PaginationItem>
          {page > 3 && (
            <>
              <PaginationItem>
                <Button
                  type="button"
                  onClick={() => {
                    setPageIndex(1);
                  }}
                  className={`${
                    page === 1 ? 'text-white' : 'border border-primary bg-transparent text-black'
                  }`}>
                  1
                </Button>
              </PaginationItem>
              {page > 4 && (
                <PaginationItem>
                  <PaginationEllipsis />
                </PaginationItem>
              )}
            </>
          )}
          {generatePageNumbers().map((pageNumber) => (
            <PaginationItem key={pageNumber}>
              <Button
                type="button"
                onClick={() => setPageIndex(pageNumber)}
                className={`${
                  page === pageNumber
                    ? 'text-white'
                    : 'border border-primary bg-transparent text-black hover:text-white'
                }`}>
                {pageNumber}
              </Button>
            </PaginationItem>
          ))}
          {page < pages - 3 && (
            <>
              {page < pages - 4 && (
                <PaginationItem>
                  <PaginationEllipsis />
                </PaginationItem>
              )}
              <PaginationItem>
                <Button
                  type="button"
                  onClick={() => setPageIndex(pages)}
                  className={`${
                    page === pages
                      ? 'text-white'
                      : 'border border-primary bg-transparent text-black'
                  }`}>
                  {pages}
                </Button>
              </PaginationItem>
            </>
          )}
          <PaginationItem>
            <PaginationNext
              title={t('next')}
              className={`${
                pages === page
                  ? ' cursor-not-allowed hover:bg-secondary/50'
                  : 'cursor-pointer hover:bg-secondary'
              }  `}
              onClick={() => {
                pages > page && setPageIndex(page + 1);
              }}
            />
          </PaginationItem>
        </PaginationContent>
      </Pagination>
    </div>
  );
};

export default PaginationComponent;
