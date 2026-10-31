export function getLocalStorageItem(key: string): any {
  try {
    const _item = localStorage.getItem(key);
    if (_item !== null) {
      try {
        const parsedItem = JSON.parse(_item);
        return parsedItem;
      } catch (parseError) {
        return _item;
      }
    }
    return null;
  } catch (storageError) {
    localStorage.removeItem(key);
    console.error(`Error accessing local storage for key '${key}':`, storageError);
    return null;
  }
}
