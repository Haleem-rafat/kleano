import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { VehicleModel, vehicleModelName } from './schemas/vehicles.schema';
import { CreateVehicleDTO } from './dto/createVehicle.dto';
import { FirebaseService } from '../common/services/firebase/firebase.service';
import { NotFoundResponse } from '../common/errors/NotFoundResponse';
import { MethodNotAllowedResponse } from '../common/errors/MethodNotAllowedResponse';

@Injectable()
export class VehiclesRepository {
  constructor(
    @InjectModel(vehicleModelName)
    private readonly vehicleModel: Model<VehicleModel>,
    private firebaseService: FirebaseService,
  ) {}

  async create(
    userId: string,
    createVehicleDTO: CreateVehicleDTO,
    image: Express.Multer.File,
  ) {
    const plateNumberAlreadyExist = await this.checkPlateNumber(
      createVehicleDTO.plateNumber,
    );
    if (plateNumberAlreadyExist)
      throw new MethodNotAllowedResponse({
        ar: 'رقم السيارة مسجل من قبل',
        en: 'Plate Number is already exist',
      });

    // Create Vehicle
    const createdVehicle = await this.vehicleModel.create({
      // type: createVehicleDTO.type,
      brand: createVehicleDTO.brand,
      model: createVehicleDTO.model,
      plateNumber: createVehicleDTO.plateNumber,
      color: createVehicleDTO.color,
      user: userId,
    });

    if (image) {
      // Upload Image to Firebase
      const { fileLink, filePath } = await this.firebaseService.uploadImage(
        image,
      );

      // Update Vehicle with image
      createdVehicle.imageLink = fileLink;
      createdVehicle.imagePath = filePath;
      await createdVehicle.save();
    }

    return createdVehicle;
  }

  async findAll(userId: string) {
    return await this.vehicleModel.find({ user: userId });
  }

  async findByIdOr404(id: string) {
    const vehicle = await this.vehicleModel.findById(id);

    if (!vehicle)
      throw new NotFoundResponse({
        ar: 'لاتوجد هذه السيارة',
        en: 'Vehicle Not Found',
      });
    return vehicle;
  }

  async delete(id: string) {
    await this.vehicleModel.deleteOne({ _id: id });
  }

  async update(
    id: string,
    createVehicleDTO: CreateVehicleDTO,
    image: Express.Multer.File,
  ) {
    const plateNumberAlreadyExist = await this.checkPlateNumberForAnotherCar(
      id,
      createVehicleDTO.plateNumber,
    );
    if (plateNumberAlreadyExist)
      throw new MethodNotAllowedResponse({
        ar: 'رقم السيارة مسجل من قبل',
        en: 'Plate Number is already exist',
      });

    const vehicle = await this.vehicleModel.findById(id);

    // vehicle.type = createVehicleDTO.type;
    vehicle.brand = createVehicleDTO.brand;
    vehicle.model = createVehicleDTO.model;
    vehicle.plateNumber = createVehicleDTO.plateNumber;
    vehicle.color = createVehicleDTO.color;
    await vehicle.save();

    if (image) {
      if (vehicle.imagePath)
        await this.firebaseService.deleteFileFromStorage(vehicle.imagePath);

      // Upload Image to Firebase
      const { fileLink, filePath } = await this.firebaseService.uploadImage(
        image,
      );

      // Update Vehicle with image
      vehicle.imageLink = fileLink;
      vehicle.imagePath = filePath;
      await vehicle.save();
    }

    return vehicle;
  }

  async findById(id: string) {
    const vehicle = await this.vehicleModel.findById(id);

    return vehicle;
  }

  async checkPlateNumber(plateNumber: string) {
    const plateIsExist = await this.vehicleModel.findOne({
      plateNumber: plateNumber.trim(),
    });
    return plateIsExist ? true : false;
  }

  async checkPlateNumberForAnotherCar(id: string, plateNumber: string) {
    const plateIsExist = await this.vehicleModel.findOne({
      _id: { $ne: id },
      plateNumber: plateNumber.trim(),
    });
    return plateIsExist ? true : false;
  }

  async deleteMany(userId: string) {}
}
