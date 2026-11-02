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
import { CreateProductDto } from '../dtos/create-product.dto';
import { UpdateProductDto } from '../dtos/update-product.dto';
import { ProductsQoyodService } from '../services/products-qoyod.service';

/**
 * Qoyod Products Controller
 * Handles product management in Qoyod
 */
@Controller('qoyod/products')
export class ProductsQoyodController {
  constructor(private readonly productsQoyodService: ProductsQoyodService) {}

  /**
   * Create a new product
   * POST /qoyod/products
   */
  @Post()
  async createProduct(@Body() createProductDto: CreateProductDto) {
    return await this.productsQoyodService.createProduct(createProductDto);
  }

  /**
   * Get product details by ID
   * GET /qoyod/products/:id
   */
  @Get(':id')
  async getProduct(@Param('id') id: string) {
    return await this.productsQoyodService.getProduct(id);
  }

  /**
   * List all products with optional filters
   * GET /qoyod/products
   */
  @Get()
  async listProducts(
    @Query('page') page?: number,
    @Query('per_page') perPage?: number,
    @Query('category_id') categoryId?: string,
  ) {
    return await this.productsQoyodService.listProducts({
      page,
      per_page: perPage,
      category_id: categoryId,
    });
  }

  /**
   * Update product details
   * PUT /qoyod/products/:id
   */
  @Put(':id')
  async updateProduct(
    @Param('id') id: string,
    @Body() updateProductDto: UpdateProductDto,
  ) {
    return await this.productsQoyodService.updateProduct(id, updateProductDto);
  }

  /**
   * Delete a product
   * DELETE /qoyod/products/:id
   */
  @Delete(':id')
  async deleteProduct(@Param('id') id: string) {
    await this.productsQoyodService.deleteProduct(id);
    return {
      message: {
        ar: 'تم حذف المنتج بنجاح',
        en: 'Product deleted successfully',
      },
    };
  }

  /**
   * Sync add-ons with Qoyod
   * Creates Qoyod products for all add-ons that don't have one
   * POST /qoyod/products/sync/add-ons
   * @param batchSize - Number of items to process per batch (default: 20)
   * @param delayMs - Delay between batches in milliseconds (default: 1000)
   */
  @Post('sync/add-ons')
  async syncAddOns(
    @Query('batchSize') batchSize?: number,
    @Query('delayMs') delayMs?: number,
  ) {
    return await this.productsQoyodService.syncAddOns(
      batchSize ? Number(batchSize) : 20,
      delayMs ? Number(delayMs) : 1000,
    );
  }

  /**
   * Sync washing services with Qoyod
   * Creates Qoyod products for all washing services that don't have one
   * POST /qoyod/products/sync/washing-services
   * @param batchSize - Number of items to process per batch (default: 20)
   * @param delayMs - Delay between batches in milliseconds (default: 1000)
   */
  @Post('sync/washing-services')
  async syncWashingServices(
    @Query('batchSize') batchSize?: number,
    @Query('delayMs') delayMs?: number,
  ) {
    return await this.productsQoyodService.syncWashingServices(
      batchSize ? Number(batchSize) : 20,
      delayMs ? Number(delayMs) : 1000,
    );
  }

  /**
   * Sync plans with Qoyod
   * Creates Qoyod products for all plans that don't have one
   * POST /qoyod/products/sync/plans
   * @param batchSize - Number of items to process per batch (default: 20)
   * @param delayMs - Delay between batches in milliseconds (default: 1000)
   */
  @Post('sync/plans')
  async syncPlans(
    @Query('batchSize') batchSize?: number,
    @Query('delayMs') delayMs?: number,
  ) {
    return await this.productsQoyodService.syncPlans(
      batchSize ? Number(batchSize) : 20,
      delayMs ? Number(delayMs) : 1000,
    );
  }
}
