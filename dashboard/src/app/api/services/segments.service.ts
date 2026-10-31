import { EAPI } from '@constants/endpoints';
import { IAllSegment, ISegment } from '@servicesTypes/segments.types';
import * as Yup from 'yup';
import api from '..';

class segmentsServices {
  public async getAllSegments(): Promise<{ data: IAllSegment[]; success: boolean }> {
    const { data } = await api.get(EAPI.SEGMENTS_LIST);
    return data;
  }
  public async getSegmentUsers(segmentId): Promise<{ data: ISegment; success: boolean }> {
    const { data } = await api.get(`${EAPI.SEGMENTS_LIST}/${segmentId}`);
    return data;
  }

  public async updateSegment(
    segmentId: string,
    values: { name: string; users: string[] }
  ): Promise<{ success: boolean }> {
    const { data } = await api.patch(`${EAPI.SEGMENTS_LIST}/${segmentId}`, values);
    return data;
  }

  public async createSegment(values: {
    name: string;
    users: string[];
  }): Promise<{ success: boolean }> {
    const { data } = await api.post(EAPI.SEGMENTS_LIST, values);
    return data;
  }

  public createSegmentSchema = Yup.object({
    segmentName: Yup.string().required('Required').trim(),
    segmentUsers: Yup.array().required('Required'),
  });
}

export default Object.freeze(new segmentsServices());
