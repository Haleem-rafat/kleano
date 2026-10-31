export function formatEnumsText(input: string): string {
  // Add a space before each capital letter (except the first letter)
  const formattedText = input?.replace(/([A-Z])/g, ' $1');

  // Capitalize the first letter
  return formattedText?.charAt(0)?.toUpperCase() + formattedText?.slice(1);
}
