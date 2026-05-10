import os
import django

# Django environment setup
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'core.settings')
django.setup()

from accounts.models import User

# --- Admin Details ---
phone = '01712345678'
pin = '1234'
password = 'abir'
full_name = 'Abir'

def create_admin():
    from django.contrib.auth.hashers import make_password
    import sys
    
    try:
        if not User.objects.filter(phone=phone).exists():
            print(f"--- Attempting to create superuser: {phone} ---")
            user = User.objects.create_superuser(phone=phone, full_name=full_name, password=password)
            user.pin = make_password(pin)
            user.save()
            print(f"--- SUCCESS: Superuser {phone} created with password 'abir' and PIN '1234'. ---")
        else:
            print(f"--- INFO: User {phone} already exists. Updating credentials... ---")
            user = User.objects.get(phone=phone)
            user.set_password(password) # পাসওয়ার্ড 'abir' সেট হচ্ছে
            user.pin = make_password(pin)
            user.is_staff = True
            user.is_superuser = True
            user.save()
            print(f"--- SUCCESS: Credentials updated for {phone}. ---")
        sys.stdout.flush()
    except Exception as e:
        print(f"--- ERROR: Could not create/update superuser: {str(e)} ---")
        sys.stdout.flush()

if __name__ == "__main__":
    create_admin()
