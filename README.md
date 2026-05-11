# Blog App (Flutter)

Flutter mobile app with blog listing, **category filtering**, **infinite-scroll pagination**, **pull-to-refresh**, **search (debounced)**, **bookmarks** (local), and **authentication** (email/password + Google). Uses **Dio** for HTTP and **Provider** for state.

You can point the app at either:

1. **Your REST API** (paths below), by setting `API_BASE_URL`, or  
2. **Google Blogger API v3** as a ready-made backend when `API_BASE_URL` is empty.

## Technical stack

| Requirement | Implementation |
|-------------|----------------|
| Flutter (stable) | See `pubspec.yaml` / SDK constraint |
| State management | **Provider** (`ChangeNotifier`) |
| HTTP | **Dio** |
| Infinite scroll | Home feed scroll listener + page / `pageToken` |
| Local storage | **SharedPreferences** (bookmarks), **flutter_secure_storage** (mobile on profile) |
| Session | **Firebase Auth** persists the signed-in user on device |

## REST API (when `API_BASE_URL` is set)

Base URL should have **no trailing slash**. Example: `https://api.example.com/v1`.

| Spec | App request |
|------|-------------|
| `GET /blogs?page=1&category_id=` | `GET {base}/blogs?page=&category_id=&per_page=10` |
| `GET /blog/{id}` | `GET {base}/blog/{id}` |
| `GET /categories` | `GET {base}/categories` |
| `GET /search?q=` | `GET {base}/search?q=` |

Responses are parsed flexibly: blog lists may be under `data`, `items`, `blogs`, `results`, or `posts`. Pagination may use Laravel-style `meta.current_page` / `meta.last_page`, top-level `current_page` / `last_page`, or a full page of `per_page` results to infer another page. Single post may be the JSON object or `{ "data": { ... } }`.

Blog objects support common field names: `title`, `content` / `html` / `body`, `image` / `thumbnail`, `published` / `published_at`, `labels` / `tags`, `url` / `link`.

## Blogger fallback (when `API_BASE_URL` is empty)

| Spec | Blogger v3 |
|------|------------|
| `GET /blogs?page=&category_id=` | `GET .../blogs/{blogId}/posts` with `pageToken` and optional `labels` |
| `GET /blog/{id}` | `GET .../posts/{postId}` |
| `GET /categories` | Labels aggregated from a `posts.list` sample |
| `GET /search?q=` | `GET .../posts/search?q=` |

API reference: [Blogger API v3](https://developers.google.com/blogger/docs/3.0/reference/).

## Features (screens)

- **Login**: Email/password, Google Sign-In, validation, Firebase session.
- **Signup**: Name, email, mobile, password, validation; mobile stored in secure storage.
- **Home**: Blog cards, infinite scroll, pull-to-refresh, horizontal category chips.
- **Blog detail**: HTML (`flutter_html`), bookmark, share (`share_plus`).
- **Bookmarks**: List + `SharedPreferences` persistence.
- **Search**: Debounced input (~450 ms).
- **Profile**: Name, email, mobile, logout (clears secure profile field and signs out).

**Navigation**: `go_router` with bottom tabs (Home, Search, Bookmarks, Profile).

## Prerequisites

- Flutter SDK (**stable**), Dart per `environment` in `pubspec.yaml`.
- **Firebase** project: Authentication with Email/Password and Google; platform files configured (`firebase_options.dart`, `google-services.json`, `GoogleService-Info.plist` as needed).
- Either **`API_BASE_URL`** for your backend, or **Blogger API key** + **blog id** for the fallback.

## Configuration

1. Copy `assets/.env.example` to `assets/.env` and fill values (or use `--dart-define`).

```env
# REST mode (optional)
API_BASE_URL=

# Blogger mode when API_BASE_URL is empty
BLOGGER_API_KEY=your_key
BLOGGER_BLOG_ID=your_blog_id
```

2. Build/run with defines (optional):

```bash
flutter run \
  --dart-define=API_BASE_URL=https://api.example.com/v1
```

```bash
flutter run \
  --dart-define=BLOGGER_API_KEY=your_key \
  --dart-define=BLOGGER_BLOG_ID=your_blog_id
```

3. Firebase: enable providers in the console; for Google on Android add your app **SHA-1** to the Firebase Android app.

## Run

```bash
cd blog_app
flutter pub get
flutter run
```

## Build APK (optional)

```bash
flutter build apk --release \
  --dart-define=BLOGGER_API_KEY=your_key \
  --dart-define=BLOGGER_BLOG_ID=your_blog_id
```

Output: `build/app/outputs/flutter-apk/app-release.apk` (configure release signing as needed).

## Project layout (feature-first + MVVM)

- `lib/core/` — constants, Dio client, validators, errors.
- `lib/shared/` — models, `BlogRepository`, shared widgets (e.g. `BlogCard`).
- `lib/features/<feature>/` — ViewModels + `presentation/` screens.
- `lib/router/` — `go_router` and auth redirect.
- `lib/services/` — secure profile helpers.

## Deliverables

1. Flutter source (this repo).  
2. This README (setup + API mapping).  
3. APK: use `flutter build apk` above when you need a release binary.
