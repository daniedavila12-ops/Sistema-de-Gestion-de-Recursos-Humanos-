import os
import glob
import re

frontend_dir = 'frontend'
files = glob.glob(frontend_dir + '/**/*.vue', recursive=True)

for filepath in files:
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()

        original_content = content

        # Fix the invalid `src=` backticks
        # <img src=`${useRuntimeConfig().public.apiBase}/...` -> <img :src="`${useRuntimeConfig().public.apiBase}/...`"
        content = re.sub(r' src=(`\${useRuntimeConfig\(\)\.public\.apiBase}[^`]*`)', r' :src="\1"', content)
        
        # Also fix href
        content = re.sub(r' href=(`\${useRuntimeConfig\(\)\.public\.apiBase}[^`]*`)', r' :href="\1"', content)

        # Replace useRuntimeConfig().public.apiBase with $config.public.apiBase inside the template (i.e. inside vue <template> block)
        # Note: to be safe, any useRuntimeConfig() in a backtick inside a template binding should be $config
        # But actually, in Nuxt 3, if it's in the template, you CAN use `$config.public.apiBase`
        # Let's just replace all `useRuntimeConfig().public.apiBase` inside `<template>` with `$config.public.apiBase`
        # We can just replace all `${useRuntimeConfig().public.apiBase}` with `${$config.public.apiBase}` in the whole file EXCEPT in <script> blocks.
        # It's easier to just replace all `${useRuntimeConfig().public.apiBase}` with `${$config.public.apiBase}` globally if it's inside the template.
        
        template_match = re.search(r'<template>.*?</template>', content, flags=re.DOTALL)
        if template_match:
            template_content = template_match.group(0)
            fixed_template = template_content.replace('useRuntimeConfig().public.apiBase', '$config.public.apiBase')
            content = content.replace(template_content, fixed_template)

        if content != original_content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Fixed {filepath}")
            
    except Exception as e:
        pass

print("Done.")
