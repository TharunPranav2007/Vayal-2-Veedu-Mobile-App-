import { Controller, Post, Body, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { Role } from '@prisma/client';
import { Public } from '../common/decorators/public.decorator';

class RegisterDto {
  email: string;
  phone: string;
  name: string;
  password: String;
  role: Role;
}

class LoginDto {
  email: string;
  password: String;
}

@ApiTags('Authentication')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Public()
  @Post('register')
  @ApiOperation({ summary: 'Register a new marketplace user (Farmer, Consumer, Delivery Partner) (Public)' })
  @ApiResponse({ status: 201, description: 'User successfully registered' })
  async register(@Body() dto: RegisterDto) {
    return this.authService.register(dto);
  }

  @Public()
  @Post('login')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Authenticate user & return JWT tokens (Public)' })
  @ApiResponse({ status: 200, description: 'JWT authentication successful' })
  async login(@Body() dto: LoginDto) {
    return this.authService.login(dto);
  }
}
