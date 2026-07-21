const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');

// Credenciales de Railway (de los comentarios del .env)
const railwayConfig = {
    host: 'sakura.proxy.rlwy.net',
    port: 52260,
    user: 'root',
    password: 'TsAZLfVFZkEjHvJhGZDTloumbVQdGEQh',
    database: 'railway',
    multipleStatements: true,
    connectTimeout: 30000
};

async function run() {
    console.log('🔌 Conectando a Railway MySQL...');
    console.log(`   Host: ${railwayConfig.host}:${railwayConfig.port}`);
    
    let conn;
    try {
        conn = await mysql.createConnection(railwayConfig);
        console.log('✅ Conexión exitosa!\n');
        
        const sqlFile = path.join(__dirname, 'data_dump_full.sql');
        let sql = fs.readFileSync(sqlFile, 'utf8');
        
        // Remove BOM if present
        if (sql.charCodeAt(0) === 0xFEFF) {
            sql = sql.slice(1);
        }
        
        console.log('📋 Ejecutando script de importación SQL...');
        const [results] = await conn.query(sql);
        
        console.log('\n✅ Script ejecutado exitosamente!');
        
        // Verificar tablas creadas
        const [tables] = await conn.query('SHOW TABLES');
        console.log(`\n📊 Tablas en la base de datos (${tables.length} total):`);
        tables.forEach(t => {
            const tableName = Object.values(t)[0];
            console.log(`   ✓ ${tableName}`);
        });
        
    } catch (err) {
        console.error('❌ Error:', err.message);
        if (err.code) console.error('   Código:', err.code);
        process.exit(1);
    } finally {
        if (conn) await conn.end();
        console.log('\n🔒 Conexión cerrada.');
    }
}

run();
