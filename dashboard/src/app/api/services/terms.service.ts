import { EAPI } from '@constants/endpoints';
import api from '..';

class termsServices {
  public async getTerms() {
    const { data } = await api.get(EAPI.TERMS);
    return data;
  }
  public async addTerms(content: { en: string; ar: string }) {
    const { data } = await api.post(EAPI.TERMS, { content });
    return data;
  }
  public async updateTerms(content: { en: string; ar: string }) {
    const { data } = await api.patch(EAPI.TERMS, { content });
    return data;
  }
}
export default Object.freeze(new termsServices());
