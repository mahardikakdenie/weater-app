# 🌤️ Weather App – Flutter + Firebase + BLoC

A modern, responsive weather application built with **Flutter**, powered by the **OpenWeatherMap One Call API 3.0**, secured with **Firebase Authentication & Firestore**, and architected using the **BLoC pattern** for clean, scalable state management.

![Weather App Preview](https://lh3.googleusercontent.com/rd-d/ALs6j_HbuB2OsJ_hcvo7sCkXwJb5y76BlW8iaPOl_1I16groc4mNewkOn--zPuvVGaa0b0x7LJZVz8p_K8xiT0PpMGNY8RSgNEe410zm_pYP-Rc4hfLlNN-X1FSCZB1iw2ZMbCuzu6QEDfiDM7KZTbnyshgQZ8wyzMqbVWMCcLGx44dwEQbjTqM6uQ2-Ds6fWWNgIOCv7p-FM0V9HJId0MqCPPkjH5WkKZTRa4U1YJsLPyQwv53s8yqGWFaj78HaNkT3KnTRgBvQsb3jDVA2itFI-oJqejMKunNbitHJy_2tnzCTcwYu-z2J8ONNjNOnrV2773BswxWh09_Iky7hwZidayMf4AAYYFH0Mvp-BhYY_ysxZMb7EPQL31JZrAt7ElUjByoAW7lkJZOYmx57Esrkp-wvC24s3iAYLSh1L7pMzaemp94uwAxKIMpCLVuVpW9C_bGHT5aEWTEIvzuwnJWq24EAIctx_fv_FSEYukHv4VFxs_aR89XhT8XifyrWkGSHio8FcK2ntIsocDA3U03fctUP2tqKLiBEkJ7KPCmSuJj9V2Y-4_fmOfe4cZmyP_65yxcY9k2FAN4sCAjG_JTBwo0kUJoGyv2pOgIzuzf0awKUC0R8RZu8c-GI0IoJxUSjULSDpB9w9T5R-Ww6_SE5GKyVPYYNqIPP23ChbXRegTaBzqAcrOGrSqP4b5xkq7bfAjst8HDHgVcvXVlJeIjSTWdqc_79TUitHarkQZCGqNoxziLpUKIBRuEcTdl53NeFkj8nafv65Wglb052SCpTc6OzZ24MhmrX513-uXNt6DEIwr8ZquHqdLq696Hb6TcVHLUxV-FINkq3g4lpkEJ89l53FXj36basxN2lICtJFB8-eB3VMieKopKsrV4v0Zh4j7yTU7iCH7gtTHRnc0f-wKH2dLVE1TlwV1MZIvs9amB7rp7GUlCYq_DtXKAD98ffYUBmo9wQQ3TxVYMPpxTfV70GeMYwDf3LrMQRhY0Vkww901T_hsQR3JgY5fH7cvvPxY5LZi79C9Q=w1418-h911?auditContext=prefetch)  

![Weather App Search Screen Preview](https://lh3.googleusercontent.com/rd-d/ALs6j_Ej-TM1yevBua4IZeXxddDIL5TY8Rvwzrk79-pNVA4BM40XqTSnj2g-QOpu2jKaKhulwZyLT7Q2XGxF3nLdEXS2uWUMDfDrQT1wFlyblqOz0-AWk25OTSihO5XQ8NIN1Rbqx5eW1Bxj4eNiCkmVetv9AtZKRYs0q4C4cz4v0EBRF6UAYOXLYbX29Y0uIHqELSNXgIZ8NToQ5Mmr7ISyyso8ucGHt0hX0btR3IUDvLhSgB7lkxpuxUSWXwk5YTMPAIGtoGUNwP5ldGAZE-DO5KzNPCHoE39-QqgrRCLgQM1d5Q1zeH7pXtBaHMA3782pQGVrb_GKMHHo5D2TKtxQS0ka9-sKib6RCSRHc9nZ9cqlaOmz-3YjbjMvuKlIi4qyxk2iUHGzLfiHQ9gEd4ggDMjIcfh8rKXEQK7BK3eziobeNaRxj7w-iQkk7lzpsNKwVHp85vPRUKSg6dHI115A0cQsdMJ_6JczatJwsKCfOOG0G334YQQGbklxX4IuTHtqc8XHbcM_UOjcYzvwitdYUHEb0iK3SsP8Q64jB22nEKikYGoC1fgJux8FJjBHy6lhXJ8gLltqDaq2WnEcpRo8ez2tDtTxyXiHqDPqedYO7L__MKeTgr8CmUxAnFz7h1pZ-RkEoNqkrIPU27_rGQ0ep_hcsZ6Qbo9vQ85tS2h0QCKRIw_cHHUARmzYbwWUwTYUVVxfGGQQLph6jXhTLDYbxslNZE5ovPty0orq0V34s4nJUBH5qUg8ktJvveURWMtFJf80svWiOmg7CO01Pq-1u7HwhFSVmbwDmiU_3FedP91SLnTExP7iDROgUoZuFWGnfESaU-kzqvKgCmxYjHwLkuUyB6B3qKJL8Cb8NDLgsVGQm9tAKfliMtLGGtU-nxfRLcBu_G6clw-Cr4X2QGD6ll0iubtd93Xj2CT9u1CvT9nLn6htTEss35UNfg0WAZFftNH13iealjMzHpJsipM8hLUm9QUUaDC1Wi4xS2W9-2ghOMgFR_EXAfIFeWs3-pAjqSeETMzyJoyd=w1418-h911?auditContext=prefetch)  
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
   git clone https://github.com/mahardikakdenie/weater-app.git
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
