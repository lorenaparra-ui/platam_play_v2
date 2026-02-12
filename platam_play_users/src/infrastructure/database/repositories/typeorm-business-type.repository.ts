import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { BusinessTypeEntity } from '../entities/business-type.entity';
import { BusinessTypeRepositoryPort } from '../../../transversal/domain/ports/business-type.repository.port';
import { BusinessType } from '../../../transversal/domain/models/business-type.model';
import { BusinessTypeMapper } from '../mappers/business-type.mapper';

@Injectable()
export class TypeOrmBusinessTypeRepository implements BusinessTypeRepositoryPort {
  constructor(
    @InjectRepository(BusinessTypeEntity)
    private readonly repository: Repository<BusinessTypeEntity>,
  ) {}

  async findAll(): Promise<BusinessType[]> {
    const entities = await this.repository.find();
    return entities.map(BusinessTypeMapper.toDomain);
  }

  async findById(id: number): Promise<BusinessType | null> {
    const entity = await this.repository.findOne({ where: { id } });
    return entity ? BusinessTypeMapper.toDomain(entity) : null;
  }
}