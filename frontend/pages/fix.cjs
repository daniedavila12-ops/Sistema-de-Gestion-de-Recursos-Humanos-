const fs = require('fs');
const path = require('path');

const dir = 'c:/Users/danie/Documents/INNOVA/Proyecto/frontend/pages';

function walkDir(dir, callback) {
  fs.readdirSync(dir).forEach(f => {
    let dirPath = path.join(dir, f);
    let isDirectory = fs.statSync(dirPath).isDirectory();
    isDirectory ? walkDir(dirPath, callback) : callback(dirPath);
  });
}

walkDir(dir, function(filePath) {
  if (filePath.endsWith('.vue')) {
    let content = fs.readFileSync(filePath, 'utf8');
    let changed = false;

    // We know it was mangled into: /api/menu/?usuario_id=
    // And /api/dashboard-permisos/?usuario_id=

    if (content.includes('api/menu/?usuario_id=')) {
      content = content.replace(/api\/menu\/\?usuario_id=/g, 'api/menu/${rolID.value}?usuario_id=${localStorage.getItem(\'usuarioID\')}');
      changed = true;
    }
    
    if (content.includes('api/dashboard-permisos/?usuario_id=')) {
      content = content.replace(/api\/dashboard-permisos\/\?usuario_id=/g, 'api/dashboard-permisos/${rolID.value}?usuario_id=${localStorage.getItem(\'usuarioID\')}');
      changed = true;
    }

    if (changed) {
      fs.writeFileSync(filePath, content, 'utf8');
      console.log('Fixed:', filePath);
    }
  }
});
