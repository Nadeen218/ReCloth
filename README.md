# ReCloth ♻️
### *Because Every Piece Tells a Story*
**Bachelor of Computer Science - Graduation Project | 2026**

---

## 📺 App Demo & Screenshots

| **🎥 Feature Demo** | **🖼️ App Screenshots** |
| :--- | :--- |
| **Admin Dashboard** <br><br> <video src="https://github.com/user-attachments/assets/a24e4946-8b4b-4ff4-9fba-b1e9e5c61a55" width="220" controls></video> | <img src="https://github.com/user-attachments/assets/ea114718-40c8-49b1-b77c-bcfd7fd4bb22" width="150"> &nbsp; <img src="https://github.com/user-attachments/assets/315c629c-0dc3-4187-b08b-132b35efe8b7" width="150"> <img src="https://github.com/user-attachments/assets/879f1cab-2b52-4545-a99f-e4ce2f2f43f6" width="150"> <img src="https://github.com/user-attachments/assets/7f834852-18a0-480e-aac8-ecd924085b10" width="150"> <img  src="https://github.com/user-attachments/assets/32f059e3-520c-46d9-9be1-fa9f3fda37ca" width="150"> <img  src="https://github.com/user-attachments/assets/4269af2a-24a5-4bdb-9a40-039ba7e95ef6" width="150"> <img src="https://github.com/user-attachments/assets/dcd996e8-a108-420c-be29-4a7270809924" width="150"> <img src="https://github.com/user-attachments/assets/d689d22f-8eae-4f65-9763-e684c47438d8" width="150"> |
| **🎥 Home Screen (Role Based)** | **🖼️ App Screenshots** |
| **Home screen** <br><br> <video src="https://github.com/user-attachments/assets/72e65b08-c20d-4210-9ec7-8b4ba6871fd2" width="220" controls></video> | <img src="https://github.com/user-attachments/assets/8a7eeb17-3c7a-45e0-a816-bf95a3001867" width="150"> &nbsp; <img src="https://github.com/user-attachments/assets/27e77c23-fcba-4c38-bd4a-4ca0c60a9662" width="150"> <img src="https://github.com/user-attachments/assets/0013103b-d893-4ae1-bcc7-46cd571b7f93" width="150"> <img src="https://github.com/user-attachments/assets/392f7abe-7ea2-4cce-9434-570d9c3a02ca" width="150"> <br><br> <img src="https://github.com/user-attachments/assets/41d7a286-3269-4d44-9506-75ff93f76808" width="150"> <img src="https://github.com/user-attachments/assets/23e5a801-97dd-4a07-ad3e-0c1bd2334b20" width="150"> <img src="https://github.com/user-attachments/assets/795ceec7-20fb-477f-93d7-eda455e2f849" width="150">  <img src="https://github.com/user-attachments/assets/83128d46-2c7d-47e4-b55b-14f73af40d72" width="150"> |

---

## 📱 Project Overview & Screens

**ReCloth** is a comprehensive mobile application developed using **Flutter** and **Firebase**. The project is dedicated to promoting environmental sustainability and the circular economy by providing a streamlined platform for donating, refurbishing, and reselling quality second-hand clothing at affordable prices.
### **1. Onboarding & Security**

*   **Splash Screen**: The first point of interaction featuring the app logo and the tagline: “Because Every Piece Tells a Story”.
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
---

## ⚙️ Core Functionalities

*   **Role-Based Access Control (RBAC)**: Distinct permissions for Admin and User roles to ensure data security.
*   **Real-time Synchronization**: Powered by Firebase Firestore to update order and donation statuses instantly.
*   **Automated Stock Management**: Inventory levels automatically decrease upon successful purchases.
*   **State Management**: Centralized app state using the Provider pattern to ensure high performance and clean code.
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

To run this project locally, follow these steps:
### 1. Prerequisites
*   Install [Flutter SDK](https://docs.flutter.dev/get-started/install).
*   Install [Firebase CLI](https://firebase.google.com/docs/cli).
### 2. Clone the Repository
     git clone [https://github.com/Nadeen218/Graduation-project.git](https://github.com/Nadeen218/Graduation-project.git)
     cd Graduation-project
### 3.Install Dependencies
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

---

## ⚖️ Rights & License
© 2026 **ReCloth Project**. All Rights Reserved for **Nadeen Abu Hilweh**.

This project was developed as a **Graduation Project** for the **Bachelor of Computer Science** degree to support the circular economy and environmental sustainability.

---

## 💻 Developer

**Nadeen Abu Hilweh**  
*   **GitHub**: [github.com/Nadeen218](https://github.com/Nadeen218)
*   **LinkedIn**: [LinkedIn](https://www.linkedin.com/in/nadeen-abu-hilweh/)
