import { Column, Entity, PrimaryGeneratedColumn } from 'typeorm';

@Entity('business_seniorities')
export class BusinessSeniorityEntity {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'varchar', length: 50 })
  name: string;

  @Column({ type: 'int' })
  level: number;

  @Column({ type: 'boolean', default: true })
  isActive: boolean;
}