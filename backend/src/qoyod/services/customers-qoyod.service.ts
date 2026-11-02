import { HttpService } from '@nestjs/axios';
import {
  BadRequestException,
  Injectable,
  InternalServerErrorException,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { OnEvent } from '@nestjs/event-emitter';
import { catchError, firstValueFrom, map } from 'rxjs';
import { UserRepository } from 'src/user/user.repository';
import { CreateCustomerDto } from '../dtos/create-customer.dto';

@Injectable()
export class CustomersQoyodService {
  private readonly logger = new Logger(CustomersQoyodService.name);
  private readonly apiKey: string;
  private readonly baseUrl: string;

  constructor(
    private readonly httpService: HttpService,
    private readonly userRepository: UserRepository,
  ) {
    this.apiKey = process.env.QOYOD_API_KEY;
    this.baseUrl = process.env.QOYOD_BASE_URL || 'https://api.qoyod.com/2.0';

    if (!this.apiKey) {
      this.logger.error('QOYOD_API_KEY is not configured');
      throw new Error('QOYOD_API_KEY must be set in environment variables');
    }
  }

  /**
   * Get default headers for Qoyod API requests
   */
  private getHeaders() {
    return {
      'Content-Type': 'application/json',
      'API-KEY': this.apiKey,
      Accept: 'application/json',
    };
  }

  /**
   * Create a new customer/contact in Qoyod
   * @param createCustomerDto - Customer details
   * @returns Created customer response
   */
  async createCustomer(createCustomerDto: CreateCustomerDto) {
    try {
      this.logger.log('Creating customer in Qoyod');

      const customerData = {
        contact: {
          name: createCustomerDto.name,
          organization: createCustomerDto.organization || '',
          phone_number: createCustomerDto.phone_number || '',
          email: createCustomerDto.email || '',
          tax_number: createCustomerDto.tax_number || '',
          status: createCustomerDto.status || 'Active',
        },
      };

      this.logger.debug(
        `Customer request body: ${JSON.stringify(customerData, null, 2)}`,
      );

      const response = await firstValueFrom(
        this.httpService
          .post(`${this.baseUrl}/customers`, customerData, {
            headers: this.getHeaders(),
          })
          .pipe(
            map((res) => res.data),
            catchError((error) => {
              this.logger.error(
                `Failed to create customer: ${
                  error.response?.data?.message || error.message
                }`,
              );
              this.logger.error(`Response status: ${error.response?.status}`);
              this.logger.error(
                `Response data: ${JSON.stringify(error.response?.data)}`,
              );
              this.logger.error(`Request URL: ${this.baseUrl}/customers`);
              throw this.handleApiError(error);
            }),
          ),
      );

      this.logger.log(
        `Customer created successfully. Response: ${JSON.stringify(response)}`,
      );

      // Extract customer ID from response (Qoyod returns it in response.contact.id)
      const customerId = response?.contact?.id || response?.id || null;

      return {
        ...response,
        id: customerId,
      };
    } catch (error) {
      if (
        error instanceof BadRequestException ||
        error instanceof InternalServerErrorException
      ) {
        throw error;
      }
      this.logger.error(`Unexpected error creating customer: ${error.message}`);
      throw new InternalServerErrorException({
        ar: 'فشل في إنشاء العميل',
        en: 'Failed to create customer',
      });
    }
  }

  /**
   * Get customer details by ID
   * @param customerId - Customer ID
   * @returns Customer details
   */
  async getCustomer(customerId: string) {
    try {
      this.logger.log(`Fetching customer: ${customerId}`);

      const response = await firstValueFrom(
        this.httpService
          .get(`${this.baseUrl}/customers/${customerId}`, {
            headers: this.getHeaders(),
          })
          .pipe(
            map((res) => res.data),
            catchError((error) => {
              this.logger.error(
                `Failed to fetch customer: ${
                  error.response?.data?.message || error.message
                }`,
              );
              throw this.handleApiError(error);
            }),
          ),
      );

      this.logger.log(`Customer fetched successfully: ${customerId}`);
      return response;
    } catch (error) {
      if (
        error instanceof NotFoundException ||
        error instanceof InternalServerErrorException
      ) {
        throw error;
      }
      this.logger.error(`Unexpected error fetching customer: ${error.message}`);
      throw new InternalServerErrorException({
        ar: 'فشل في جلب العميل',
        en: 'Failed to fetch customer',
      });
    }
  }

  /**
   * List all customers with optional filters
   * @param params - Query parameters
   * @returns List of customers
   */
  async listCustomers(params?: {
    page?: number;
    per_page?: number;
    status?: string;
  }) {
    try {
      this.logger.log('Fetching customers list');

      const queryParams = new URLSearchParams();
      if (params) {
        Object.entries(params).forEach(([key, value]) => {
          if (value !== undefined && value !== null) {
            queryParams.append(key, value.toString());
          }
        });
      }

      const url = `${this.baseUrl}/customers${
        queryParams.toString() ? `?${queryParams.toString()}` : ''
      }`;

      const response = await firstValueFrom(
        this.httpService
          .get(url, {
            headers: this.getHeaders(),
          })
          .pipe(
            map((res) => res.data),
            catchError((error) => {
              this.logger.error(
                `Failed to fetch customers: ${
                  error.response?.data?.message || error.message
                }`,
              );
              throw this.handleApiError(error);
            }),
          ),
      );

      this.logger.log('Customers list fetched successfully');
      return response;
    } catch (error) {
      if (error instanceof InternalServerErrorException) {
        throw error;
      }
      this.logger.error(
        `Unexpected error fetching customers: ${error.message}`,
      );
      throw new InternalServerErrorException({
        ar: 'فشل في جلب قائمة العملاء',
        en: 'Failed to fetch customers list',
      });
    }
  }

  /**
   * Update customer details
   * @param customerId - Customer ID
   * @param updateCustomerDto - Updated customer details
   * @returns Updated customer response
   */
  async updateCustomer(
    customerId: string,
    updateCustomerDto: CreateCustomerDto,
  ) {
    try {
      this.logger.log(`Updating customer: ${customerId}`);

      const customerData = {
        contact: {
          name: updateCustomerDto.name,
          email: updateCustomerDto.email,
        },
      };

      const response = await firstValueFrom(
        this.httpService
          .put(`${this.baseUrl}/customers/${customerId}`, customerData, {
            headers: this.getHeaders(),
          })
          .pipe(
            map((res) => res.data),
            catchError((error) => {
              this.logger.error(
                `Failed to update customer: ${
                  error.response?.data?.message || error.message
                }`,
              );
              throw this.handleApiError(error);
            }),
          ),
      );

      this.logger.log(`Customer updated successfully: ${customerId}`);
      return response;
    } catch (error) {
      if (
        error instanceof NotFoundException ||
        error instanceof BadRequestException ||
        error instanceof InternalServerErrorException
      ) {
        throw error;
      }
      this.logger.error(`Unexpected error updating customer: ${error.message}`);
      throw new InternalServerErrorException({
        ar: 'فشل في تحديث العميل',
        en: 'Failed to update customer',
      });
    }
  }

  /**
   * Delete a customer
   * @param customerId - Customer ID
   */
  async deleteCustomer(customerId: string) {
    try {
      this.logger.log(`Deleting customer: ${customerId}`);

      await firstValueFrom(
        this.httpService
          .delete(`${this.baseUrl}/customers/${customerId}`, {
            headers: this.getHeaders(),
          })
          .pipe(
            catchError((error) => {
              this.logger.error(
                `Failed to delete customer: ${
                  error.response?.data?.message || error.message
                }`,
              );
              throw this.handleApiError(error);
            }),
          ),
      );

      this.logger.log(`Customer deleted successfully: ${customerId}`);
    } catch (error) {
      if (
        error instanceof NotFoundException ||
        error instanceof InternalServerErrorException
      ) {
        throw error;
      }
      this.logger.error(`Unexpected error deleting customer: ${error.message}`);
      throw new InternalServerErrorException({
        ar: 'فشل في حذف العميل',
        en: 'Failed to delete customer',
      });
    }
  }

  /**
   * Handle API errors and convert them to NestJS exceptions
   */
  private handleApiError(error: any): Error {
    const status = error.response?.status;
    const message = error.response?.data?.message || error.message;
    const details = error.response?.data?.details;

    switch (status) {
      case 400:
        return new BadRequestException({
          ar: 'طلب غير صحيح',
          en: message || 'Bad request',
          details,
        });
      case 404:
        return new NotFoundException({
          ar: 'العميل غير موجود',
          en: message || 'Customer not found',
          details,
        });
      case 401:
      case 403:
        return new InternalServerErrorException({
          ar: 'خطأ في المصادقة مع Qoyod',
          en: 'Authentication error with Qoyod',
          details,
        });
      default:
        return new InternalServerErrorException({
          ar: 'خطأ في الاتصال بـ Qoyod',
          en: message || 'Error communicating with Qoyod',
          details,
        });
    }
  }

  @OnEvent('user.created')
  async createCustomerFromUser({
    userId,
    userName,
    phone,
    email,
  }: {
    userId: string;
    userName: string;
    phone: string;
    email: string;
  }) {
    try {
      await this.createCustomerForUser({ userId, userName, phone, email });
    } catch (error) {
      this.logger.error(
        `Error creating qoyod customer from user: ${error.message}`,
      );
    }
  }

  /**
   * Returns the user's Qoyod customer ID, creating the customer when the user
   * has none or the saved one no longer exists in Qoyod.
   * @param userId - User ID
   * @returns Qoyod customer ID
   */
  async ensureCustomerForUser(userId: string): Promise<number> {
    const user = await this.userRepository.findUserByIdOr404(userId);

    if (user.qoyodCustomerId) {
      try {
        await this.getCustomer(user.qoyodCustomerId.toString());
        return user.qoyodCustomerId;
      } catch (error) {
        // Only a 404 proves the customer is gone; on other errors keep the
        // saved ID rather than creating a duplicate customer
        if (!(error instanceof NotFoundException)) {
          this.logger.warn(
            `Could not verify Qoyod customer ${user.qoyodCustomerId}, using it anyway: ${error.message}`,
          );
          return user.qoyodCustomerId;
        }

        this.logger.warn(
          `Qoyod customer ${user.qoyodCustomerId} not found, recreating for user ${userId}`,
        );
      }
    }

    return await this.createCustomerForUser({
      userId,
      userName: user.userName,
      phone: user.phone,
      email: user.email,
    });
  }

  /**
   * Create a Qoyod customer for a user and save its ID on the user
   * @returns Qoyod customer ID
   */
  private async createCustomerForUser({
    userId,
    userName,
    phone,
    email,
  }: {
    userId: string;
    userName?: string;
    phone?: string;
    email?: string;
  }): Promise<number> {
    const customer = await this.createCustomer({
      name: userName || 'User',
      phone_number: phone || '',
      email: email || '',
    });

    if (!customer.id) {
      throw new Error('Qoyod did not return a customer ID');
    }

    // Update user with qoyodCustomerId
    await this.userRepository.updateQoyodCustomerId(userId, customer.id);

    return customer.id;
  }

  @OnEvent('user.updated')
  async updateCustomerFromUser({
    userId,
    qoyodCustomerId,
    userName,
    email,
  }: {
    userId: string;
    qoyodCustomerId: number | null;
    userName: string;
    email: string;
  }) {
    try {
      // No Qoyod customer yet (e.g. creation failed at sign-up), so create one
      // from the saved, already-updated profile instead of updating
      if (!qoyodCustomerId) {
        await this.ensureCustomerForUser(userId);
        return;
      }

      await this.updateCustomer(qoyodCustomerId.toString(), {
        name: userName,
        email: email,
      });
    } catch (error) {
      this.logger.error(
        `Error updating qoyod customer from user: ${error.message}`,
      );
    }
  }

  /**
   * Sync all users without Qoyod customers
   * Creates Qoyod customers for all users that don't have one
   * Processes in batches with delays to avoid rate limits
   * @param batchSize - Number of users to process per batch (default: 50)
   * @param delayMs - Delay between batches in milliseconds (default: 2000)
   * @returns Summary of sync operation
   */
  async syncUsers(batchSize = 50, delayMs = 2000) {
    this.logger.log('Starting users sync with Qoyod');

    try {
      // Get all users without qoyodCustomerId
      const usersWithoutQoyod =
        await this.userRepository.findAllWithoutQoyodCustomer();

      if (usersWithoutQoyod.length === 0) {
        this.logger.log('No users to sync - all have Qoyod customers');
        return {
          success: true,
          message: 'All users are already synced with Qoyod',
          synced: 0,
          failed: 0,
          total: 0,
          results: [],
        };
      }

      this.logger.log(
        `Found ${usersWithoutQoyod.length} users without Qoyod customers`,
      );
      this.logger.log(
        `Processing in batches of ${batchSize} with ${delayMs}ms delay between batches`,
      );

      const results = [];
      let successCount = 0;
      let failedCount = 0;

      // Process users in batches
      const totalBatches = Math.ceil(usersWithoutQoyod.length / batchSize);

      for (let i = 0; i < totalBatches; i++) {
        const start = i * batchSize;
        const end = Math.min(start + batchSize, usersWithoutQoyod.length);
        const batch = usersWithoutQoyod.slice(start, end);

        this.logger.log(
          `Processing batch ${i + 1}/${totalBatches} (users ${
            start + 1
          }-${end})`,
        );

        // Process batch concurrently with Promise.allSettled
        const batchPromises = batch.map(async (user) => {
          try {
            this.logger.debug(
              `Creating Qoyod customer for user: ${user.userName} (${user._id})`,
            );

            const qoyodCustomerId = await this.createCustomerForUser({
              userId: user._id.toString(),
              userName: user.userName,
              phone: user.phone,
              email: user.email,
            });

            return {
              userId: user._id.toString(),
              userName: user.userName,
              phone: user.phone,
              qoyodCustomerId,
              status: 'success',
            };
          } catch (error) {
            this.logger.error(
              `Failed to create Qoyod customer for user ${user.userName}: ${error.message}`,
            );

            return {
              userId: user._id.toString(),
              userName: user.userName,
              phone: user.phone,
              status: 'failed',
              error: error.message,
            };
          }
        });

        // Wait for all promises in the batch to settle
        const batchResults = await Promise.allSettled(batchPromises);

        // Process results
        for (const result of batchResults) {
          if (result.status === 'fulfilled') {
            const userResult = result.value;
            results.push(userResult);

            if (userResult.status === 'success') {
              successCount++;
            } else {
              failedCount++;
            }
          } else {
            failedCount++;
            this.logger.error(`Unexpected error: ${result.reason}`);
          }
        }

        this.logger.log(
          `Batch ${
            i + 1
          }/${totalBatches} completed - Success: ${successCount}, Failed: ${failedCount}`,
        );

        // Add delay between batches (except for the last batch)
        if (i < totalBatches - 1) {
          this.logger.log(`Waiting ${delayMs}ms before next batch...`);
          await new Promise((resolve) => setTimeout(resolve, delayMs));
        }
      }

      this.logger.log(
        `Users sync completed - Total Success: ${successCount}, Total Failed: ${failedCount}`,
      );

      return {
        success: true,
        message: 'Users sync completed',
        synced: successCount,
        failed: failedCount,
        total: usersWithoutQoyod.length,
        results,
      };
    } catch (error) {
      this.logger.error(`Error during users sync: ${error.message}`);
      throw new InternalServerErrorException({
        ar: 'فشل في مزامنة المستخدمين مع Qoyod',
        en: 'Failed to sync users with Qoyod',
        details: error.message,
      });
    }
  }
}
