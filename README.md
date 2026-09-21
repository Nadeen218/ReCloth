# ReCloth ♻️
### *Because Every Piece Tells a Story*
**Bachelor of Computer Science - Graduation Project | 2026**

> ⚠️ **Notice:** This repository and all its contents (code, UI/UX design, screens, branding, and documentation) are the original intellectual property of the author. Copying, cloning, redistributing, rebranding, or submitting this project (in whole or in part) as your own academic or commercial work is **strictly prohibited** and may constitute academic dishonesty and/or copyright infringement. See the [Rights & License](#️-rights--license) section below.

---

## 📺 App Demo & Screenshots

| **🎥 Feature Demo** | **🖼️ App Screenshots** |
| :--- | :--- |
| **Admin Dashboard** <br><br> <video src="https://github.com/user-attachments/assets/a24e4946-8b4b-4ff4-9fba-b1e9e5c61a55" width="220" controls></video> | <img  src="https://github.com/user-attachments/assets/2d5f0330-55dd-49ee-b872-6d512b294b00" width="150"> &nbsp; <img src="https://github.com/user-attachments/assets/315c629c-0dc3-4187-b08b-132b35efe8b7" width="150"> <img src="https://github.com/user-attachments/assets/879f1cab-2b52-4545-a99f-e4ce2f2f43f6" width="150"> |
| **🎥 Home Screen (Role Based)** | **🖼️ App Screenshots** |
| **Home screen** <br><br> <video src="https://github.com/user-attachments/assets/fb58bf74-8650-47fa-9c46-8ae9a44cd4c0" width="220" controls></video> | <img src="https://github.com/user-attachments/assets/8a7eeb17-3c7a-45e0-a816-bf95a3001867" width="150"> &nbsp; <img src="https://github.com/user-attachments/assets/27e77c23-fcba-4c38-bd4a-4ca0c60a9662" width="150"> <img src="https://github.com/user-attachments/assets/0013103b-d893-4ae1-bcc7-46cd571b7f93" width="150"> |

*All screenshots and demo footage above are original captures from this application and are protected under the same license as the rest of this repository (see below).*

---

## 📱 Project Overview & Screens

**ReCloth** is a comprehensive mobile application developed using **Flutter** and **Firebase**. The project is dedicated to promoting environmental sustainability and the circular economy by providing a streamlined platform for donating, refurbishing, and reselling quality second-hand clothing at affordable prices.

### **1. Onboarding & Security**

*   **Loading Screen**: The first point of interaction featuring the app logo and the tagline: "Because Every Piece Tells a Story".
*   **Home screen**: The second screen that appears for guests, explaining what the app does for visitors.
*   **Authentication Flow**: Secure **Login** and **Register** screens powered by Firebase Auth, allowing users to join the ReCloth community or access the Admin panel.

### **2. Core Experience**

*   **Home Screen**: A central dashboard providing quick navigation to main activities: Donate, Shop, Rewards, and tracking.
*   **Profile Management**: A comprehensive section including **Edit Profile**, **Settings**, and **Help & Support** to ensure a personalized user experience.

### **3. Donation Journey (Donor Flow)**

*   **Donate Screen**: A structured form where users can submit donation requests for their used clothes.
*   **Donation Submitted**: A confirmation screen providing immediate feedback after a successful donation request.
*   **Track Donations**: A real-time interface for users to monitor the status and history of their contributions.

### **4. Shopping Journey (Buyer Flow)**

*   **Shop Screen**: A categorized marketplace to browse high-quality refurbished clothing.
*   **Item Details**: In-depth view for each product, allowing users to see descriptions and quality before purchasing.
*   **Cart & Checkout**: A seamless flow to manage selected items and finalize purchases with a secure "Cash on Delivery" system.
*   **Order Placed**: A dedicated success screen confirming the order has been received and processed.

### **5. Special Features & Administration**

*   **Remake Studio**: A unique space dedicated to the creative side of clothing refurbishment and sustainability.
*   **Rewards Screen**: A gamified area where users can view points and rewards earned through their sustainable actions.
*   **Admin Dashboard**: A powerful management interface for tracking global statistics, managing inventory, and overseeing donation requests.
*   **Company Management**: A dedicated interface within the Admin Dashboard to manage service providers, including Cleaning Companies, Tailor Shops (Remake), and Delivery Services, ensuring a professional workflow for refurbishing clothes.

---

## ⚙️ Core Functionalities

*   **Role-Based Access Control (RBAC)**: Distinct permissions for Admin and User roles to ensure data security.
*   **Real-time Synchronization**: Powered by Firebase Firestore to update order and donation statuses instantly.
*   **Automated Stock Management**: Inventory levels automatically decrease upon successful purchases.
*   **State Management**: Centralized app state using the Provider pattern to ensure high performance and clean code.
*   **Service Provider Integration**: A streamlined logistics flow that connects donation requests with specialized companies for cleaning and repairing, ensuring every item meets quality standards before reselling.

---

## 🛠 Tech Stack & Tools

*   **Frontend**: Flutter (Dart) for high-performance cross-platform development.
*   **Backend**: Firebase (Cloud Firestore for database, Firebase Auth for security).
*   **State Management**: Provider for efficient app-wide state handling.
*   **Local Services**: Integrated Notification Services for user engagement.

---

## 🗺️ Future Roadmap

*   Integration of AI for automatic clothing quality assessment via image recognition.
*   Integration of a secure online payment gateway (Stripe / PayPal).
*   Implementation of a localized map (Google Maps API) for precise donation pickups.

---

## 🚀 Installation & Setup

> This section is provided for academic evaluation and demonstration purposes only. Running the project locally does not grant any license to reuse, redistribute, or repurpose its code or design — see [Rights & License](#️-rights--license).

To run this project locally, follow these steps:

### 1. Prerequisites
*   Install [Flutter SDK](https://docs.flutter.dev/get-started/install).
*   Install [Firebase CLI](https://firebase.google.com/docs/cli).

### 2. Clone the Repository
     git clone https://github.com/Nadeen218/Graduation-project.git
     cd Graduation-project

### 3. Install Dependencies
    flutter pub get

### 4. Configuration
*  Add your google-services.json to the android/app/ directory.
*  Ensure Firebase is initialized within the app.

### 5. Run the App
    flutter run

---

## 🏗 Key Technical Implementation Details

* During the development, several critical technical milestones were achieved:
* Firebase Integration: Successfully resolved Gradle conflicts and SDK versioning to ensure stable connectivity.
* Role-Based Access Control: Implemented logic to distinguish between Admin and User accounts, securing the administrative dashboard.
* Inventory Management: Developed a system that automatically updates stock levels in Firestore upon successful order placement.
* Automated Authentication: Implemented a "Stay Logged In" feature using FirebaseAuth.instance.currentUser for a better user experience.
* Vendor Management System: Designed and implemented a CRUD system for managing external service providers (Companies) to handle the refurbishment phase of the circular economy model.

---

## ⚖️ Rights & License

© 2026 **Nadeen Abu Hilweh**. All Rights Reserved.

This repository, including but not limited to its source code, UI/UX design, screen flows, branding (name, logo, tagline), screenshots, demo videos, and documentation, is the original work of **Nadeen Abu Hilweh**, created as a **Graduation Project** for the **Bachelor of Computer Science** degree.

**No part of this project may be copied, reproduced, distributed, rebranded, modified, publicly displayed, or submitted (in full or in part) as academic or commercial work by any other party without the prior explicit written permission of the author.**

This includes, without limitation:
*   Cloning or forking the repository for use as one's own graduation or course project.
*   Copying the application's design, screen flow, or feature set into another project.
*   Reusing the branding (name "ReCloth", logo, or tagline "Because Every Piece Tells a Story") in another product.
*   Presenting this work, or a derivative of it, as original work in an academic submission.

Any unauthorized use may be reported to the relevant academic institution and, where applicable, pursued as a copyright violation.

For collaboration, licensing, or reuse requests, please contact the author directly through the channels listed below.

---

## 💻 Developer

**Nadeen Abu Hilweh**
*   **GitHub**: [github.com/Nadeen218](https://github.com/Nadeen218)
*   **LinkedIn**: [LinkedIn](https://www.linkedin.com/in/nadeen-abu-hilweh/)

*If you found this project interesting, please ⭐ star the repository instead of copying it — it helps support the author's work while respecting her rights.*
