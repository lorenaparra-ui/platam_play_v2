import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { DocumentTypeEntity } from '../entities/document-type.entity';
import { DocumentTypeRepositoryPort } from '../../../transversal/domain/ports/document-type.repository.port';
import { DocumentType } from '../../../transversal/domain/models/document-type.model';
import { DocumentTypeMapper } from '../mappers/document-type.mapper';

@Injectable()
export class TypeOrmDocumentTypeRepository implements DocumentTypeRepositoryPort {
  constructor(
    @InjectRepository(DocumentTypeEntity)
    private readonly repository: Repository<DocumentTypeEntity>,
  ) {}

  async findAll(): Promise<DocumentType[]> {
    const entities = await this.repository.find();
    return entities.map(DocumentTypeMapper.toDomain);
  }

  async findById(id: number): Promise<DocumentType | null> {
    const entity = await this.repository.findOne({ where: { id } });
    return entity ? DocumentTypeMapper.toDomain(entity) : null;
  }

  async findByCode(code: string): Promise<DocumentType | null> {
    const entity = await this.repository.findOne({ where: { code } });
    return entity ? DocumentTypeMapper.toDomain(entity) : null;
  }
}