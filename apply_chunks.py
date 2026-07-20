import json
import sys

with open('chunks.json', encoding='utf-8') as f:
    chunks_data = json.load(f)

file_path = r'frontend\pages\reportes\index.vue'
with open(file_path, encoding='utf-8') as f:
    content = f.read()
content = content.replace('\r\n', '\n')

for c in chunks_data:
    if c['name'] == 'multi_replace_file_content':
        for chunk in c['args']['ReplacementChunks']:
            target = chunk['TargetContent'].replace('\r\n', '\n')
            replacement = chunk['ReplacementContent']
            if target in content:
                content = content.replace(target, replacement)
                print('Replaced chunk:', chunk['StartLine'], '-', chunk['EndLine'])
            else:
                print('Could not find chunk:', chunk['StartLine'], '-', chunk['EndLine'])
                
with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

