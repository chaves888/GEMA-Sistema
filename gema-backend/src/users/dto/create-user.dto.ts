// src/users/dto/create-user.dto.ts
import { IsEmail, IsEnum, IsNotEmpty, IsOptional, IsString, IsUUID, MinLength } from 'class-validator';
import { UserProfile } from "../entities/user.entity";

export class CreateUserDto {
    @IsString()
    @IsNotEmpty()
    name: string;

    @IsEmail()
    email: string;

    @IsString()
    @MinLength(6, { message: 'A senha deve ter no mínimo 6 caracteres.' })
    password: string;

    @IsEnum(UserProfile)
    profile: UserProfile;

    // --- ADICIONE ESTA PROPRIEDADE ---
    @IsUUID()
    @IsOptional() // É opcional, pois nem todo usuário tem uma escola
    schoolId?: string;
}