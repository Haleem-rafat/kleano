import { IsIn, IsNotEmpty, IsOptional, IsString } from 'class-validator';

export enum ProductType {
  Service = 'Service',
  Product = 'Product',
}

export class CreateProductDto {
  @IsOptional()
  @IsString()
  sku?: string;

  @IsOptional()
  @IsString()
  barcode?: string;

  @IsNotEmpty()
  @IsString()
  name_ar: string;

  @IsNotEmpty()
  @IsString()
  name_en: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsNotEmpty()
  @IsString()
  product_unit_type_id: string;

  @IsNotEmpty()
  @IsString()
  category_id: string;

  @IsOptional()
  @IsIn(['0', '1'])
  track_quantity?: '0' | '1';

  @IsOptional()
  @IsIn(['0', '1'])
  purchase_item?: '0' | '1';

  @IsOptional()
  @IsString()
  buying_price?: string;

  @IsOptional()
  @IsString()
  expense_account_id?: string;

  @IsOptional()
  @IsIn(['0', '1'])
  sale_item?: '0' | '1';

  @IsOptional()
  @IsString()
  selling_price?: string;

  @IsOptional()
  @IsString()
  sales_account_id?: string;

  @IsOptional()
  @IsString()
  tax_id?: string;

  @IsOptional()
  @IsString()
  type?: ProductType;
}
