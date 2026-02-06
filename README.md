# 💧 Hydro

**Smart Hydration. Connected Wellbeing.**

Hydro is a robust cross-platform mobile application built with Flutter that goes beyond simple water logging. It integrates device sensors, health data, and smart reminders to create a holistic wellness companion.

> *Bridging the gap between High-Fidelity Design and Production Code.*

---

### 🎨 UX/UI Case Study

Unlike many engineering projects, Hydro started with a **Human-Centered Design** process.
I conducted UX Research, defined User Personas, and created a complete Design System before writing a single line of code.

| **Visual Identity** | **High-Fidelity Mockups** |
| :---: | :---: |
| <img src="https://github.com/user-attachments/assets/5c8a5263-0ec8-475b-a657-5e7dd4dd3a0f" width="350" > | <img src="https://github.com/user-attachments/assets/ad283f1d-6aae-400f-b78d-84e00fb03916" width="350" > |

> 📂 **[View the Full Presentation (PDF)](Presentation.pdf)** to see the research, problem statement, and design iteration.

---

### 📦 Technologies

* **Framework:** Flutter (Dart 3.8+)
* **State Management:** Riverpod & Provider
* **Architecture:** Feature-First / Modular Architecture
* **Integrations:**
    * `health`: Syncs with Apple Health & Google Fit
    * `geolocator`: Location-based context
    * `flutter_local_notifications`: Smart local reminders
* **UI/UX:**
    * **Design System:** Custom "Water" Color Scale & Poppins Typography
    * **Components:** Glassmorphism (`glass_card.dart`), Lottie Animations
    * **Visualization:** `fl_chart` for hydration analytics

---

### 🦄 Features

Here is what makes Hydro technically interesting:

* **📍 Smart Context:** The app utilizes `location_service` to understand the user's environment, potentially adjusting hydration goals.
* **🍎 Health Ecosystem Sync:** Implemented a `health_repository` to read/write water data directly to the device's native health app.
* **🏆 Gamified Progress:** Features a `trophies` module with `confetti` animations to reward hydration streaks.
* **🔔 Local Notification Engine:** A custom `reminder_scheduler` that handles permissions and schedules notifications without needing a backend server.
* **🎨 Pixel-Perfect Implementation:** A faithful conversion of the Figma designs, featuring custom painters for water animations.

---

### 👩🏽‍🍳 The Process

I approached this project with a focus on **Scalability** and **Clean Code**.

1.  **Modular Architecture:** I organized the codebase into three main layers:
    * **`core/`**: Holds the "brains" of the app—services like `auth_service` and `health_repository`.
    * **`features/`**: Each domain (e.g., `dashboard`, `trophies`) is self-contained.
    * **`shared/`**: Reusable UI components like `glass_card` and `water_fab`.
2.  **The "Integration" Challenge:** Orchestrating multiple external services was complex. I created a robust `permission_helper` to manage Location, Notification, and Health permissions simultaneously.
3.  **State Management:** Using a reactive approach, I ensured that adding a water entry in the `dashboard` instantly updates the `history` graphs and syncs via the `health_repository`.

---

### 📚 What I Learned

Building Hydro pushed my understanding of the Flutter ecosystem:

* **Platform Channels:** Working with `health` and `geolocator` packages taught me how Flutter communicates with native iOS/Android APIs.
* **Routing Logic:** Implementing `go_router` with a centralized `app_router.dart` gave me fine-grained control over navigation stacks.
* **Data Persistence:** I learned to balance local storage (`shared_preferences`) for user settings with repository patterns for handling domain data.

---

### 🚦 Running the Project

1.  **Clone the repository:**
    ```bash
    git clone [https://gitlab.com/saifeddineraouzi-group/hydro.git](https://gitlab.com/saifeddineraouzi-group/hydro.git)
    ```
2.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Run the App:**
    ```bash
    flutter run
    ```
