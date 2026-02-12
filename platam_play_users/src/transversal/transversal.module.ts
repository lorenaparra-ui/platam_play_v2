import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

// Entities
import { DocumentTypeEntity } from '@infrastructure/database/entities/document-type.entity';
import { BusinessTypeEntity } from '@infrastructure/database/entities/business-type.entity';
import { BusinessSeniorityEntity } from '@infrastructure/database/entities/business-seniority.entity';

// Repositories (Implementations)
import { TypeOrmDocumentTypeRepository } from '@infrastructure/database/repositories/typeorm-document-type.repository';
import { TypeOrmBusinessTypeRepository } from '@infrastructure/database/repositories/typeorm-business-type.repository';
import { TypeOrmBusinessSeniorityRepository } from '@infrastructure/database/repositories/typeorm-business-seniority.repository';

// Ports (Tokens)
import { DOCUMENT_TYPE_REPOSITORY } from '@transversal/domain/ports/document-type.repository.port';
import { BUSINESS_TYPE_REPOSITORY } from '@transversal/domain/ports/business-type.repository.port';
import { BUSINESS_SENIORITY_REPOSITORY } from '@transversal/domain/ports/business-seniority.repository.port';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      DocumentTypeEntity,
      BusinessTypeEntity,
      BusinessSeniorityEntity,
    ]),
  ],
  providers: [
    {
      provide: DOCUMENT_TYPE_REPOSITORY,
      useClass: TypeOrmDocumentTypeRepository,
    },
    {
      provide: BUSINESS_TYPE_REPOSITORY,
      useClass: TypeOrmBusinessTypeRepository,
    },
    {
      provide: BUSINESS_SENIORITY_REPOSITORY,
      useClass: TypeOrmBusinessSeniorityRepository,
    },
  ],
  exports: [
    DOCUMENT_TYPE_REPOSITORY,
    BUSINESS_TYPE_REPOSITORY,
    BUSINESS_SENIORITY_REPOSITORY,
  ],
})
export class TransversalModule {}