import { EAPI } from "@constants/endpoints";
import api from "..";

class bannerServices {

    public async getBanners() {
        const { data } = await api.get(EAPI.BANNERS);
        return data;
    }

    public async createBanner(body) {
        const { data } = await api.post(EAPI.BANNERS, body);
        return data;
    }

    public async editBanner(bannerId, body) {
        const { data } = await api.patch(`${EAPI.BANNERS}/${bannerId}`, body);
        return data;
    }

    public async deleteBanner(bannerId) {
        const { data } = await api.delete(`${EAPI.BANNERS}/${bannerId}`);
        return data;
    }
    public async toggleBannerStatus(bannerId, status) {
        const { data } = await api.post(`${EAPI.BANNERS}/${bannerId}/${status}`);
        return data;
    }




}


export default Object.freeze(new bannerServices())