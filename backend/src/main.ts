import 'dotenv/config';
import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import helmet from 'helmet';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Enable HTTP Security Headers
  app.use(helmet());

  // Enable CORS
  app.enableCors({
    origin: process.env.CORS_ORIGIN || '*',
    credentials: true,
  });

  // Global Prefix
  app.setGlobalPrefix('api/v1');

  // Strict Request Body DTO Validation
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: {
        enableImplicitConversion: true,
      },
    }),
  );

  // Setup Swagger OpenAPI Documentation
  const config = new DocumentBuilder()
    .setTitle('FarmDirect (Vayal 2 Veedu) API')
    .setDescription('Direct Farmer-to-Consumer Digital Marketplace REST API Documentation')
    .setVersion('1.0')
    .addBearerAuth()
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document);

  const port = process.env.PORT || 3000;
  await app.listen(port);
  console.log(`🚀 NestJS Backend running on: http://localhost:${port}/api/v1`);
  console.log(`📚 Swagger OpenAPI available on: http://localhost:${port}/api/docs`);
}
bootstrap();
