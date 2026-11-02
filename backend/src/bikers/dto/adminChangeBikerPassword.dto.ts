import { IsNotEmpty, IsString, Length } from 'class-validator';

export class AdminChangeBikerPasswordDto {
  @IsNotEmpty()
  @IsString()
  @Length(8, 255)
  password: string;
}
