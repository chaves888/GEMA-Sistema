import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, HttpCode } from '@nestjs/common';
import { ProductsService } from './products.service';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { JwtAuthGuard } from 'src/auth/guards/jwt-auth.guard';
import { RolesGuard } from 'src/auth/guards/roles.guard';
import { Roles } from 'src/auth/decorators/roles.decorator';
import { UserProfile } from 'src/users/entities/user.entity';

@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('products')
export class ProductsController {
  constructor(private readonly productsService: ProductsService) {}

  @Post()
  @Roles(UserProfile.PREFEITURA)
  create(@Body() createProductDto: CreateProductDto) {
    return this.productsService.create(createProductDto);
  }

  @Get()
  @Roles(UserProfile.PREFEITURA, UserProfile.NUTRICIONISTA, UserProfile.ESCOLA)
  findAll() {
    return this.productsService.findAll();
  }

  @Get(':id')
  @Roles(UserProfile.PREFEITURA, UserProfile.NUTRICIONISTA, UserProfile.ESCOLA)
  findOne(@Param('id') id: string) {
    return this.productsService.findOne(id);
  }

  @Patch(':id')
  @Roles(UserProfile.PREFEITURA)
  update(@Param('id') id: string, @Body() updateProductDto: UpdateProductDto) {
    return this.productsService.update(id, updateProductDto);
  }

  @Delete(':id')
  @Roles(UserProfile.PREFEITURA)
  @HttpCode(204) // <-- CORREÇÃO APLICADA AQUI
  remove(@Param('id') id: string) {
    return this.productsService.remove(id);
  }
}