export const spliteEmailToName = (email: string) => {
  return email
    ?.split('@')[0]
    ?.replace(/[^a-zA-Z]+/g, ' ')
    ?.trim()
    ?.split(' ')
    ?.map((word) => word.charAt(0).toUpperCase() + word.slice(1))
    ?.join(' ');
};
