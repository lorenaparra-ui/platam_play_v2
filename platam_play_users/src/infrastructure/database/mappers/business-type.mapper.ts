import { BusinessTypeEntity } from '../entities/business-type.entity';
import { BusinessType } from '../../../transversal/domain/models/business-type.model';

export class BusinessTypeMapper {
  static toDomain(entity: BusinessTypeEntity): BusinessType {
    return new BusinessType(
      entity.id,
      entity.name,
      entity.description,
      entity.isActive,
    );
  }

  static toEntity(domain: BusinessType): BusinessTypeEntity {
    const entity = new BusinessTypeEntity();
    entity.id = domain.id;
    entity.name = domain.name;
    entity.description = domain.description;
    entity.isActive = domain.isActive;
    return entity;
  }
}