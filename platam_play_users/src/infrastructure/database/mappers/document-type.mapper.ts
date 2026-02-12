import { DocumentTypeEntity } from '../entities/document-type.entity';
import { DocumentType } from '../../../transversal/domain/models/document-type.model';

export class DocumentTypeMapper {
  static toDomain(entity: DocumentTypeEntity): DocumentType {
    return new DocumentType(
      entity.id,
      entity.name,
      entity.code,
      entity.isActive,
    );
  }

  static toEntity(domain: DocumentType): DocumentTypeEntity {
    const entity = new DocumentTypeEntity();
    entity.id = domain.id;
    entity.name = domain.name;
    entity.code = domain.code;
    entity.isActive = domain.isActive;
    return entity;
  }
}