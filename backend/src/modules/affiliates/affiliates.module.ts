import { DynamicModule, Module } from '@nestjs/common';
import { RuntimeConfig } from '../../config/runtime-config';
import { AuthModule } from '../auth/auth.module';
import { AffiliatesController } from './controllers/affiliates.controller';
import { GetAffiliateService } from './features/get-affiliate/get-affiliate.service';
import { ListAffiliatesService } from './features/list-affiliates/list-affiliates.service';
import { AffiliatesRepository } from './repositories/affiliates.repository';

@Module({})
export class AffiliatesModule {
  static register(config: RuntimeConfig): DynamicModule {
    return {
      module: AffiliatesModule,
      imports: [AuthModule.register(config)],
      controllers: [AffiliatesController],
      providers: [AffiliatesRepository, ListAffiliatesService, GetAffiliateService],
    };
  }
}
