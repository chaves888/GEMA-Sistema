import { Test, TestingModule } from '@nestjs/testing';
import { CardapiosService } from './cardapios.service';

describe('CardapiosService', () => {
  let service: CardapiosService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [CardapiosService],
    }).compile();

    service = module.get<CardapiosService>(CardapiosService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
