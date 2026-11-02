import 'dotenv/config';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import { AdminService } from './admin/admin.service';
import { NestFactory } from '@nestjs/core';
import * as express from 'express';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, { bufferLogs: true });
  app.use(express.json({ limit: '10mb' }));
  app.use(express.urlencoded({ extended: true, limit: '10mb' }));
  app.setGlobalPrefix('api/');
  app.useGlobalPipes(new ValidationPipe());

  app.enableCors({
    origin: true,
    methods: '*',
    allowedHeaders: '*',
    optionsSuccessStatus: 204,
  });

  await app.listen(process.env.PORT || 3000);
  const adminService = app.get(AdminService);

  await adminService.injectSuperAdmin();
}
bootstrap();
