import { INestApplication, ValidationPipe, VersioningType } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import request from 'supertest';
import { AppModule } from '../src/app.module';

describe('CalculatorController (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.useGlobalPipes(
      new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true, transform: true }),
    );
    app.enableVersioning({ type: VersioningType.URI });
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  it('/v1/calculator/add (POST)', async () => {
    await request(app.getHttpServer())
      .post('/v1/calculator/add')
      .send({ a: 2, b: 3 })
      .expect(200)
      .expect(({ body }) => expect(body.result).toBe(5));
  });

  it('/v1/calculator/subtract (POST)', async () => {
    await request(app.getHttpServer())
      .post('/v1/calculator/subtract')
      .send({ a: 5, b: 3 })
      .expect(200)
      .expect(({ body }) => expect(body.result).toBe(2));
  });

  it('/v1/calculator/multiply (POST)', async () => {
    await request(app.getHttpServer())
      .post('/v1/calculator/multiply')
      .send({ a: 4, b: 3 })
      .expect(200)
      .expect(({ body }) => expect(body.result).toBe(12));
  });

  it('/v1/calculator/divide (POST)', async () => {
    await request(app.getHttpServer())
      .post('/v1/calculator/divide')
      .send({ a: 10, b: 2 })
      .expect(200)
      .expect(({ body }) => expect(body.result).toBe(5));
  });

  it('/v1/calculator/divide (POST) - division by zero', async () => {
    await request(app.getHttpServer())
      .post('/v1/calculator/divide')
      .send({ a: 10, b: 0 })
      .expect(400);
  });

  it('/v1/calculator/add (POST) - invalid payload', async () => {
    await request(app.getHttpServer())
      .post('/v1/calculator/add')
      .send({ a: 'x', b: 2 })
      .expect(400);
  });
});


