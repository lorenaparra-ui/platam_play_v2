import { Column, Entity, PrimaryGeneratedColumn } from 'typeorm';

@Entity('document_types')
export class DocumentTypeEntity {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'varchar', length: 50, unique: true })
  name: string;

  @Column({ type: 'varchar', length: 10, unique: true })
  code: string;

  @Column({ type: 'boolean', default: true })
  isActive: boolean;
}