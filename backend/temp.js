const mysql = require('mysql2/promise');
require('dotenv').config();

async function run() {
  const connection = await mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: process.env.DB_PORT
  });
  await connection.execute("INSERT IGNORE INTO roles (id, nombre) VALUES (8, 'Mercadeo')");
  console.log('Mercadeo role added');
  connection.end();
}

run().catch(console.error);
