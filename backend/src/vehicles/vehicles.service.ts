import { Injectable } from '@nestjs/common';
import { CreateVehicleDTO } from './dto/createVehicle.dto';
import { VehiclesRepository } from './vehicles.repository.';

@Injectable()
export class VehiclesService {
  constructor(private vehiclesRepository: VehiclesRepository) {}

  async createVehicle(
    userId: string,
    createVehicleDTO: CreateVehicleDTO,
    image: Express.Multer.File,
  ) {
    return await this.vehiclesRepository.create(
      userId,
      createVehicleDTO,
      image,
    );
  }

  async getAll(userId: string) {
    return await this.vehiclesRepository.findAll(userId);
  }

  async getByIdOr404(id: string) {
    return await this.vehiclesRepository.findByIdOr404(id);
  }

  async delete(id: string) {
    await this.vehiclesRepository.delete(id);
  }

  async update(
    id: string,
    createVehicleDTO: CreateVehicleDTO,
    image: Express.Multer.File,
  ) {
    return await this.vehiclesRepository.update(id, createVehicleDTO, image);
  }

  async getById(id: string) {
    return await this.vehiclesRepository.findById(id);
  }
}
