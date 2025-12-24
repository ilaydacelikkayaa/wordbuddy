# WordBuddy

**WordBuddy** is an iOS vocabulary learning app built with **SwiftUI**. It supports user authentication, level selection, and a **daily lesson + review/learned** flow. The backend is powered by **Firebase Cloud Functions (Python)** and data is stored in **Firestore**.


[Uygulamanın Videosu](https://youtube.com/shorts/OCjBJrPKlyg?si=6LaG-RF_XsH3KoYH)

## Features
- iOS app with SwiftUI
- Sign up / sign in with Firebase Authentication
- Save user level and fetch level-based daily lessons
- Mark words as learned / not learned and list learned words
- Fill-in-the-blank quiz flow

## Tech Stack
**iOS**
- Swift 5, SwiftUI
- Combine
- Firebase iOS SDK: `FirebaseCore`, `FirebaseAuth`, `FirebaseFirestore`
- Networking: `URLSession`
- (UI) `PhotosUI` (import exists in the project)

**Backend**
- Firebase Cloud Functions (Python **3.11** / `python311`)
- `firebase_functions`
- `firebase_admin` (Firestore Admin)



## Quick Start

### 1) iOS
1. Open `WordBuddy.xcodeproj` with Xcode.
2. Create a Firebase project and add an iOS app.
3. Place `GoogleService-Info.plist` under `App/WordBuddy/`.
4. Run the app.

### 2) Backend (Functions)
```bash
cd WordBuddy/functions
python3.11 -m venv venv
source venv/bin/activate
pip install -r requirements.txt


Run with emulator:
cd WordBuddy
firebase emulators:start
In the iOS app, NetworkManager.swift uses an emulator base URL by default, e.g.:
http://127.0.0.1:5001/wordbuddy-app/us-central1

Functions Endpoints
POST /set_user_level — save user level
GET /get_daily_lesson — return daily lesson words (userId, level, lessonSize)
POST /process_review — process review/learning result
POST /reset_level_reviews — reset review data for a level
GET /get_learned_words — list learned words
POST /set_word_learned_status — set a word’s learned status

Notes
For production, update the baseURL to your deployed Functions URL.
Tighten Firestore Security Rules and Auth settings before going live.
