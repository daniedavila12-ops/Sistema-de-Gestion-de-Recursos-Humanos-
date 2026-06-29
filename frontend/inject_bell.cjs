const fs = require('fs');
const path = require('path');

function walkDir(dir, callback) {
  fs.readdirSync(dir).forEach(f => {
    let dirPath = path.join(dir, f);
    let isDirectory = fs.statSync(dirPath).isDirectory();
    isDirectory ? walkDir(dirPath, callback) : callback(path.join(dir, f));
  });
}

walkDir('c:\\Users\\danie\\Documents\\INNOVA\\Proyecto\\frontend\\pages', function(filePath) {
  if (filePath.endsWith('.vue')) {
    let content = fs.readFileSync(filePath, 'utf8');
    let original = content;
    
    // Pattern 1
    let pattern1 = `<div class="relative">\n            <div @click="dropdownPerfilAbierto = !dropdownPerfilAbierto"`;
    let replacement1 = `<NotificationBell />\n          <div class="relative">\n            <div @click="dropdownPerfilAbierto = !dropdownPerfilAbierto"`;
    
    // Pattern 1 alternative spacing
    let pattern1Alt = `<div class="relative">\n              <div @click="dropdownPerfilAbierto = !dropdownPerfilAbierto"`;
    let replacement1Alt = `<NotificationBell />\n          <div class="relative">\n              <div @click="dropdownPerfilAbierto = !dropdownPerfilAbierto"`;

    // Pattern 2
    let pattern2 = `<div class="relative w-full md:w-auto flex justify-end">\n            <div @click="dropdownPerfilAbierto = !dropdownPerfilAbierto"`;
    let replacement2 = `<NotificationBell />\n          <div class="relative w-full md:w-auto flex justify-end">\n            <div @click="dropdownPerfilAbierto = !dropdownPerfilAbierto"`;
    
    if (content.includes(pattern1)) {
        content = content.replace(pattern1, replacement1);
    } else if (content.includes(pattern1Alt)) {
        content = content.replace(pattern1Alt, replacement1Alt);
    } else if (content.includes(pattern2)) {
        content = content.replace(pattern2, replacement2);
    } else if (content.includes(`@click="dropdownPerfilAbierto = !dropdownPerfilAbierto"`)) {
        // Fallback for weird spacing: regex
        content = content.replace(/(<div class="relative[^>]*>\s*<div @click="dropdownPerfilAbierto = !dropdownPerfilAbierto")/g, '<NotificationBell />\n          $1');
    }

    if (content !== original) {
      fs.writeFileSync(filePath, content, 'utf8');
      console.log('Modificado:', filePath);
    }
  }
});
