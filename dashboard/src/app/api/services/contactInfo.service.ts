import { EAPI } from "@constants/endpoints";
import api from "..";

class contactInfoService {

    public async editContactInfo(body) {
        const { data } = await api.patch(EAPI.CONTACT_INFO, body);
        return data;

    } public async createContactInfo(body) {
        const { data } = await api.post(EAPI.CONTACT_INFO, body);
        return data;

    }
    public async getContactInfo() {
        const { data } = await api.get(EAPI.CONTACT_INFO);
        return data;
    }
    public async deleteContactInfo() {
        const { data } = await api.delete(EAPI.CONTACT_INFO);
        return data;
    }

}

export default Object.freeze(new contactInfoService())