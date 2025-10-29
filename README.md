# Pay — Mobile Wallet (Flutter)

Open-source Flutter app powering the **Brussels Pay** local payment network.  
Supports phone-number login, multi-currency wallets, QR payments, P2P transfers, and card-based spending.

---

## Features

- Phone number login (OTP-based)
- Switch between currencies (EUR, BPAY, etc.)
- Scan QR codes to pay
- Peer-to-peer transfers
- Import and manage cards
- Spend directly from imported cards
- Deep link and checkout integrations

---

## Tech stack

- **Framework:** Flutter (iOS, Android, Web)
- **Language:** Dart
- **Backend:** REST endpoints (external)
- **Auth:** Phone number verification (via Brevo through backend)
- **Storage:** Secure local device storage
- **Deep links:** Configurable domains and redirect URLs

---

## Environment configuration

Create a `.env` file in the project root (or use build-time `--dart-define` values).  
This file defines runtime URLs, domains, and defaults used by the app:

```bash
CHECKOUT_DOMAIN='https://checkout.brusselspay.be'
CARD_DOMAIN='https://cards.brusselspay.be'
APP_REDIRECT_DOMAIN='https://app.brusselspay.be'
DEEPLINK_DOMAINS='pay.brusselspay.be,brusselspay.page.link'

CHECKOUT_API_BASE_URL='https://api.checkout.brusselspay.be'
DASHBOARD_API_BASE_URL='https://api.dashboard.brusselspay.be'
ORIGIN_HEADER='https://brusselspay.be'

DEFAULT_PHONE_COUNTRY_CODE='+32'
```

Use .env.example as a reference.
Each domain must match your configured app deep links and backend CORS policy.

⸻

Setup
built for iOS and Android, other platforms not tested. 

1.	Install dependencies

```
flutter pub get
```

2.	Configure environment
Copy .env.example → .env and fill in your environment variables.

3.	Run the app

```
flutter run
```

Use `-d ios`, `-d android`, or `-d chrome` to target a specific platform.

⸻

Project structure

Folder	Purpose
lib/	Main Flutter source (modules for auth, wallet, payments, cards, settings)
assets/	Static assets: icons, translations, Lottie, etc.
test/	Unit and widget tests
android/, ios/, web/	Platform-specific build targets


⸻

Core flows

1. Authentication

Phone-number login with one-time password.
Stores a session key securely on device.

2. Currencies

User can hold and switch between multiple currency balances.

3. QR Codes

Scan or display QR codes to send or receive payments.

4. Peer-to-Peer

Transfer funds between users using phone numbers or wallet addresses.

5. Cards

Import physical or digital cards (e.g., membership, prepaid, community cards).
Spend directly from selected cards at checkout.

⸻

Deep link format

pay://<domain>/<action>?amount=<amount>&currency=<code>&memo=<text>

Used for merchant checkouts and in-app redirection after payment.

⸻

Build

# Android
flutter build appbundle

# iOS
flutter build ipa

# Web
flutter build web

Before release, set bundle IDs, signing configs, and domain associations (Apple/Android).

⸻

Security checklist
	•	Enforce HTTPS on all APIs
	•	Validate QR payloads before execution
	•	Store credentials securely (Keychain/Keystore)
	•	Limit OTP requests per phone number
	•	Restrict deep link domains to trusted hosts

⸻

Localization

Default language: English (en).
Additional translations: French (fr), Dutch (nl).

⸻

License

MIT License — see LICENSE.

⸻

Acknowledgements

Developed by Citizen Wallet for the Brussels Pay network.
Built with Flutter, focused on user-friendly, transparent local payments.

