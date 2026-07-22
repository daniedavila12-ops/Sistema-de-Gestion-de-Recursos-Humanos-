const fs = require('fs');
const path = require('path');

const walkSync = (dir, filelist = []) => {
  fs.readdirSync(dir).forEach(file => {
    const dirFile = path.join(dir, file);
    try {
      filelist = walkSync(dirFile, filelist);
    } catch (err) {
      if (err.code === 'ENOTDIR' || err.code === 'EBUSY') filelist = [...filelist, dirFile];
    }
  });
  return filelist;
};

const files = walkSync(path.join(__dirname, 'pages')).filter(f => f.endsWith('.vue'));

files.forEach(file => {
  if (file.includes('login.vue')) return;
  if (file.includes('index.vue') && !file.includes('admin') && !file.includes('empleados') && !file.includes('departamentos') && !file.includes('reportes')) return; // skip the one we already did manually

  let content = fs.readFileSync(file, 'utf-8');
  let originalContent = content;

  // 1. Remove <aside>
  const asideRegex = /<aside[\s\S]*?<\/aside>/;
  if (asideRegex.test(content)) {
    content = content.replace(asideRegex, '<AppSidebar />');
  } else {
    return; // No aside, probably not a layout page
  }

  // 2. Fix <main>
  content = content.replace(/<main([^>]*)>/, (match, attrs) => {
    let newAttrs = attrs.replace(/\bml-64\b/g, 'md:ml-64').replace(/\bhidden md:flex\b/g, '');
    if (!newAttrs.includes('w-full')) newAttrs += ' w-full overflow-x-hidden transition-all duration-300';
    return `<main${newAttrs}>`;
  });

  // 3. Fix header to include hamburger
  // Find <header> and the next <div> or <h1>
  content = content.replace(/(<header[^>]*>)\s*<div([^>]*?)>/, (match, header, divAttrs) => {
    return `${header}
        <div class="flex items-center gap-4 w-full md:w-auto">
          <button @click="toggleMobileMenu" class="md:hidden p-2 text-slate-500 hover:text-slate-800 hover:bg-slate-100 rounded-lg transition-colors">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path></svg>
          </button>
          <div${divAttrs}>`;
  });

  // 4. Inject composable
  if (content.includes('<script setup>')) {
      content = content.replace(/<script setup>\s*/, `<script setup>\nimport { useSidebar } from '@/composables/useSidebar'\nconst { toggleMobileMenu } = useSidebar()\n`);
  }

  // 5. Remove menuUsuario from script if it exists
  content = content.replace(/const menuUsuario = ref\(\[\]\)\s*/g, '');
  content = content.replace(/const urlMenu = [\s\S]*?menuUsuario\.value = await response\.json\(\)\s*\}\s*\}/g, '');
  
  if (content !== originalContent) {
    fs.writeFileSync(file, content, 'utf-8');
    console.log(`Updated ${file}`);
  }
});
