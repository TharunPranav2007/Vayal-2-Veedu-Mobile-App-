import { Injectable, UnauthorizedException, ConflictException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../prisma/prisma.service';
import { Role } from '@prisma/client';
import * as bcrypt from 'bcryptjs';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
  ) {}

  async register(dto: { email: string; phone: string; name: string; password: String; role: Role }) {
    const existing = await this.prisma.user.findFirst({
      where: {
        OR: [{ email: dto.email }, { phone: dto.phone }],
      },
    });

    if (existing) {
      throw new ConflictException('User with this email or phone number already exists.');
    }

    const passwordHash = await bcrypt.hash(dto.password as string, 10);

    const user = await this.prisma.user.create({
      data: {
        email: dto.email,
        phone: dto.phone,
        name: dto.name,
        passwordHash,
        role: dto.role,
        ...(dto.role === Role.FARMER && {
          farmerProfile: {
            create: {
              farmName: `${dto.name}'s Farm`,
              farmAddress: 'Madurai District',
            },
          },
        }),
        ...(dto.role === Role.CONSUMER && {
          consumerProfile: {
            create: {},
          },
        }),
        ...(dto.role === Role.DELIVERY_PARTNER && {
          deliveryProfile: {
            create: {
              vehicleType: 'Two Wheeler',
              vehicleNumber: 'TN-58-AB-1234',
              licenseNumber: 'DL-987654321',
            },
          },
        }),
      },
    });

    const tokens = await this._generateTokens(user.id, user.email, user.role);

    return {
      success: true,
      message: 'User registered successfully',
      data: {
        user: { id: user.id, email: user.email, name: user.name, role: user.role },
        ...tokens,
      },
    };
  }

  async login(dto: { email: string; password: String }) {
    const user = await this.prisma.user.findUnique({
      where: { email: dto.email },
    });

    if (!user) {
      throw new UnauthorizedException('Invalid email or password.');
    }

    const isMatch = await bcrypt.compare(dto.password as string, user.passwordHash);
    if (!isMatch) {
      throw new UnauthorizedException('Invalid email or password.');
    }

    const tokens = await this._generateTokens(user.id, user.email, user.role);

    return {
      success: true,
      message: 'Login successful',
      data: {
        user: { id: user.id, email: user.email, name: user.name, role: user.role },
        ...tokens,
      },
    };
  }

  private async _generateTokens(userId: string, email: string, role: Role) {
    const payload = { sub: userId, email, role };
    const accessToken = await this.jwtService.signAsync(payload, { expiresIn: '15m' });
    const refreshToken = await this.jwtService.signAsync(payload, { expiresIn: '7d' });

    return { accessToken, refreshToken };
  }
}
