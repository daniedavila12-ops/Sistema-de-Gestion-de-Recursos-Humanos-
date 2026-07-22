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

  // We have:
  // <div class="flex items-center gap-4 w-full md:w-auto">
  //   <button ...>...</button>
  //   <div class="flex justify-between items-center w-full"> (or similar)
  
  // Let's remove the wrapper div and just leave the button inside the original div, putting it before the original div's contents.
  // Wait, no, it's easier to just close the div at the end of the header? No, it's a structural mess.
  // Let's revert the header change entirely and redo it cleanly.
  // I'll find `<div class="flex items-center gap-4 w-full md:w-auto">` and remove it, along with its unclosed tag problem.
  
  const badRegex = /<div class="flex items-center gap-4 w-full md:w-auto">\s*<button @click="toggleMobileMenu" class="md:hidden p-2 text-slate-500 hover:text-slate-800 hover:bg-slate-100 rounded-lg transition-colors">\s*<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"><\/path><\/svg>\s*<\/button>\s*<div([^>]*)>/g;
  
  content = content.replace(badRegex, (match, divAttrs) => {
    return `<div${divAttrs}>\n          <button @click="toggleMobileMenu" class="md:hidden p-2 text-slate-500 hover:text-slate-800 hover:bg-slate-100 rounded-lg transition-colors mr-3 shrink-0">\n            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path></svg>\n          </button>`;
  });

  if (content !== original) {
    fs.writeFileSync(file, content, 'utf-8');
    console.log('Fixed header in ' + file);
  }
});
