import { BusinessSeniorityEntity } from '../entities/business-seniority.entity';
import { BusinessSeniority } from '../../../transversal/domain/models/business-seniority.model';

export class BusinessSeniorityMapper {
  static toDomain(entity: BusinessSeniorityEntity): BusinessSeniority {
    return new BusinessSeniority(
      entity.id,
      entity.name,
      entity.level,
      entity.isActive,
    );
  }

  static toEntity(domain: BusinessSeniority): BusinessSeniorityEntity {
    const entity = new BusinessSeniorityEntity();
    entity.id = domain.id;
    entity.name = domain.name;
    entity.level = domain.level;
    entity.isActive = domain.isActive;
    return entity;
  }
}