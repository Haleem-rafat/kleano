export const formatCurrency = (amount: number): string => {
  const finalRes = new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'R.S',
  }).format(amount);

  return finalRes;
};
