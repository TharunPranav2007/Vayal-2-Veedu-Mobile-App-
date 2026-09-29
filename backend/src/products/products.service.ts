import { Injectable, NotFoundException, ForbiddenException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { Role } from '@prisma/client';
import { AuthenticatedUser } from '../common/decorators/current-user.decorator';

export interface CreateProductDto {
  name: string;
  description: string;
  categoryId: string;
  price: number;
  unit: string;
  stock: number;
}

export interface UpdateProductDto {
  name?: string;
  description?: string;
  categoryId?: string;
  price?: number;
  unit?: string;
  stock?: number;
  isPublished?: boolean;
}

@Injectable()
export class ProductsService {
  constructor(private prisma: PrismaService) {}

  async findAll(query: { category?: string; search?: string; minPrice?: number; maxPrice?: number; page?: number; limit?: number }) {
    const page = Number(query.page) || 1;
    const limit = Number(query.limit) || 20;
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
      if (query.minPrice) where.price.gte = Number(query.minPrice);
      if (query.maxPrice) where.price.lte = Number(query.maxPrice);
    }

    const [products, total] = await Promise.all([
      this.prisma.product.findMany({
        where,
        skip,
        take: limit,
        include: {
          farmer: { select: { id: true, farmName: true, farmAddress: true, userId: true } },
          category: { select: { id: true, name: true, slug: true } },
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
        farmer: { select: { id: true, farmName: true, farmAddress: true, bio: true, userId: true } },
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

  async create(user: AuthenticatedUser, dto: CreateProductDto) {
    let farmerId = user.farmerProfileId;

    if (!farmerId) {
      const farmerProfile = await this.prisma.farmerProfile.findUnique({
        where: { userId: user.id },
      });
      if (!farmerProfile) {
        throw new ForbiddenException('User is not registered as a farmer.');
      }
      farmerId = farmerProfile.id;
    }

    const product = await this.prisma.product.create({
      data: {
        farmerId: farmerId,
        categoryId: dto.categoryId,
        name: dto.name,
        description: dto.description,
        price: dto.price,
        unit: dto.unit,
        stock: dto.stock,
      },
      include: {
        category: true,
        farmer: { select: { id: true, farmName: true, userId: true } },
      },
    });

    return {
      success: true,
      message: 'Product created successfully',
      data: product,
    };
  }

  async update(id: string, user: AuthenticatedUser, dto: UpdateProductDto) {
    const existing = await this.prisma.product.findUnique({
      where: { id },
      include: { farmer: { select: { userId: true } } },
    });

    if (!existing) {
      throw new NotFoundException(`Product with ID ${id} not found.`);
    }

    // IDOR Enforcement: User must be the owner farmer or an Admin
    if (user.role !== Role.ADMIN && existing.farmer.userId !== user.id) {
      throw new ForbiddenException('You are not authorized to update this product.');
    }

    const updated = await this.prisma.product.update({
      where: { id },
      data: {
        ...(dto.name !== undefined && { name: dto.name }),
        ...(dto.description !== undefined && { description: dto.description }),
        ...(dto.categoryId !== undefined && { categoryId: dto.categoryId }),
        ...(dto.price !== undefined && { price: dto.price }),
        ...(dto.unit !== undefined && { unit: dto.unit }),
        ...(dto.stock !== undefined && { stock: dto.stock }),
        ...(dto.isPublished !== undefined && { isPublished: dto.isPublished }),
      },
      include: {
        category: true,
        farmer: { select: { id: true, farmName: true, userId: true } },
      },
    });

    return {
      success: true,
      message: 'Product updated successfully',
      data: updated,
    };
  }

  async remove(id: string, user: AuthenticatedUser) {
    const existing = await this.prisma.product.findUnique({
      where: { id },
      include: { farmer: { select: { userId: true } } },
    });

    if (!existing) {
      throw new NotFoundException(`Product with ID ${id} not found.`);
    }

    // IDOR Enforcement: User must be the owner farmer or an Admin
    if (user.role !== Role.ADMIN && existing.farmer.userId !== user.id) {
      throw new ForbiddenException('You are not authorized to delete this product.');
    }

    await this.prisma.product.delete({ where: { id } });

    return {
      success: true,
      message: 'Product deleted successfully',
    };
  }
}
