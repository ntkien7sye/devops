// =============================================================================
// Health Module
// =============================================================================
// Register health check endpoints
// File: src/modules/health/health.module.ts
// =============================================================================

import { Module } from '@nestjs/common';
import { HealthController } from './health.controller';

@Module({
    controllers: [HealthController],
})
export class HealthModule {}
