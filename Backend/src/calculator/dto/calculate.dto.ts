import { ApiProperty } from '@nestjs/swagger';
import { IsNumber } from 'class-validator';

export class CalculateDto {
  @ApiProperty({ example: 12.5 })
  @IsNumber()
  a!: number;

  @ApiProperty({ example: 3.5 })
  @IsNumber()
  b!: number;
}


