import os
import glob
import re

frontend_dir = 'frontend'
files = glob.glob(frontend_dir + '/**/*.vue', recursive=True) + glob.glob(frontend_dir + '/**/*.js', recursive=True) + glob.glob(frontend_dir + '/**/*.ts', recursive=True)

for filepath in files:
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()

        if 'http://localhost:3007' not in content:
            continue
            
        original_content = content

        # 1. API routes with axios (we just remove the base URL since axios plugin handles it)
        content = content.replace("'http://localhost:3007/api", "'/api")
        content = content.replace("`http://localhost:3007/api", "`/api")
        content = content.replace('"http://localhost:3007/api', '"/api')

        # 2. Template string interpolation: `http://localhost:3007${var}` -> `${$config.public.apiBase}${var}`
        # Wait, if it's in <script setup>, $config is not available. 
        # In <script setup>, we should use useRuntimeConfig().public.apiBase
        # Let's replace `http://localhost:3007 with `${useRuntimeConfig().public.apiBase}
        content = content.replace("`http://localhost:3007", "`${useRuntimeConfig().public.apiBase}")

        # 3. Plain strings like 'http://localhost:3007/uploads/...' -> `${useRuntimeConfig().public.apiBase}/uploads/...`
        # Note: we need to replace single quotes with template literals if it contains localhost
        content = re.sub(r"'http://localhost:3007(/[^']*)'", r"`${useRuntimeConfig().public.apiBase}\1`", content)
        content = re.sub(r'"http://localhost:3007(/[^"]*)"', r"`${useRuntimeConfig().public.apiBase}\1`", content)

        # 4. Handle HTML attributes in Vue templates.
        # <img src="http://localhost:3007/uploads/..." />
        # becomes <img :src="`${useRuntimeConfig().public.apiBase}/uploads/...`" />
        # This regex matches src="..." and href="..." and replaces them
        content = re.sub(r' src="http://localhost:3007([^"]*)"', r' :src="`${useRuntimeConfig().public.apiBase}\1`"', content)
        content = re.sub(r' href="http://localhost:3007([^"]*)"', r' :href="`${useRuntimeConfig().public.apiBase}\1`"', content)

        # 5. Handle style="background-image: url('http://localhost:3007...')"
        content = re.sub(r'style="background-image:\s*url\(\'http://localhost:3007([^\']+)\'\);"([^>]*)', 
                         r':style="`background-image: url(\'${useRuntimeConfig().public.apiBase}\1\');`"\2', content)

        # 6. Socket io
        content = content.replace("io('http://localhost:3007')", "io(useRuntimeConfig().public.apiBase)")

        if content != original_content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Updated {filepath}")
            
    except Exception as e:
        print(f"Error processing {filepath}: {e}")

print("Done.")
