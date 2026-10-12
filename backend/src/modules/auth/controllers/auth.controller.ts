import { Body, Controller, HttpCode, HttpStatus, Post } from '@nestjs/common';
import { LoginDto } from '../features/login/login.dto';
import { LoginResponse, LoginService } from '../features/login/login.service';

@Controller('auth')
export class AuthController {
  constructor(private readonly loginService: LoginService) {}

  @Post('login')
  @HttpCode(HttpStatus.OK)
  login(@Body() body: unknown): Promise<LoginResponse> {
    return this.loginService.execute(LoginDto.parse(body));
  }
}
