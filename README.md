🍔 Nostalgic Foodie App
A full-stack Food Delivery mobile application built with Flutter and Firebase. Features include user authentication with custom email verification, real-time product browsing, and cloud-based image management via Cloudinary. Designed with a focus on 'nostalgic' user experience and smooth UI/UX."

🚀 Key Features
User & Admin Roles: Separate interfaces for customers and restaurant managers.

Dynamic Menu: Add and manage food items like Burgers, Pizza, and Salads with real-time updates.

Image Management: Integrated with Cloudinary for professional image hosting and optimized delivery.

Secure Payments: Stripe integration for handling credit card transactions.

Real-time Database: Powered by Firebase for user authentication and data management.

🛡️ Security & Environment Configuration
To maintain professional security standards, this project uses a .env configuration system to prevent sensitive data leaks:

API Protection: All sensitive keys for Stripe and Cloudinary are stored in a local .env file.

Git Security: The .gitignore file is configured to exclude firebase_options.dart and .env from the repository, ensuring API keys remain private.

Environment Variables: The app uses flutter_dotenv to dynamically load configurations at runtime.

🛠️ Tech Stack
Frontend: Flutter (Dart)
Backend: Firebase (Firestore, Auth)
Storage: Cloudinary
Payments: Stripe

