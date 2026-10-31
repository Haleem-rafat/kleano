import { EAPI } from '@constants/endpoints';
import { DateRange } from 'react-day-picker';
import { format } from 'date-fns';
import api from '..';

interface IBookingParams {
  biker?: string;
  city?: string;
  area?: string;
  day?: 'FRIDAY' | 'SATURDAY' | 'SUNDAY' | 'MONDAY' | 'TUESDAY' | 'WEDNESDAY' | 'THURSDAY';
  date?: string;
}

interface IBooking {
  data: {
    bikers: {
      _id: string;
      userName: string;
      phone: string;
      nationalId: string;
    }[];
    timeSlot: string;
  }[];
}

class bookingService {
  public async getBookings(params: DateRange) {
    const formattedParams = {
      from: format(params.from, 'yyyy-MM-dd') + 'T00:00:00.000Z',
      to: format(params.to, 'yyyy-MM-dd') + 'T23:59:59.999Z',
    };
    const { data } = await api.get(EAPI.BOOKING_DAYS, {
      params: formattedParams,
    });
    return data;
  }
  public async updateBooking(payload) {
    const { data } = await api.patch(EAPI.BOOKING_DAYS, payload);
    return data;
  }

  public async createBookingSprint(payload) {
    const { data } = await api.post(EAPI.BOOKING_DAYS, payload);
    return data;
  }
  // ===================================================================== //
  // list all bookings
  public async listAllBookings(params: IBookingParams) {
    const { data } = await api.get(EAPI.BOOKING_ALL, { params });
    return data as IBooking[];
  }
}

export default Object.freeze(new bookingService());
