import { EAPI } from "@constants/endpoints";
import api from "..";


interface INotificationsParams {
    page: number,
    perPage: number
}
class notificationServices {


    public async getAllNotifications(params: INotificationsParams): Promise<any> {
        const { data } = await api.get(EAPI.NOTIFICATIONS, { params });
        return data;
    }
    public async readNotifications(id): Promise<any> {
        const { data } = await api.patch(EAPI.READ_NOTIFICATION.replace(':id', id));
        return data;
    }
}

export default Object.freeze(new notificationServices())