# CineVerse

CineVerse is a Flutter movie and TV discovery app with a dark, streaming-service-inspired interface. It supports a local sample catalogue for demos and can optionally use The Movie Database (TMDB) for live discovery metadata.

## Features

- Home screen with a featured title and horizontal catalogue sections.
- Movies, TV Shows, Search, title details, related titles, My List, and Profile & Settings screens.
- Local sample catalogue with search, genre filtering, ratings, descriptions, dates, and movie/TV metadata.
- Add and remove titles from a watchlist persisted on the device.
- Guest browsing and a demo login/sign-up flow.
- Optional TMDB discovery and search when credentials are configured.
- Poster and backdrop photographs loaded from Unsplash, with a styled fallback if a request fails.

The login form is a UI demo and does not authenticate against an account service. The app provides discovery metadata and does not stream full-length movies or shows.

## Technologies

- Flutter and Dart
- Material widgets
- `http` for optional TMDB requests
- `shared_preferences` for local preferences and watchlist storage
- Unsplash CDN image URLs for sample-catalogue artwork

## Prerequisites

- Flutter SDK installed and available on `PATH` (`flutter --version` should work).
- A supported browser such as Google Chrome to run the web app.
- Internet access for remote poster artwork and, optionally, live TMDB requests.

## Setup and run on the web

From the project root:

```bash
flutter pub get
flutter run -d chrome
```

No API key is required for the demo catalogue. If Chrome is not detected automatically, check `flutter devices` and make sure Chrome is installed.

## Demo catalogue

When TMDB credentials are absent, CineVerse automatically uses its clearly labeled local sample catalogue. It contains original sample movie and TV titles; its descriptions, ratings, genres, and dates are sample data, not TMDB results. Artwork is illustrative photography associated by theme with these sample titles, not official movie posters. Image requests require a network connection. If an image cannot load, CineVerse displays a styled fallback and the rest of the app remains usable.

Search, category filtering, details, related-title suggestions, and My List use the local catalogue in demo mode. The watchlist and app preferences are stored locally on the device.

## Optional TMDB configuration

To use live TMDB discovery, create an API key in your TMDB account settings. The repository includes [`tmdb.secrets.json.example`](tmdb.secrets.json.example) as a placeholder template. Copy it to the ignored local file `tmdb.secrets.json` and replace the placeholder with your key:

```powershell
Copy-Item tmdb.secrets.json.example tmdb.secrets.json
notepad tmdb.secrets.json
```

The JSON should use the compile-time field expected by the app:

```json
{
  "TMDB_API_KEY": "YOUR_TMDB_V3_API_KEY"
}
```

You can instead provide a TMDB read access token using `TMDB_READ_ACCESS_TOKEN`. Start the app from the project root and pass the local file at build time:

```bash
flutter run -d chrome --dart-define-from-file=tmdb.secrets.json
```

Flutter Web cannot read a local secrets file after startup. `--dart-define-from-file` supplies its values when building the app. Any credential embedded in a web build is visible to its users; use a backend proxy for a public production deployment. Never commit `tmdb.secrets.json`, API keys, or access tokens. The checked-in example contains a placeholder only.

## Checks

```bash
flutter pub get
dart format lib
flutter analyze
flutter test
```
