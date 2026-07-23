import os

dirs = ['pages', 'components']

for d in dirs:
    for root, _, files in os.walk(d):
        for f in files:
            if f.endswith('.vue') or f.endswith('.js'):
                path = os.path.join(root, f)
                # Ignore the login page (index.vue)
                if path.endswith('pages\\index.vue') or path.endswith('pages/index.vue'):
                    continue

                with open(path, 'r', encoding='utf8') as file:
                    content = file.read()
                
                new_content = content
                
                # Update routes that point to the old dashboard ('/') to point to the new dashboard ('/dashboard')
                new_content = new_content.replace("navigateTo('/')", "navigateTo('/dashboard')")
                new_content = new_content.replace('navigateTo("/")', 'navigateTo("/dashboard")')
                
                new_content = new_content.replace('to="/"', 'to="/dashboard"')
                new_content = new_content.replace("to='/'", 'to="/dashboard"')
                
                if new_content != content:
                    with open(path, 'w', encoding='utf8') as file:
                        file.write(new_content)
                    print(f"Updated {path}")
