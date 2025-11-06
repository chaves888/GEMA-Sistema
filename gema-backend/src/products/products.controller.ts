// src/products/products.controller.ts
import {
	Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, HttpCode, Req, // 1. Importar Req
} from '@nestjs/common';
import { ProductsService } from './products.service';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { JwtAuthGuard } from 'src/auth/guards/jwt-auth.guard';
import { RolesGuard } from 'src/auth/guards/roles.guard';
import { Roles } from 'src/auth/decorators/roles.decorator';
import { User, UserProfile } from 'src/users/entities/user.entity'; // 2. Importar User
import { Request } from 'express'; // 3. Importar Request

// 4. Definir interface
interface RequestWithUser extends Request {
	user: User;
}

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

	// --- 5. ROTA REMOVE ATUALIZADA ---
	@Delete(':id')
	@Roles(UserProfile.PREFEITURA)
	@HttpCode(204)
	remove(@Param('id') id: string, @Req() req: RequestWithUser) { // Recebe o @Req
		// Passa o ID e o usuário que está excluindo
		return this.productsService.remove(id, req.user);
	}
}