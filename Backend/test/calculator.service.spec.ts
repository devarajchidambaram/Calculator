import { CalculatorService } from '../src/calculator/calculator.service';
import { BadRequestException } from '@nestjs/common';

describe('CalculatorService', () => {
  let service: CalculatorService;

  beforeEach(() => {
    service = new CalculatorService();
  });

  it('adds numbers', () => {
    expect(service.add(1, 2)).toBe(3);
  });

  it('subtracts numbers', () => {
    expect(service.subtract(5, 3)).toBe(2);
  });

  it('multiplies numbers', () => {
    expect(service.multiply(4, 3)).toBe(12);
  });

  it('divides numbers', () => {
    expect(service.divide(10, 2)).toBe(5);
  });

  it('throws on divide by zero', () => {
    expect(() => service.divide(10, 0)).toThrow(BadRequestException);
  });
});


