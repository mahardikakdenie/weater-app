# 🌤️ Weather App – Flutter + Firebase + BLoC

A modern, responsive weather application built with **Flutter**, powered by the **OpenWeatherMap One Call API 3.0**, secured with **Firebase Authentication & Firestore**, and architected using the **BLoC pattern** for clean, scalable state management.

![Weather App Preview](http://i.ibb.co.com/cSjYJJFt/Screenshot-2025-11-02-144342.png)  

![Weather App Search Screen Preview](http://i.ibb.co.com/cSjYJJFt/Screenshot-2025-11-02-144342.png)  
---

## ✨ Features

- 🌍 **Current weather** — temperature, humidity, wind speed, pressure, and condition
- 📅 **Hourly forecast** — next 48 hours in scrollable cards (via One Call API)
- 📆 **Tomorrow’s detailed summary** — high/low temps, "feels like", visibility, cloud cover
- ❤️ **Save favorite cities** — persisted securely in Firestore per user
- 🔐 **Google Sign-In** — seamless authentication with Firebase
- 🌓 **Glassmorphism UI** — elegant blur effects, dynamic gradients, and dark-mode-friendly design
- 📱 **Fully responsive** — optimized for phones and tablets
- 🧠 **BLoC architecture** — decoupled logic, easy to test and maintain
- 🚀 **Skeleton loaders** — smooth loading experience with custom animated placeholders

---

## 🛠️ Tech Stack

| Layer | Technology |
|------|------------|
| **Frontend** | Flutter (Dart) |
| **State Management** | `flutter_bloc` |
| **Authentication & Database** | Firebase (Auth + Firestore) |
| **Weather API** | [OpenWeatherMap One Call API 3.0](https://openweathermap.org/api) |
| **UI Components** | Custom widgets, `BackdropFilter`, `AnimatedScale`, `ListView.separated` |
| **Utilities** | `flutter_dotenv`, custom date/time formatters, extensions |

> 💡 The app uses the **free tier** of OpenWeatherMap (1,000 calls/day), which includes current weather, 48-hour hourly forecast, and 8-day daily forecast via One Call API 3.0.

---

## 📦 Installation

### Prerequisites
- Flutter SDK ≥ 3.19
- Dart ≥ 3.3
- A [Firebase project](https://console.firebase.google.com/) with:
  - **Authentication** enabled (Google provider)
  - **Firestore Database** created (in test mode or with proper rules)
- An [OpenWeatherMap API key](https://home.openweathermap.org/users/sign_up) (free account)

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/weather_app.git
   cd weather_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**  
   Create a `.env` file in the root directory:
   ```env
   FLUTTER_BASE_API_WEATER=your_actual_api_key_here
   ```

4. **Set up Firebase**
   - Download `google-services.json` (Android) from Firebase Console → Project Settings
   - Download `GoogleService-Info.plist` (iOS)
   - Place them in:
     - `android/app/google-services.json`
     - `ios/Runner/GoogleService-Info.plist`

5. **Run the app**
   ```bash
   flutter run
   ```

> ✅ Make sure your `.gitignore` includes `.env`, `google-services.json`, and `GoogleService-Info.plist`.

---

## 📁 Project Structure

```
lib/
├── bloc/               # WeatherBloc & ForecastBloc with events/states
├── model/              # Data models (WeatherResponse, ForecastResponse, etc.)
├── repository/         # WeatherRepository (calls OpenWeatherMap API)
├── services/           # Firebase service (optional abstraction layer)
├── utils/              # Helpers (e.g., timestamp_to_local.dart)
├── widgets/            # Reusable UI: BoxWeatherLoading, AvatarWidget, etc.
├── main.dart           # App entry point with BlocProviders
└── ...
```

---

## 🔒 Privacy & Security

- 🔑 API keys are loaded via `flutter_dotenv` and **never hardcoded**.
- 🛡️ User data (favorites) is stored in **user-scoped Firestore collections**.
- 🚫 No telemetry, ads, or third-party trackers.
- 📜 Firebase Security Rules should restrict read/write access to authenticated users only.

> ⚠️ **Never commit `.env` or Firebase config files to version control.**

---

## 📄 License

This project is licensed under the **MIT License** — see [LICENSE](LICENSE) for details.

---

## 🙌 Acknowledgements

- [OpenWeatherMap](https://openweathermap.org/) — for reliable, global weather data via One Call API 3.0
- [Firebase](https://firebase.google.com/) — for authentication and real-time database
- [Flutter](https://flutter.dev/) — for enabling beautiful cross-platform apps with a single codebase

---

> Made with ❤️ for weather enthusiasts and clean-code advocates.  
> Designed to be **simple, fast, and privacy-respecting**.
