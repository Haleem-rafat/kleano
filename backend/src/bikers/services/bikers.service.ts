import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import * as ExcelJS from 'exceljs';
import { AdminRepository } from 'src/admin/admin.repository';
import { AdminService } from '../../admin/admin.service';
import { MethodNotAllowedResponse } from '../../common/errors/MethodNotAllowedResponse';
import { CreateBikerDTO } from '../dto';
import { GetBikerTotalOrdersDTO } from '../dto/getBikerTotalOrders.dto';
import { UpdateBikerDTO } from '../dto/updateBiker.dto';
import { UpdatePasswordDTO } from '../dto/updatePassword.dto';
import { BikersRepository } from '../repositories/bikers.repository';
import { Biker, BikerStatus } from '../schemas/bikers.schema';

@Injectable()
export class BikersService {
  constructor(
    private bikersRepository: BikersRepository,
    private adminRepository: AdminRepository,
    private adminService: AdminService,
  ) {}

  async createBiker(
    adminId: string,
    createBikerDTO: CreateBikerDTO,
    image: Express.Multer.File,
  ) {
    // hash password using bycrpt
    const hashedPassword = await bcrypt.hash(
      createBikerDTO.password,
      Number(process.env.SALT_OF_ROUND),
    );

    await this.bikersRepository.create(
      adminId,
      createBikerDTO,
      image,
      hashedPassword,
    );
  }

  async getAll(adminId: string, role: string, search?: string) {
    const admin = await this.adminService.getById(adminId);
    return await this.bikersRepository.findAll(role, admin.city, search);
  }

  async getByIdOr404(id: string) {
    return await this.bikersRepository.findByIdOr404(id);
  }

  async getById(id: string | Biker) {
    return await this.bikersRepository.findById(id);
  }

  async getBikerByUserNameOr404(userName: string) {
    return await this.bikersRepository.findByUserNameOr404(userName);
  }

  async getBikersByArea(areaId: string) {
    return await this.bikersRepository.findAllByArea(areaId);
  }

  async deleteBiker(id: string) {
    await this.bikersRepository.delete(id);
  }

  async checkPhoneNumber(phone: string) {
    return await this.bikersRepository.findByPhoneNumber(phone);
  }

  async resetPassword(bikerId: string, password: string) {
    // hash password using bycrpt
    const hashedPassword = await bcrypt.hash(
      password,
      Number(process.env.SALT_OF_ROUND),
    );
    await this.bikersRepository.updateBikerPassword(bikerId, hashedPassword);
  }

  async updateCredentials(
    bikerId: string,
    updatePasswordDTO: UpdatePasswordDTO,
  ) {
    const biker = await this.bikersRepository.findByIdWithPasswordOr404(
      bikerId,
    );
    // Decrypt biker password and Compare
    const isMatch = await bcrypt.compare(
      updatePasswordDTO.oldPassword,
      biker.password,
    );
    if (!isMatch)
      throw new MethodNotAllowedResponse({
        ar: 'بيانات المستخدم غير صالحة',
        en: 'Invalid Biker credentials ',
      });

    // hash password using bycrpt
    const hashedPassword = await bcrypt.hash(
      updatePasswordDTO.newPassword,
      Number(process.env.SALT_OF_ROUND),
    );

    await this.bikersRepository.updateBikerPassword(bikerId, hashedPassword);
  }

  async updatePublicInfo(
    bikerId: string,
    userName: string,
    image: Express.Multer.File,
  ) {
    await this.bikersRepository.updateBikerPublicInfo(bikerId, userName, image);
  }

  async updateBiker(
    bikerId: string,
    adminId: string,
    updateBikerDTO: UpdateBikerDTO,
    image: Express.Multer.File,
  ) {
    return await this.bikersRepository.update(
      bikerId,
      updateBikerDTO,
      image,
      adminId,
    );
  }

  async updateBikerStatus(bikerId: string, status: string) {
    const biker = await this.bikersRepository.findByIdOr404(bikerId);
    biker.status = status;
    await biker.save();
  }

  async suspendBikerById(bikerId: string) {
    const biker = await this.bikersRepository.findByIdOr404(bikerId);
    biker.status = 'SUSPENDED';
    await biker.save();
  }

  async restoreBikerById(bikerId: string) {
    const biker = await this.bikersRepository.findByIdOr404(bikerId);
    biker.status = 'ACTIVE';
    await biker.save();
  }

  async updateBikerSocketId(id: string, socketId: string) {
    const biker = await this.bikersRepository.findById(id);
    biker.socketId = socketId;
    await biker.save();
  }

  async getAllOnlineBikersForOrderLocation(area: any) {
    return await this.bikersRepository.findAllWithStatus(
      BikerStatus.ONLINE,
      area,
    );
  }

  async updateBikerLocation(
    bikerId: string,
    location: {
      latitude: number;
      longitude: number;
      streetName: string;
      subAdministrativeArea: string;
    },
  ) {
    return await this.bikersRepository.updateLocation(bikerId, location);
  }

  async removeInvalidFcmTokenForBiker(bikerId: string, fcmToken: string) {
    const biker = await this.bikersRepository.findBiker(bikerId);

    if (!biker) {
      console.log(
        `Biker with id ${bikerId} not found, skipping FCM token removal`,
      );
      return;
    }

    if (!biker.fcmTokens || biker.fcmTokens.length === 0) {
      console.log(`Biker ${bikerId} has no FCM tokens to remove`);
      return;
    }

    const validFcmTokens = biker.fcmTokens.filter((fcmTokenItem) => {
      return fcmTokenItem !== fcmToken;
    });
    console.log('valid fcmTokens :' + validFcmTokens);

    biker.fcmTokens = validFcmTokens;
    await biker.save();
  }

  async updateBikerLanguage(id: string, language: string) {
    const biker = await this.bikersRepository.findByIdOr404(id);

    biker.language = language;
    await biker.save();
  }

  async getBikersPerformanceReport(query: GetBikerTotalOrdersDTO) {
    const data = await this.bikersRepository.getBikersPerformanceReport(query);

    return data;
  }

  async getBikerProfilePerformanceReport(
    accountId: string,
    bikerId: string,
    query: GetBikerTotalOrdersDTO,
  ) {
    if (accountId !== bikerId) {
      throw new ForbiddenException('Not allowed to view this information');
    }

    const { fromDate, toDate } = query;

    const data = await this.bikersRepository.getBikersPerformanceReport({
      bikerId,
      fromDate,
      toDate,
    });

    return data;
  }

  async exportBikersToExcel() {
    const bikers = await this.bikersRepository.getBikersPerformanceReport({});

    const workbook = new ExcelJS.Workbook();
    const worksheet = workbook.addWorksheet('Bikers');

    worksheet.columns = [
      { header: 'Username', key: 'userName', width: 30 },
      { header: 'Phone', key: 'phone', width: 30 },
      { header: 'National-Id', key: 'nationalId', width: 30 },
      { header: 'Status', key: 'status', width: 30 },
      { header: 'Created-At', key: 'createdAt', width: 30 },
      { header: 'Street-Name', key: 'streetName', width: 30 },
      { header: 'Rating', key: 'rating', width: 30 },
      { header: 'Total-Deliveries', key: 'totalDeliveries', width: 30 },
      { header: 'Total-Time-Worked', key: 'totalTimeWorked', width: 30 },
      {
        header: 'Average-Time-Per-Delivery',
        key: 'averageTimePerDelivery',
        width: 30,
      },
    ];

    bikers.forEach((biker) => {
      worksheet.addRow({
        userName: biker.userName,
        phone: biker.phone,
        nationalId: biker.nationalId,
        status: biker.status,
        createdAt: biker.createdAt,
        streetName: biker.streetName,
        rating: biker.rating,
        totalDeliveries: biker.totalDeliveries,
        totalTimeWorked: biker.totalTimeWorked,
        averageTimePerDelivery: biker.averageTimePerDelivery,
      });
    });

    const buffer = await workbook.xlsx.writeBuffer();
    return buffer;
  }

  async changeBikerPassword(
    adminId: string,
    bikerId: string,
    newPassword: string,
  ): Promise<void> {
    // Fetch admin and biker data
    const admin = await this.adminRepository.findById(adminId);
    const biker = await this.bikersRepository.findById(bikerId);

    if (!admin || !biker) {
      throw new NotFoundException('Admin or Biker not found');
    }

    const hashedPassword = await bcrypt.hash(
      newPassword,
      Number(process.env.SALT_OF_ROUND),
    );
    await this.bikersRepository.updatePassword(bikerId, hashedPassword);
  }
}
