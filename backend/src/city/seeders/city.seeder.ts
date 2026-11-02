import { City } from '../schemas/city.schema';

export const prePopulatedCities: City[] = [
  {
    name: {
      ar: 'الرياض',
      en: 'Riyadh',
    },
    latitude: 24.7136,
    longitude: 46.6753,
    isExist: true,
  },
  {
    name: {
      ar: 'جدة',
      en: 'Jeddah',
    },
    latitude: 21.3891,
    longitude: 39.8579,
    isExist: true,
  },
  {
    name: {
      ar: 'الدمام',
      en: 'Dammam',
    },
    latitude: 26.4207,
    longitude: 49.8254,
    isExist: true,
  },
  {
    name: {
      ar: 'المدينة المنورة',
      en: 'Medina',
    },
    latitude: 24.4667,
    longitude: 39.6,
    isExist: true,
  },
  {
    name: {
      ar: 'الخبر',
      en: 'Khobar',
    },
    latitude: 26.2833,
    longitude: 50.2,
    isExist: true,
  },
];
