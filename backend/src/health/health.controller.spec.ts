import { HealthController } from './health.controller';
import { HealthService } from './health.service';

describe('HealthController', () => {
  it('returns minimal healthy status', () => {
    const controller = new HealthController(new HealthService());

    expect(controller.getHealth()).toEqual({ status: 'ok' });
  });
});
