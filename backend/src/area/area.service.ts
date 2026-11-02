import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { City } from 'src/city/schemas/city.schema';
import { CreateAreaDto, UpdateAreaDto } from './dto';
import { Area, AreaModel, areaModelName } from './schemas/area.schema';

@Injectable()
export class AreasService {
  constructor(
    @InjectModel(areaModelName) private readonly areaModel: Model<AreaModel>,
  ) {}

  async getAreasByCity(cityId: string): Promise<Area[]> {
    return this.areaModel.find({ city: cityId }, { name: 1, _id: 1 }).lean();
  }

  async getAreaByCoordinates(
    longitude: number,
    latitude: number,
    maxDistance = 5000,
  ): Promise<Area | null> {
    return this.areaModel
      .findOne({
        latitude: { $exists: true },
        longitude: { $exists: true },
        $expr: {
          $lte: [
            {
              $multiply: [
                6371000, // Earth's radius in meters
                {
                  $acos: {
                    $add: [
                      {
                        $multiply: [
                          { $sin: { $degreesToRadians: '$latitude' } },
                          { $sin: { $degreesToRadians: latitude } },
                        ],
                      },
                      {
                        $multiply: [
                          { $cos: { $degreesToRadians: '$latitude' } },
                          { $cos: { $degreesToRadians: latitude } },
                          {
                            $cos: {
                              $subtract: [
                                { $degreesToRadians: '$longitude' },
                                { $degreesToRadians: longitude },
                              ],
                            },
                          },
                        ],
                      },
                    ],
                  },
                },
              ],
            },
            maxDistance, // Maximum distance in meters
          ],
        },
      })
      .exec();
  }

  async createArea(createAreaDto: CreateAreaDto): Promise<Area> {
    const newArea = new this.areaModel(createAreaDto);
    return newArea.save();
  }

  async updateArea(
    areaId: string,
    updateAreaDto: UpdateAreaDto,
  ): Promise<Area> {
    const updatedArea = await this.areaModel.findByIdAndUpdate(
      areaId,
      updateAreaDto,
      { new: true },
    );
    if (!updatedArea) {
      throw new NotFoundException(`Area with ID "${areaId}" not found`);
    }

    return updatedArea;
  }

  async validateAreas(cityId: City, areas: Area[]): Promise<boolean> {
    const validAreas = await this.areaModel.find({ city: cityId });

    const validAreaIds = new Set(validAreas.map((area) => area._id.toString()));

    const selectedAreaIds = areas.map((area) => area.toString());

    const areValid = selectedAreaIds.every((areaId) =>
      validAreaIds.has(areaId),
    );

    if (!areValid) {
      throw new BadRequestException(
        'Some areas do not belong to the selected city',
      );
    }

    return true;
  }
}
