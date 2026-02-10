import './dotenv.config';
import * as path from 'path';
import { DataSource, DataSourceOptions } from 'typeorm';

const TypeormConfig = {
  type: process.env.TYPEORM_TYPE,
  host: process.env.POSTGRES_HOST,
  username: process.env.POSTGRES_USERNAME,
  port: process.env.TYPEORM_PORT,
  database: process.env.POSTGRES_DATABASE,
  password: process.env.POSTGRES_PASSWORD,
  migrations: [path.join(__dirname, '../infrastructure/database/migrations/*.js')],
  entities: [path.join(__dirname, '../../**/*.entity.js')],
  logging: true,
  synchronize: process.env.TYPEORM_SYNC === 'true',
  migrationsTableName: 'typeorm_migrations',
  cli: {
    migrationsDir: 'src/infrastructure/database/migrations',
  },
};
console.log(TypeormConfig);

export default TypeormConfig;
export const dataSource = new DataSource(TypeormConfig as DataSourceOptions);