// =============================================================================
// Health Check Controller
// =============================================================================
// Add this to your NestJS application for Kubernetes health probes
// File: src/modules/health/health.controller.ts
// =============================================================================

import { Controller, Get } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';

interface HealthCheckResponse {
    status: string;
    timestamp: string;
    uptime: number;
    version: string;
    environment: string;
    checks: {
        database: string;
        memory: {
            heapUsed: number;
            heapTotal: number;
            rss: number;
        };
    };
}

@ApiTags('Health')
@Controller('health')
export class HealthController {
    @Get()
    @ApiOperation({ summary: 'Health check endpoint' })
    @ApiResponse({
        status: 200,
        description: 'Service is healthy',
    })
    getHealth(): HealthCheckResponse {
        const memoryUsage = process.memoryUsage();

        return {
            status: 'ok',
            timestamp: new Date().toISOString(),
            uptime: process.uptime(),
            version: process.env.npm_package_version || '1.0.0',
            environment: process.env.NODE_ENV || 'development',
            checks: {
                database: 'connected', // Replace with actual DB check
                memory: {
                    heapUsed: Math.round(memoryUsage.heapUsed / 1024 / 1024),
                    heapTotal: Math.round(memoryUsage.heapTotal / 1024 / 1024),
                    rss: Math.round(memoryUsage.rss / 1024 / 1024),
                },
            },
        };
    }

    @Get('liveness')
    @ApiOperation({ summary: 'Kubernetes liveness probe' })
    @ApiResponse({
        status: 200,
        description: 'Service is alive',
    })
    getLiveness(): { status: string } {
        return { status: 'alive' };
    }

    @Get('readiness')
    @ApiOperation({ summary: 'Kubernetes readiness probe' })
    @ApiResponse({
        status: 200,
        description: 'Service is ready to accept traffic',
    })
    getReadiness(): { status: string; ready: boolean } {
        // Add checks for dependencies (database, cache, etc.)
        const isReady = true; // Replace with actual readiness check

        return {
            status: isReady ? 'ready' : 'not_ready',
            ready: isReady,
        };
    }
}
