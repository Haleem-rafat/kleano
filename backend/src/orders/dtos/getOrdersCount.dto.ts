import { IsString } from 'class-validator';

export class GetOrdersCountDTO {
  @IsString()
  status: string;
}
