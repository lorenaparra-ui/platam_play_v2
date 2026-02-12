import { BusinessSeniority } from '../models/business-seniority.model';

export const BUSINESS_SENIORITY_REPOSITORY = 'BUSINESS_SENIORITY_REPOSITORY';

export interface BusinessSeniorityRepositoryPort {
  findAll(): Promise<BusinessSeniority[]>;
  findById(id: number): Promise<BusinessSeniority | null>;
}