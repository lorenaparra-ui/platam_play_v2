import { DocumentType } from '../models/document-type.model';

export const DOCUMENT_TYPE_REPOSITORY = 'DOCUMENT_TYPE_REPOSITORY';

export interface DocumentTypeRepositoryPort {
  findAll(): Promise<DocumentType[]>;
  findById(id: number): Promise<DocumentType | null>;
  findByCode(code: string): Promise<DocumentType | null>;
}