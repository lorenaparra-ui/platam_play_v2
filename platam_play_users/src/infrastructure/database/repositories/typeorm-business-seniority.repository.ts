import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { BusinessSeniorityEntity } from '../entities/business-seniority.entity';
import { BusinessSeniorityRepositoryPort } from '../../../transversal/domain/ports/business-seniority.repository.port';
import { BusinessSeniority } from '../../../transversal/domain/models/business-seniority.model';
import { BusinessSeniorityMapper } from '../mappers/business-seniority.mapper';

@Injectable()
export class TypeOrmBusinessSeniorityRepository implements BusinessSeniorityRepositoryPort {
  constructor(
    @InjectRepository(BusinessSeniorityEntity)
    private readonly repository: Repository<BusinessSeniorityEntity>,
  ) {}

  async findAll(): Promise<BusinessSeniority[]> {
    const entities = await this.repository.find();
    return entities.map(BusinessSeniorityMapper.toDomain);
  }

  async findById(id: number): Promise<BusinessSeniority | null> {
    const entity = await this.repository.findOne({ where: { id } });
    return entity ? BusinessSeniorityMapper.toDomain(entity) : null;
  }
}