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

  // Auto-scaling test endpoints
  @Version('1')
  @Post('fibonacci')
  @HttpCode(HttpStatus.OK)
  @ApiOkResponse({ schema: { properties: { result: { type: 'number' }, iterations: { type: 'number' } } } })
  @ApiBadRequestResponse({ description: 'Invalid input' })
  fibonacci(@Body() dto: { n: number }) {
    return this.calculatorService.fibonacci(dto.n);
  }

  @Version('1')
  @Post('prime-check')
  @HttpCode(HttpStatus.OK)
  @ApiOkResponse({ schema: { properties: { result: { type: 'boolean' }, primes: { type: 'array' } } } })
  @ApiBadRequestResponse({ description: 'Invalid input' })
  primeCheck(@Body() dto: { n: number }) {
    return this.calculatorService.findPrimesUpTo(dto.n);
  }

  @Version('1')
  @Post('matrix-multiply')
  @HttpCode(HttpStatus.OK)
  @ApiOkResponse({ schema: { properties: { result: { type: 'array' }, size: { type: 'number' } } } })
  @ApiBadRequestResponse({ description: 'Invalid input' })
  matrixMultiply(@Body() dto: { size: number }) {
    return this.calculatorService.matrixMultiply(dto.size);
  }

  @Version('1')
  @Post('memory-test')
  @HttpCode(HttpStatus.OK)
  @ApiOkResponse({ schema: { properties: { result: { type: 'string' }, memoryUsed: { type: 'number' } } } })
  @ApiBadRequestResponse({ description: 'Invalid input' })
  memoryTest(@Body() dto: { size: number }) {
    return this.calculatorService.memoryIntensiveOperation(dto.size);
  }
}


