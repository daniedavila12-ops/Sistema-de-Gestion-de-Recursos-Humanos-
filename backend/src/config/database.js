

const { Sequelize } = require('sequelize');
require('dotenv').config();

const sequelize = new Sequelize(
  process.env.DB_NAME ?? 'sistema_rrhh',
  process.env.DB_USER ?? 'root',
  process.env.DB_PASS ?? '',
  {
    host: process.env.DB_HOST ?? 'localhost',
    port: process.env.DB_PORT ?? 3306,
    dialect: 'mysql',
    logging: false, // Set to true to see SQL queries
  }
);

module.exports = sequelize;
//mysql://root:FRamIHqKpMRLCxadepuyXmfiKQuxjrXr@autorack.proxy.rlwy.net:48674/railway   sistema_rrhh
//mysql://root:DUhBTZhVFzcXkbMFBgQhQiHuZGmBjuys@kodama.proxy.rlwy.net:25674/railway


//Nuevo Apunte
//mysql://root: