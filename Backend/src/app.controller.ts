import { Controller, Get } from '@nestjs/common';
import { AppService } from './app.service';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  getHello(): string {
    return this.appService.getHello();
  }

  @Get('health')
  getHealth() {
    return {
      status: 'ok',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      service: 'calculator-api',
      version: '1.0.0'
    };
  }

  @Get('health/ready')
  getReadiness() {
    // Add any readiness checks here (database, external services, etc.)
    return {
      status: 'ready',
      timestamp: new Date().toISOString(),
      checks: {
        database: 'ok', // Replace with actual DB check if needed
        memory: 'ok',
        disk: 'ok'
      }
    };
  }

  @Get('health/live')
  getLiveness() {
    // Basic liveness check - if this fails, pod should be restarted
    return {
      status: 'alive',
      timestamp: new Date().toISOString(),
      pid: process.pid,
      memory: process.memoryUsage()
    };
  }
}
