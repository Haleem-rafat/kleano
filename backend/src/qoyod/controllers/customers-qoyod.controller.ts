import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  Put,
  Query,
} from '@nestjs/common';
import { CreateCustomerDto } from '../dtos/create-customer.dto';
import { CustomersQoyodService } from '../services/customers-qoyod.service';

/**
 * Qoyod Customers Controller
 * Handles customer/contact management in Qoyod
 */
@Controller('qoyod/customers')
export class CustomersQoyodController {
  constructor(private readonly customersQoyodService: CustomersQoyodService) {}

  /**
   * Create a new customer
   * POST /qoyod/customers
   */
  @Post()
  async createCustomer(@Body() createCustomerDto: CreateCustomerDto) {
    return await this.customersQoyodService.createCustomer(createCustomerDto);
  }

  /**
   * Get customer details by ID
   * GET /qoyod/customers/:id
   */
  @Get(':id')
  async getCustomer(@Param('id') id: string) {
    return await this.customersQoyodService.getCustomer(id);
  }

  /**
   * List all customers with optional filters
   * GET /qoyod/customers
   */
  @Get()
  async listCustomers(
    @Query('page') page?: number,
    @Query('per_page') perPage?: number,
    @Query('status') status?: string,
  ) {
    return await this.customersQoyodService.listCustomers({
      page,
      per_page: perPage,
      status,
    });
  }

  /**
   * Update customer details
   * PUT /qoyod/customers/:id
   */
  @Put(':id')
  async updateCustomer(
    @Param('id') id: string,
    @Body() updateCustomerDto: CreateCustomerDto,
  ) {
    return await this.customersQoyodService.updateCustomer(
      id,
      updateCustomerDto,
    );
  }

  /**
   * Delete a customer
   * DELETE /qoyod/customers/:id
   */
  @Delete(':id')
  async deleteCustomer(@Param('id') id: string) {
    await this.customersQoyodService.deleteCustomer(id);
    return {
      message: {
        ar: 'تم حذف العميل بنجاح',
        en: 'Customer deleted successfully',
      },
    };
  }

  /**
   * Sync users with Qoyod
   * Creates Qoyod customers for all users that don't have one
   * POST /qoyod/customers/sync/users
   * @param batchSize - Number of users to process per batch (default: 50)
   * @param delayMs - Delay between batches in milliseconds (default: 2000)
   */
  @Post('sync/users')
  async syncUsers(
    @Query('batchSize') batchSize?: number,
    @Query('delayMs') delayMs?: number,
  ) {
    return await this.customersQoyodService.syncUsers(
      batchSize ? Number(batchSize) : 50,
      delayMs ? Number(delayMs) : 2000,
    );
  }
}
