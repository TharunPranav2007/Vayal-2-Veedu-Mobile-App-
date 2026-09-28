import { Controller, Get, Post, Param, Query, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { ProductsService } from './products.service';

@ApiTags('Products Catalog')
@Controller('products')
export class ProductsController {
  constructor(private readonly productsService: ProductsService) {}

  @Get()
  @ApiOperation({ summary: 'List published produce with search, filtering, and pagination' })
  async findAll(
    @Query('category') category?: string,
    @Query('search') search?: string,
    @Query('minPrice') minPrice?: number,
    @Query('maxPrice') maxPrice?: number,
    @Query('page') page?: number,
    @Query('limit') limit?: number,
  ) {
    return this.productsService.findAll({ category, search, minPrice, maxPrice, page, limit });
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get detailed produce profile, images, ratings, and farmer details' })
  async findOne(@Param('id') id: string) {
    return this.productsService.findOne(id);
  }
}
