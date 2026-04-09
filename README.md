# ShareWay — AI-Powered Ride-Sharing App

> Final Year Project · COMSATS University Islamabad  
> Bachelor of Artificial Intelligence · 2026  
> Team: Aymen Ali (fa23-bai-011) · Nimra Tahseen (fa23-bai-043) · Syed Shahzaib (fa23-bai-050)  
> Supervisor: Sir Shujaat Hussain

---

## Screens Included

| Screen | File | Description |
|---|---|---|
| Onboarding | `screens/onboarding.dart` | Splash + feature highlights |
| Login / Register | `screens/login.dart` | Tabbed sign-in & sign-up |
| Home | `screens/home.dart` | Ride feed, search, categories |
| Ride Details | `screens/ride_details.dart` | Map, driver info, fare, confirm |
| Host a Ride | `screens/host_ride.dart` | Offer ride form with preferences |
| Chat | `screens/chat.dart` | Real-time in-app messaging |
| Booking Confirmation | `screens/booking_confirmation.dart` | Receipt + booking ID |
| Wallet | `screens/wallet.dart` | Balance, card, transactions |
| Profile | `screens/profile.dart` | Stats, settings, menu |

---

## Tech Stack

- **Frontend**: Flutter 3.x (Dart) — cross-platform iOS & Android
- **UI Font**: Outfit via `google_fonts`
- **Backend**: Firebase (Auth, Firestore, Cloud Functions, Storage, FCM)
- **Maps**: Google Maps Flutter SDK + Geolocator
- **State**: Provider
- **Payments**: Stripe SDK (sandbox mode for prototype)

---

## Quick Start

### Prerequisites
- Flutter SDK ≥ 3.0.0
- Dart SDK ≥ 3.0.0
- Android Studio or VS Code with Flutter plugin
- A Firebase project

### 1. Clone & Install
```bash
git clone https://github.com/your-repo/shareway.git
cd shareway
flutter pub get
```

### 2. Firebase Setup
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project named **ShareWay**
3. Add Android app → download `google-services.json` → place in `android/app/`
4. Add iOS app → download `GoogleService-Info.plist` → place in `ios/Runner/`
5. Enable: Authentication (Email/Phone), Firestore, Storage, Cloud Messaging

### 3. Google Maps API
1. Get an API key from [Google Cloud Console](https://console.cloud.google.com)
2. Enable: Maps SDK for Android, Maps SDK for iOS, Places API, Directions API
3. Android: add to `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <meta-data android:name="com.google.android.geo.API_KEY"
              android:value="YOUR_API_KEY"/>
   ```
4. iOS: add to `ios/Runner/AppDelegate.swift`:
   ```swift
   GMSServices.provideAPIKey("YOUR_API_KEY")
   ```

### 4. Run
```bash
# Android
flutter run

# iOS
cd ios && pod install && cd ..
flutter run -d ios
```

---

## Project Structure

```
lib/
├── main.dart                    # App entry point & routes
├── theme.dart                   # Design system (colors, fonts, styles)
├── models/
│   └── ride.dart                # Ride data model
├── screens/
│   ├── onboarding.dart
│   ├── login.dart
│   ├── home.dart
│   ├── ride_details.dart
│   ├── host_ride.dart
│   ├── chat.dart
│   ├── booking_confirmation.dart
│   ├── wallet.dart
│   └── profile.dart
└── widgets/
    └── shared.dart              # Reusable components
```

---

## Firestore Collections

```
users/{uid}
  name, email, phone, rating, totalRides, carModel, carPlate, isVerified

rides/{rideId}
  driverId, pickup, destination, departureTime, price, seats, tags, status

bookings/{bookingId}
  rideId, passengerId, driverId, fare, status, createdAt

messages/{chatId}/messages/{msgId}
  senderId, text, timestamp

transactions/{txnId}
  userId, type (credit|debit), amount, description, timestamp
```

---

## Matching Algorithm (Sprint 3)

The AI matching engine uses **GeoHashing** + **route polyline overlap** to rank rides:

1. Convert pickup & destination to GeoHash cells
2. Query Firestore for rides within adjacent cells
3. Score matches by: route overlap %, time delta, price, rating
4. Return top-N sorted results

For advanced matching, a Python Cloud Function using `scikit-learn` K-Means clustering groups frequent commuters with overlapping trajectories.

---

## Color Palette

| Token | Hex | Usage |
|---|---|---|
| `brandGreen` | `#1B3022` | Primary actions, headers |
| `brandEspresso` | `#2C1B18` | Secondary, wallet header |
| `accent` | `#D4A853` | Gold highlights, savings |
| `background` | `#FAFAF8` | App background |
| `surface` | `#FFFFFF` | Cards, inputs |
| `sand` | `#F5F0EA` | Tags, stat boxes |
| `textMain` | `#1A1A1A` | Body text |
| `textSub` | `#6C757D` | Captions, hints |

---

## Development Sprints

| Sprint | Focus | Status |
|---|---|---|
| 1 | Auth, Onboarding, Profile | ✅ UI Complete |
| 2 | Home, Search, Google Maps | ✅ UI Complete |
| 3 | AI Matching Algorithm | 🔄 In Progress |
| 4 | Booking, Chat, Notifications | ✅ UI Complete |
| 5 | Wallet, Payments, Rating | ✅ UI Complete |

---

## License

Academic use only · COMSATS University Islamabad · 2026
