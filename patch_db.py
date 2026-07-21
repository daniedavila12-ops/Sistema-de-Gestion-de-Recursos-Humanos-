import glob
import re

files = glob.glob('backend/src/**/*.js', recursive=True)
for f in files:
    try:
        with open(f, 'r', encoding='utf-8') as file:
            content = file.read()
        
        # We want to replace the default localhost connection strings with the Railway ones
        new_content = content.replace("'localhost'", "'sakura.proxy.rlwy.net'")
        new_content = new_content.replace("3306", "52260")
        new_content = new_content.replace("?? ''", "?? 'TsAZLfVFZkEjHvJhGZDTloumbVQdGEQh'")
        new_content = new_content.replace("?? 'sistema_rrhh'", "?? 'railway'")
        
        if new_content != content:
            with open(f, 'w', encoding='utf-8') as file:
                file.write(new_content)
            print(f'Updated {f}')
    except Exception as e:
        pass
print("Done")
