import { BadRequestException, Injectable } from '@nestjs/common';

@Injectable()
export class CalculatorService {
  add(a: number, b: number): number {
    return a + b;
  }

  subtract(a: number, b: number): number {
    return a - b;
  }

  multiply(a: number, b: number): number {
    return a * b;
  }

  divide(a: number, b: number): number {
    if (b === 0) {
      throw new BadRequestException('b must not be zero for division');
    }
    return a / b;
  }

  // Auto-scaling test methods
  fibonacci(n: number): { result: number; iterations: number } {
    if (n < 0) {
      throw new BadRequestException('n must be non-negative');
    }
    if (n > 40) {
      throw new BadRequestException('n must be <= 40 to prevent excessive CPU usage');
    }

    let iterations = 0;
    const result = this.fibonacciRecursive(n, iterations);
    return { result: result.result, iterations: result.iterations };
  }

  private fibonacciRecursive(n: number, iterations: number): { result: number; iterations: number } {
    iterations++;
    if (n <= 1) {
      return { result: n, iterations };
    }
    const fib1 = this.fibonacciRecursive(n - 1, iterations);
    const fib2 = this.fibonacciRecursive(n - 2, fib1.iterations);
    return { result: fib1.result + fib2.result, iterations: fib2.iterations };
  }

  findPrimesUpTo(n: number): { result: boolean; primes: number[] } {
    if (n < 2) {
      throw new BadRequestException('n must be >= 2');
    }
    if (n > 10000) {
      throw new BadRequestException('n must be <= 10000 to prevent excessive CPU usage');
    }

    const primes: number[] = [];
    const isPrime = new Array(n + 1).fill(true);
    isPrime[0] = isPrime[1] = false;

    for (let i = 2; i * i <= n; i++) {
      if (isPrime[i]) {
        for (let j = i * i; j <= n; j += i) {
          isPrime[j] = false;
        }
      }
    }

    for (let i = 2; i <= n; i++) {
      if (isPrime[i]) {
        primes.push(i);
      }
    }

    return { result: true, primes };
  }

  matrixMultiply(size: number): { result: number[][]; size: number } {
    if (size < 2 || size > 100) {
      throw new BadRequestException('size must be between 2 and 100');
    }

    // Create two random matrices
    const matrixA = this.generateRandomMatrix(size);
    const matrixB = this.generateRandomMatrix(size);
    
    // Multiply matrices
    const result = this.multiplyMatrices(matrixA, matrixB);
    
    return { result, size };
  }

  private generateRandomMatrix(size: number): number[][] {
    const matrix: number[][] = [];
    for (let i = 0; i < size; i++) {
      matrix[i] = [];
      for (let j = 0; j < size; j++) {
        matrix[i][j] = Math.random() * 100;
      }
    }
    return matrix;
  }

  private multiplyMatrices(a: number[][], b: number[][]): number[][] {
    const size = a.length;
    const result: number[][] = [];
    
    for (let i = 0; i < size; i++) {
      result[i] = [];
      for (let j = 0; j < size; j++) {
        result[i][j] = 0;
        for (let k = 0; k < size; k++) {
          result[i][j] += a[i][k] * b[k][j];
        }
      }
    }
    return result;
  }

  memoryIntensiveOperation(size: number): { result: string; memoryUsed: number } {
    if (size < 1 || size > 1000) {
      throw new BadRequestException('size must be between 1 and 1000');
    }

    // Create a large array to consume memory
    const largeArray: number[] = [];
    for (let i = 0; i < size * 1000; i++) {
      largeArray.push(Math.random());
    }

    // Perform some operations on the array
    const sum = largeArray.reduce((acc, val) => acc + val, 0);
    const avg = sum / largeArray.length;

    // Get memory usage
    const memoryUsed = process.memoryUsage().heapUsed / 1024 / 1024; // MB

    return { 
      result: `Processed ${largeArray.length} elements, sum: ${sum.toFixed(2)}, avg: ${avg.toFixed(2)}`, 
      memoryUsed: Math.round(memoryUsed * 100) / 100 
    };
  }
}


