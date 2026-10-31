export const displaySectors = (sector, number) => {
  const sectorLable = sector?.map((e) => e?.label || e?.name || e);
  if (sectorLable?.length <= number) {
    return sectorLable?.join(', ');
  } else {
    const visibleCategories = sectorLable?.slice(0, number)?.join(', ');
    const extraCategoriesCount = sectorLable?.length - number;
    return `${visibleCategories}, +${extraCategoriesCount}`;
  }
};
