const fs = require('fs');
const path = require('path');
const walkSync = (dir, filelist = []) => {
  fs.readdirSync(dir).forEach(file => {
    const dirFile = path.join(dir, file);
    try { filelist = walkSync(dirFile, filelist); } 
    catch (err) { if (err.code === 'ENOTDIR' || err.code === 'EBUSY') filelist = [...filelist, dirFile]; }
  });
  return filelist;
};
const files = walkSync(path.join(__dirname, 'pages')).filter(f => f.endsWith('.vue') && !f.includes('login.vue'));
files.forEach(file => {
  let content = fs.readFileSync(file, 'utf-8');
  let original = content;
  
  // Fix main tag
  content = content.replace(/<main([^>]*) w-full overflow-x-hidden transition-all duration-300([^>]*)>/, (match, before, after) => {
    if (before.includes('class="')) {
       return `<main${before.replace('class="', 'class="w-full overflow-x-hidden transition-all duration-300 ')}${after}>`;
    } else {
       return `<main class="w-full overflow-x-hidden transition-all duration-300"${before}${after}>`;
    }
  });

  if (content !== original) {
    fs.writeFileSync(file, content, 'utf-8');
    console.log('Fixed main in ' + file);
  }
});
