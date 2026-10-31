export function formatText(text: string): string {
  // Split the text by capital letters
  const words = text.split(/(?=[A-Z])/);

  // Capitalize the first letter of each word and join them with a space
  const formattedText = words.map((word) => word.charAt(0).toUpperCase() + word.slice(1)).join(' ');

  return formattedText;
}
