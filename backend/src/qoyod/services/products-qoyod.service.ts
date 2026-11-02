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
import { AddOnsRepository } from 'src/add-ons/repositories/add-ons.repository';
import { LocalizedText } from 'src/common/types/localized-text.type';
import { PlansRepository } from 'src/plans/repositories/plans.repoistory';
import { WashingServicesRepository } from 'src/washing-services/repositories/washing-services.repository';
import { CreateProductDto, ProductType } from '../dtos/create-product.dto';
import { UpdateProductDto } from '../dtos/update-product.dto';

@Injectable()
export class ProductsQoyodService {
  private readonly logger = new Logger(ProductsQoyodService.name);
  private readonly apiKey: string;
  private readonly baseUrl: string;

  constructor(
    private readonly httpService: HttpService,
    private readonly addOnsRepository: AddOnsRepository,
    private readonly washingServicesRepository: WashingServicesRepository,
    private readonly plansRepository: PlansRepository,
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
   * Create a new product in Qoyod
   * @param createProductDto - Product details
   * @returns Created product response
   */
  async createProduct(createProductDto: CreateProductDto) {
    try {
      this.logger.log('Creating product in Qoyod');

      const productData = {
        product: {
          sku: createProductDto.sku || '',
          barcode: createProductDto.barcode || '',
          name_ar: createProductDto.name_ar,
          name_en: createProductDto.name_en,
          description: createProductDto.description || '',
          product_unit_type_id: createProductDto.product_unit_type_id,
          category_id: createProductDto.category_id,
          track_quantity: createProductDto.track_quantity || '0',
          purchase_item: createProductDto.purchase_item || '0',
          buying_price: createProductDto.buying_price || '0',
          expense_account_id: createProductDto.expense_account_id || '',
          sale_item: createProductDto.sale_item || '0',
          selling_price: createProductDto.selling_price || '0',
          sales_account_id: createProductDto.sales_account_id || '',
          tax_id: createProductDto.tax_id || '',
          type: createProductDto.type,
        },
      };

      const response = await firstValueFrom(
        this.httpService
          .post(`${this.baseUrl}/products`, productData, {
            headers: this.getHeaders(),
          })
          .pipe(
            map((res) => res.data),
            catchError((error) => {
              this.logger.error(
                `Failed to create product: ${
                  error.response?.data?.message || error.message
                }`,
              );
              this.logger.error(`Response status: ${error.response?.status}`);
              this.logger.error(
                `Response data: ${JSON.stringify(error.response?.data)}`,
              );
              this.logger.error(`Request URL: ${this.baseUrl}/products`);
              throw this.handleApiError(error);
            }),
          ),
      );

      this.logger.log(
        `Product created successfully. Response: ${JSON.stringify(response)}`,
      );

      // Extract product ID from response (Qoyod returns it in response.product.id)
      const productId = response?.product?.id || response?.id || null;

      return {
        ...response,
        id: productId,
      };
    } catch (error) {
      if (
        error instanceof BadRequestException ||
        error instanceof InternalServerErrorException
      ) {
        throw error;
      }
      this.logger.error(`Unexpected error creating product: ${error.message}`);
      throw new InternalServerErrorException({
        ar: 'فشل في إنشاء المنتج',
        en: 'Failed to create product',
      });
    }
  }

  /**
   * Get product details by ID
   * @param productId - Product ID
   * @returns Product details
   */
  async getProduct(productId: string) {
    try {
      this.logger.log(`Fetching product: ${productId}`);

      const response = await firstValueFrom(
        this.httpService
          .get(`${this.baseUrl}/products/${productId}`, {
            headers: this.getHeaders(),
          })
          .pipe(
            map((res) => res.data),
            catchError((error) => {
              this.logger.error(
                `Failed to fetch product: ${
                  error.response?.data?.message || error.message
                }`,
              );
              throw this.handleApiError(error);
            }),
          ),
      );

      this.logger.log(`Product fetched successfully: ${productId}`);
      return response;
    } catch (error) {
      if (
        error instanceof NotFoundException ||
        error instanceof InternalServerErrorException
      ) {
        throw error;
      }
      this.logger.error(`Unexpected error fetching product: ${error.message}`);
      throw new InternalServerErrorException({
        ar: 'فشل في جلب المنتج',
        en: 'Failed to fetch product',
      });
    }
  }

  /**
   * List all products with optional filters
   * @param params - Query parameters
   * @returns List of products
   */
  async listProducts(params?: {
    page?: number;
    per_page?: number;
    category_id?: string;
  }) {
    try {
      this.logger.log('Fetching products list');

      const queryParams = new URLSearchParams();
      if (params) {
        Object.entries(params).forEach(([key, value]) => {
          if (value !== undefined && value !== null) {
            queryParams.append(key, value.toString());
          }
        });
      }

      const url = `${this.baseUrl}/products${
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
                `Failed to fetch products: ${
                  error.response?.data?.message || error.message
                }`,
              );
              throw this.handleApiError(error);
            }),
          ),
      );

      this.logger.log('Products list fetched successfully');
      return response;
    } catch (error) {
      if (error instanceof InternalServerErrorException) {
        throw error;
      }
      this.logger.error(`Unexpected error fetching products: ${error.message}`);
      throw new InternalServerErrorException({
        ar: 'فشل في جلب قائمة المنتجات',
        en: 'Failed to fetch products list',
      });
    }
  }

  /**
   * Update product details
   * @param productId - Product ID
   * @param updateProductDto - Updated product details
   * @returns Updated product response
   */
  async updateProduct(productId: string, updateProductDto: UpdateProductDto) {
    try {
      this.logger.log(`Updating product: ${productId}`);

      const productData = {
        product: {
          name_ar: updateProductDto.name_ar,
          name_en: updateProductDto.name_en,
          selling_price: updateProductDto.selling_price,
        },
      };

      const response = await firstValueFrom(
        this.httpService
          .put(`${this.baseUrl}/products/${productId}`, productData, {
            headers: this.getHeaders(),
          })
          .pipe(
            map((res) => res.data),
            catchError((error) => {
              this.logger.error(
                `Failed to update product: ${
                  error.response?.data?.message || error.message
                }`,
              );
              throw this.handleApiError(error);
            }),
          ),
      );

      this.logger.log(`Product updated successfully: ${productId}`);
      return response;
    } catch (error) {
      if (
        error instanceof NotFoundException ||
        error instanceof BadRequestException ||
        error instanceof InternalServerErrorException
      ) {
        throw error;
      }
      this.logger.error(`Unexpected error updating product: ${error.message}`);
      throw new InternalServerErrorException({
        ar: 'فشل في تحديث المنتج',
        en: 'Failed to update product',
      });
    }
  }

  /**
   * Delete a product
   * @param productId - Product ID
   */
  async deleteProduct(productId: string) {
    try {
      this.logger.log(`Deleting product: ${productId}`);

      await firstValueFrom(
        this.httpService
          .delete(`${this.baseUrl}/products/${productId}`, {
            headers: this.getHeaders(),
          })
          .pipe(
            catchError((error) => {
              this.logger.error(
                `Failed to delete product: ${
                  error.response?.data?.message || error.message
                }`,
              );
              throw this.handleApiError(error);
            }),
          ),
      );

      this.logger.log(`Product deleted successfully: ${productId}`);
    } catch (error) {
      if (
        error instanceof NotFoundException ||
        error instanceof InternalServerErrorException
      ) {
        throw error;
      }
      this.logger.error(`Unexpected error deleting product: ${error.message}`);
      throw new InternalServerErrorException({
        ar: 'فشل في حذف المنتج',
        en: 'Failed to delete product',
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
          ar: 'المنتج غير موجود',
          en: message || 'Product not found',
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

  @OnEvent('add-ons.created')
  async createProductFromAddOns({
    addOnsId,
    addOnsName,
    addOnsPrice,
  }: {
    addOnsId: string;
    addOnsName: LocalizedText;
    addOnsPrice: number;
  }) {
    try {
      const product = await this.createProduct({
        sku: addOnsId,
        name_ar: addOnsName.ar,
        name_en: addOnsName.en,
        selling_price: addOnsPrice.toString(),
        track_quantity: '0',
        product_unit_type_id: '7',
        category_id: '1',
        tax_id: '1',
        type: ProductType.Product,
        sale_item: '1',
        sales_account_id: '17',
      });

      await this.addOnsRepository.update(addOnsId, {
        qoyodProductId: product.id,
      });
    } catch (error) {
      this.logger.error(
        `Error creating qoyod product from add-ons: ${error.message}`,
      );
    }
  }

  // TODO: On event add-ons.updated, update the qoyod product
  @OnEvent('add-ons.updated')
  async updateProductFromAddOns({
    addOnsQoyodProductId,
    addOnsName,
    addOnsPrice,
  }: {
    addOnsQoyodProductId: number;
    addOnsName: LocalizedText;
    addOnsPrice: number;
  }) {
    try {
      await this.updateProduct(addOnsQoyodProductId.toString(), {
        name_ar: addOnsName.ar,
        name_en: addOnsName.en,
        selling_price: addOnsPrice.toString(),
      });
    } catch (error) {
      this.logger.error(
        `Error updating qoyod product from add-ons: ${error.message}`,
      );
    }
  }

  @OnEvent('washing-services.created')
  async createProductFromWashingService({
    washingServiceId,
    washingServiceName,
    washingServicePrice,
  }: {
    washingServiceId: string;
    washingServiceName: LocalizedText;
    washingServicePrice: number;
  }) {
    try {
      const product = await this.createProduct({
        sku: washingServiceId,
        name_ar: washingServiceName.ar,
        name_en: washingServiceName.en,
        selling_price: washingServicePrice.toString(),
        track_quantity: '0',
        product_unit_type_id: '7',
        category_id: '1',
        tax_id: '1',
        type: ProductType.Service,
        sale_item: '1',
        sales_account_id: '17',
      });

      await this.washingServicesRepository.update(washingServiceId, {
        qoyodProductId: product.id || null,
      });
    } catch (error) {
      this.logger.error(
        `Error creating qoyod product from washing-service: ${error.message}`,
      );
    }
  }

  @OnEvent('washing-services.updated')
  async updateProductFromWashingService({
    washingServiceQoyodProductId,
    washingServiceName,
    washingServicePrice,
  }: {
    washingServiceQoyodProductId: number;
    washingServiceName: LocalizedText;
    washingServicePrice: number;
  }) {
    try {
      await this.updateProduct(washingServiceQoyodProductId.toString(), {
        name_ar: washingServiceName.ar,
        name_en: washingServiceName.en,
        selling_price: washingServicePrice.toString(),
      });
    } catch (error) {
      this.logger.error(
        `Error updating qoyod product from washing-service: ${error.message}`,
      );
    }
  }

  @OnEvent('plans.created')
  async createProductFromPlan({
    planId,
    planType,
    planPrice,
  }: {
    planId: string;
    planType: LocalizedText;
    planPrice: number;
  }) {
    try {
      const product = await this.createProduct({
        sku: planId,
        name_ar: planType.ar,
        name_en: planType.en,
        selling_price: planPrice.toString(),
        track_quantity: '0',
        product_unit_type_id: '7',
        category_id: '1',
        tax_id: '1',
        type: ProductType.Service,
        sale_item: '1',
        sales_account_id: '17',
      });

      await this.plansRepository.update(planId, {
        qoyodProductId: product.id || null,
      });
    } catch (error) {
      this.logger.error(
        `Error creating qoyod product from plan: ${error.message}`,
      );
    }
  }

  @OnEvent('plans.updated')
  async updateProductFromPlan({
    planQoyodProductId,
    planType,
    planPrice,
  }: {
    planQoyodProductId: number;
    planType: LocalizedText;
    planPrice: number;
  }) {
    try {
      await this.updateProduct(planQoyodProductId.toString(), {
        name_ar: planType.ar,
        name_en: planType.en,
        selling_price: planPrice.toString(),
      });
    } catch (error) {
      this.logger.error(
        `Error updating qoyod product from plan: ${error.message}`,
      );
    }
  }

  /**
   * Sync all add-ons without Qoyod products
   * Creates Qoyod products for all add-ons that don't have one
   * Processes in batches with delays to avoid rate limits
   * @param batchSize - Number of items to process per batch (default: 20)
   * @param delayMs - Delay between batches in milliseconds (default: 1000)
   * @returns Summary of sync operation
   */
  async syncAddOns(batchSize = 20, delayMs = 1000) {
    this.logger.log('Starting add-ons sync with Qoyod');

    try {
      // Get all add-ons without qoyodProductId
      const addOnsWithoutQoyod =
        await this.addOnsRepository.findAllWithoutQoyodProduct();

      if (addOnsWithoutQoyod.length === 0) {
        this.logger.log('No add-ons to sync - all have Qoyod products');
        return {
          success: true,
          message: 'All add-ons are already synced with Qoyod',
          synced: 0,
          failed: 0,
          total: 0,
          results: [],
        };
      }

      this.logger.log(
        `Found ${addOnsWithoutQoyod.length} add-ons without Qoyod products`,
      );
      this.logger.log(
        `Processing in batches of ${batchSize} with ${delayMs}ms delay between batches`,
      );

      const results = [];
      let successCount = 0;
      let failedCount = 0;

      // Process add-ons in batches
      const totalBatches = Math.ceil(addOnsWithoutQoyod.length / batchSize);

      for (let i = 0; i < totalBatches; i++) {
        const start = i * batchSize;
        const end = Math.min(start + batchSize, addOnsWithoutQoyod.length);
        const batch = addOnsWithoutQoyod.slice(start, end);

        this.logger.log(
          `Processing batch ${i + 1}/${totalBatches} (add-ons ${
            start + 1
          }-${end})`,
        );

        // Process batch sequentially to avoid overwhelming the API
        for (const addOn of batch) {
          try {
            this.logger.debug(
              `Creating Qoyod product for add-on: ${addOn.name} (${addOn._id})`,
            );

            const product = await this.createProduct({
              sku: addOn._id.toString(),
              name_ar: addOn.name.ar,
              name_en: addOn.name.en,
              selling_price: addOn.price.toString(),
              track_quantity: '0',
              product_unit_type_id: '7',
              category_id: '1',
              tax_id: '1',
              type: ProductType.Product,
              sale_item: '1',
              sales_account_id: '17',
            });

            // Update add-on with qoyodProductId
            await this.addOnsRepository.update(addOn._id.toString(), {
              qoyodProductId: product.id || null,
            });

            successCount++;
            results.push({
              addOnId: addOn._id.toString(),
              addOnName: addOn.name,
              qoyodProductId: product.id,
              status: 'success',
            });
          } catch (error) {
            failedCount++;
            results.push({
              addOnId: addOn._id.toString(),
              addOnName: addOn.name,
              status: 'failed',
              error: error.message,
            });

            this.logger.error(
              `Failed to create Qoyod product for add-on ${addOn.name}: ${error.message}`,
            );
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
        `Add-ons sync completed - Total Success: ${successCount}, Total Failed: ${failedCount}`,
      );

      return {
        success: true,
        message: 'Add-ons sync completed',
        synced: successCount,
        failed: failedCount,
        total: addOnsWithoutQoyod.length,
        results,
      };
    } catch (error) {
      this.logger.error(`Error during add-ons sync: ${error.message}`);
      throw new InternalServerErrorException({
        ar: 'فشل في مزامنة الإضافات مع Qoyod',
        en: 'Failed to sync add-ons with Qoyod',
        details: error.message,
      });
    }
  }

  /**
   * Sync all washing services without Qoyod products
   * Creates Qoyod products for all washing services that don't have one
   * Processes in batches with delays to avoid rate limits
   * @param batchSize - Number of items to process per batch (default: 20)
   * @param delayMs - Delay between batches in milliseconds (default: 1000)
   * @returns Summary of sync operation
   */
  async syncWashingServices(batchSize = 20, delayMs = 1000) {
    this.logger.log('Starting washing services sync with Qoyod');

    try {
      // Get all washing services without qoyodProductId
      const washingServicesWithoutQoyod =
        await this.washingServicesRepository.findAllWithoutQoyodProduct();

      if (washingServicesWithoutQoyod.length === 0) {
        this.logger.log(
          'No washing services to sync - all have Qoyod products',
        );
        return {
          success: true,
          message: 'All washing services are already synced with Qoyod',
          synced: 0,
          failed: 0,
          total: 0,
          results: [],
        };
      }

      this.logger.log(
        `Found ${washingServicesWithoutQoyod.length} washing services without Qoyod products`,
      );
      this.logger.log(
        `Processing in batches of ${batchSize} with ${delayMs}ms delay between batches`,
      );

      const results = [];
      let successCount = 0;
      let failedCount = 0;

      // Process washing services in batches
      const totalBatches = Math.ceil(
        washingServicesWithoutQoyod.length / batchSize,
      );

      for (let i = 0; i < totalBatches; i++) {
        const start = i * batchSize;
        const end = Math.min(
          start + batchSize,
          washingServicesWithoutQoyod.length,
        );
        const batch = washingServicesWithoutQoyod.slice(start, end);

        this.logger.log(
          `Processing batch ${i + 1}/${totalBatches} (services ${
            start + 1
          }-${end})`,
        );

        // Process batch sequentially to avoid overwhelming the API
        for (const washingService of batch) {
          try {
            this.logger.debug(
              `Creating Qoyod product for washing service: ${washingService.name} (${washingService._id})`,
            );

            const product = await this.createProduct({
              sku: washingService._id.toString(),
              name_ar: washingService.name.ar,
              name_en: washingService.name.en,
              selling_price: washingService.price.toString(),
              track_quantity: '0',
              product_unit_type_id: '7',
              category_id: '1',
              tax_id: '1',
              type: ProductType.Service,
              sale_item: '1',
              sales_account_id: '17',
            });

            // Update washing service with qoyodProductId
            await this.washingServicesRepository.update(
              washingService._id.toString(),
              {
                qoyodProductId: product.id,
              },
            );

            successCount++;
            results.push({
              washingServiceId: washingService._id.toString(),
              washingServiceName: washingService.name,
              qoyodProductId: product.id,
              status: 'success',
            });
          } catch (error) {
            failedCount++;
            results.push({
              washingServiceId: washingService._id.toString(),
              washingServiceName: washingService.name,
              status: 'failed',
              error: error.message,
            });

            this.logger.error(
              `Failed to create Qoyod product for washing service ${washingService.name}: ${error.message}`,
            );
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
        `Washing services sync completed - Total Success: ${successCount}, Total Failed: ${failedCount}`,
      );

      return {
        success: true,
        message: 'Washing services sync completed',
        synced: successCount,
        failed: failedCount,
        total: washingServicesWithoutQoyod.length,
        results,
      };
    } catch (error) {
      this.logger.error(`Error during washing services sync: ${error.message}`);
      throw new InternalServerErrorException({
        ar: 'فشل في مزامنة خدمات الغسيل مع Qoyod',
        en: 'Failed to sync washing services with Qoyod',
        details: error.message,
      });
    }
  }

  async syncPlans(batchSize = 20, delayMs = 1000) {
    this.logger.log('Starting plans sync with Qoyod');

    try {
      // Get all plans without qoyodProductId
      const plansWithoutQoyod =
        await this.plansRepository.findAllWithoutQoyodProduct();

      if (plansWithoutQoyod.length === 0) {
        this.logger.log('No plans to sync - all have Qoyod products');
        return {
          success: true,
          message: 'All plans are already synced with Qoyod',
          synced: 0,
          failed: 0,
          total: 0,
          results: [],
        };
      }

      this.logger.log(
        `Found ${plansWithoutQoyod.length} plans without Qoyod products`,
      );
      this.logger.log(
        `Processing in batches of ${batchSize} with ${delayMs}ms delay between batches`,
      );

      const results = [];
      let successCount = 0;
      let failedCount = 0;

      // Process plans in batches
      const totalBatches = Math.ceil(plansWithoutQoyod.length / batchSize);

      for (let i = 0; i < totalBatches; i++) {
        const start = i * batchSize;
        const end = Math.min(start + batchSize, plansWithoutQoyod.length);
        const batch = plansWithoutQoyod.slice(start, end);

        this.logger.log(
          `Processing batch ${i + 1}/${totalBatches} (plans ${
            start + 1
          }-${end})`,
        );

        // Process batch sequentially to avoid overwhelming the API
        for (const plan of batch) {
          try {
            this.logger.debug(
              `Creating Qoyod product for plan: ${plan.type} (${plan._id})`,
            );

            const product = await this.createProduct({
              sku: plan._id.toString(),
              name_ar: plan.type.ar,
              name_en: plan.type.en,
              selling_price: plan.price.toString(),
              track_quantity: '0',
              product_unit_type_id: '7',
              category_id: '1',
              tax_id: '1',
              type: ProductType.Service,
              sale_item: '1',
              sales_account_id: '17',
            });

            // Update plan with qoyodProductId
            await this.plansRepository.update(plan._id.toString(), {
              qoyodProductId: product.id || null,
            });

            successCount++;
            results.push({
              planId: plan._id.toString(),
              planType: plan.type,
              qoyodProductId: product.id,
              status: 'success',
            });

            this.logger.debug(
              `Successfully synced plan: ${plan.type} (Qoyod Product ID: ${product.id})`,
            );
          } catch (error) {
            failedCount++;
            this.logger.error(
              `Failed to sync plan ${plan.type}: ${error.message}`,
            );

            results.push({
              planId: plan._id.toString(),
              planType: plan.type,
              status: 'failed',
              error: error.message,
            });
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
        `Plans sync completed - Total Success: ${successCount}, Total Failed: ${failedCount}`,
      );

      return {
        success: true,
        message: 'Plans sync completed',
        synced: successCount,
        failed: failedCount,
        total: plansWithoutQoyod.length,
        results,
      };
    } catch (error) {
      this.logger.error(`Error during plans sync: ${error.message}`);
      throw new InternalServerErrorException({
        ar: 'فشل في مزامنة الباقات مع Qoyod',
        en: 'Failed to sync plans with Qoyod',
        details: error.message,
      });
    }
  }
}
