import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class ProductsService {
  constructor(private prisma: PrismaService) {}

  async findAll(query: { category?: string; search?: string; minPrice?: number; maxPrice?: number; page?: number; limit?: number }) {
    const page = query.page || 1;
    const limit = query.limit || 20;
    const skip = (page - 1) * limit;

    const where: any = {
      isPublished: true,
    };

    if (query.search) {
      where.OR = [
        { name: { contains: query.search, mode: 'insensitive' } },
        { description: { contains: query.search, mode: 'insensitive' } },
      ];
    }

    if (query.category) {
      where.category = {
        name: { equals: query.category, mode: 'insensitive' },
      };
    }

    if (query.minPrice || query.maxPrice) {
      where.price = {};
      if (query.minPrice) where.price.gte = query.minPrice;
      if (query.maxPrice) where.price.lte = query.maxPrice;
    }

    const [products, total] = await Promise.all([
      this.prisma.product.findMany({
        where,
        skip,
        take: limit,
        include: {
          farmer: { select: { farmName: true, farmAddress: true } },
          category: { select: { name: true, slug: true } },
          images: true,
        },
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.product.count({ where }),
    ]);

    return {
      success: true,
      data: products,
      meta: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async findOne(id: string) {
    const product = await this.prisma.product.findUnique({
      where: { id },
      include: {
        farmer: { select: { farmName: true, farmAddress: true, bio: true } },
        category: true,
        images: true,
        reviews: {
          take: 5,
          orderBy: { createdAt: 'desc' },
        },
      },
    });

    if (!product) {
      throw new NotFoundException(`Product with ID ${id} not found.`);
    }

    return {
      success: true,
      data: product,
    };
  }

  async create(farmerProfileId: string, dto: { name: string; description: string; categoryId: string; price: number; unit: string; stock: number }) {
    const product = await this.prisma.product.create({
      data: {
        farmerId: farmerProfileId,
        categoryId: dto.categoryId,
        name: dto.name,
        description: dto.description,
        price: dto.price,
        unit: dto.unit,
        stock: dto.stock,
      },
      include: {
        category: true,
      },
    });

    return {
      success: true,
      message: 'Product created successfully',
      data: product,
    };
  }
}
