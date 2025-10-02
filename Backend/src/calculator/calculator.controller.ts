import { Body, Controller, HttpCode, HttpStatus, Post, Version } from '@nestjs/common';
import { ApiBadRequestResponse, ApiOkResponse, ApiTags } from '@nestjs/swagger';
import { CalculatorService } from './calculator.service';
import { CalculateDto } from './dto/calculate.dto';

@ApiTags('calculator')
@Controller('calculator')
export class CalculatorController {
  constructor(private readonly calculatorService: CalculatorService) {}

  @Version('1')
  @Post('add')
  @HttpCode(HttpStatus.OK)
  @ApiOkResponse({ schema: { properties: { result: { type: 'number' } } } })
  @ApiBadRequestResponse({ description: 'Validation error' })
  add(@Body() dto: CalculateDto) {
    return { result: this.calculatorService.add(dto.a, dto.b) };
  }

  @Version('1')
  @Post('subtract')
  @HttpCode(HttpStatus.OK)
  @ApiOkResponse({ schema: { properties: { result: { type: 'number' } } } })
  @ApiBadRequestResponse({ description: 'Validation error' })
  subtract(@Body() dto: CalculateDto) {
    return { result: this.calculatorService.subtract(dto.a, dto.b) };
  }

  @Version('1')
  @Post('multiply')
  @HttpCode(HttpStatus.OK)
  @ApiOkResponse({ schema: { properties: { result: { type: 'number' } } } })
  @ApiBadRequestResponse({ description: 'Validation error' })
  multiply(@Body() dto: CalculateDto) {
    return { result: this.calculatorService.multiply(dto.a, dto.b) };
  }

  @Version('1')
  @Post('divide')
  @HttpCode(HttpStatus.OK)
  @ApiOkResponse({ schema: { properties: { result: { type: 'number' } } } })
  @ApiBadRequestResponse({ description: 'b must not be zero for division' })
  divide(@Body() dto: CalculateDto) {
    return { result: this.calculatorService.divide(dto.a, dto.b) };
  }
}


