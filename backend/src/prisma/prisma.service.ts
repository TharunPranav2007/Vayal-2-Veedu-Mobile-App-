import { Injectable, OnModuleInit, OnModuleDestroy, Logger } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(PrismaService.name);

  async onModuleInit() {
    try {
      await this.$connect();
      this.logger.log('✅ PostgreSQL Database connected successfully via Prisma Client');
    } catch (error) {
      this.logger.warn(
        `⚠️ PostgreSQL Database connection deferred: ${error.message || error}.\n` +
        `   To connect to PostgreSQL, run 'docker-compose up -d' or set valid DATABASE_URL in backend/.env`,
      );
    }
  }

  async onModuleDestroy() {
    await this.$disconnect();
  }
}
