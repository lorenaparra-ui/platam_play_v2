import { BusinessType } from '../models/business-type.model';

export const BUSINESS_TYPE_REPOSITORY = 'BUSINESS_TYPE_REPOSITORY';

export interface BusinessTypeRepositoryPort {
  findAll(): Promise<BusinessType[]>;
  findById(id: number): Promise<BusinessType | null>;
}