import os

dirs = ['pages', 'components']

for d in dirs:
    for root, _, files in os.walk(d):
        for f in files:
            if f.endswith('.vue') or f.endswith('.js'):
                path = os.path.join(root, f)
                # Ignore the newly renamed pages to avoid double replacing
                if path.endswith('pages\\index.vue') or path.endswith('pages/index.vue'):
                    continue
                if path.endswith('pages\\dashboard.vue') or path.endswith('pages/dashboard.vue'):
                    # In dashboard, we only need to change navigateTo('/login') to navigateTo('/')
                    pass

                with open(path, 'r', encoding='utf8') as file:
                    content = file.read()
                
                new_content = content
                
                # Update routes that point to the old dashboard ('/') to point to the new dashboard ('/dashboard')
                # Wait, I only want to replace navigateTo('/') with navigateTo('/dashboard') in some places
                # Actually, wait. It's safer to just do them individually if there are too many.
                
                # Navigate to login -> navigate to root
                new_content = new_content.replace("navigateTo('/login')", "navigateTo('/')")
                new_content = new_content.replace('navigateTo("/login")', 'navigateTo("/")')
                
                # NuxtLink to login -> to root
                new_content = new_content.replace('to="/login"', 'to="/"')
                new_content = new_content.replace("to='/login'", 'to="/"')
                
                if new_content != content:
                    with open(path, 'w', encoding='utf8') as file:
                        file.write(new_content)
                    print(f"Updated {path}")
