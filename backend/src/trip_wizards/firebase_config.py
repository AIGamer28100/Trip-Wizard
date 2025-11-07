import firebase_admin
from firebase_admin import credentials, firestore, auth

# Initialize Firebase Admin SDK
def initialize_firebase():
    if not firebase_admin._apps:
        # In production, load from environment or file
        # cred = credentials.Certificate(os.getenv('FIREBASE_SERVICE_ACCOUNT_KEY_PATH'))
        # For now, placeholder
        cred = credentials.Certificate({
            "type": "service_account",
            "project_id": "trip-wizards-app",
            "private_key_id": "PLACEHOLDER",
            "private_key": "-----BEGIN PRIVATE KEY-----\nPLACEHOLDER\n-----END PRIVATE KEY-----\n",
            "client_email": "firebase-adminsdk@trip-wizards-app.iam.gserviceaccount.com",
            "client_id": "PLACEHOLDER",
            "auth_uri": "https://accounts.google.com/o/oauth2/auth",
            "token_uri": "https://oauth2.googleapis.com/token",
            "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
            "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk%40trip-wizards-app.iam.gserviceaccount.com"
        })
        firebase_admin.initialize_app(cred)

# Get Firestore client
def get_firestore_client():
    return firestore.client()

# Get Auth client
def get_auth_client():
    return auth