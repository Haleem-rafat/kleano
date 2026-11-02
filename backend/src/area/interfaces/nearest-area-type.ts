import { HydratedDocument } from 'mongoose';
import { Area } from '../schemas/area.schema';

export interface NearestAreaType {
  area: HydratedDocument<Area>;
  distance: number;
}
