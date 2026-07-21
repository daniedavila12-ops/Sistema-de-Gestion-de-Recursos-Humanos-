

const { Sequelize } = require('sequelize');
require('dotenv').config();

const sequelize = new Sequelize(
  process.env.DB_NAME ?? 'railway',
  process.env.DB_USER ?? 'root',
  process.env.DB_PASS ?? 'TsAZLfVFZkEjHvJhGZDTloumbVQdGEQh',
  {
    host: process.env.DB_HOST ?? 'sakura.proxy.rlwy.net',
    port: process.env.DB_PORT ?? 52260,
    dialect: 'mysql',
    logging: false, // Set to true to see SQL queries
  }
);

module.exports = sequelize;
//mysql://root:FRamIHqKpMRLCxadepuyXmfiKQuxjrXr@autorack.proxy.rlwy.net:48674/railway   sistema_rrhh
//mysql://root:DUhBTZhVFzcXkbMFBgQhQiHuZGmBjuys@kodama.proxy.rlwy.net:25674/railway


//Nuevo Apunte
//mysql://root: