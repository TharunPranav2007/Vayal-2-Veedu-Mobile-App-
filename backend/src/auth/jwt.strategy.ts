import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(private prisma: PrismaService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: process.env.JWT_SECRET || 'vayal2veedu_super_secret_jwt_key_2026',
    });
  }

  async validate(payload: { sub: string; email: string; role: string }) {
    const user = await this.prisma.user.findUnique({
      where: { id: payload.sub },
      include: {
        farmerProfile: { select: { id: true } },
        consumerProfile: { select: { id: true } },
        deliveryProfile: { select: { id: true } },
      },
    });

    if (!user || !user.isActive) {
      throw new UnauthorizedException('User account is invalid or deactivated.');
    }

    return {
      id: user.id,
      email: user.email,
      role: user.role,
      name: user.name,
      farmerProfileId: user.farmerProfile?.id,
      consumerProfileId: user.consumerProfile?.id,
      deliveryProfileId: user.deliveryProfile?.id,
    };
  }
}
