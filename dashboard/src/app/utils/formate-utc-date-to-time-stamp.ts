export const formateUtsDateToTimeStamp = (date) => {
  const startUtcDate = new Date(date);

  return new Date(
    startUtcDate.getFullYear(),
    startUtcDate.getMonth(),
    startUtcDate.getDate(),
    startUtcDate.getUTCHours(),
    startUtcDate.getMinutes(),
    0
  ).getTime();
};
