import { Logger, NestMiddleware } from '@nestjs/common';
import { NextFunction, Request, Response } from 'express';

export class RequestLoggerMiddleware implements NestMiddleware {
  private readonly logger = new Logger(RequestLoggerMiddleware.name);

  use(request: Request, response: Response, next: NextFunction): void {
    const startedAt = performance.now();

    response.on('finish', () => {
      const durationMs = Math.round(performance.now() - startedAt);
      this.logger.log(
        `${request.method} ${request.path} ${response.statusCode} ${durationMs}ms`,
      );
    });

    next();
  }
}
