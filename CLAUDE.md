# Anime Pilgrimage Travel App - Trip Planner

## Project Overview
A local-first, cross-platform travel planning app for anime pilgrimage trips.
Built with Flutter (Dart). SQLite via Drift for local storage. Riverpod for state management.

## Architecture
- **Mobile App (Flutter)**: Primary execution environment. Offline-first, GPS, camera, AR.
- **PC Web (Next.js/React)**: Deep planning environment (future phase).
- **Sync Model**: Manual JSON export/import between platforms.

## Core Modules
1. **ROI (Region of Interest)**: Macro-container (e.g., "Kyoto City", "Akihabara") for grouping POIs
2. **POI (Point of Interest)**: Core location node with spatial data, metadata, media, scheduling
3. **Trip Calendar**: Time chunks for scheduling POIs with drag-and-drop
4. **Anime Camera**: AR silhouette overlay for recreating anime screenshots
5. **Ticket Organizer**: QR/booking management
6. **VLM Pipeline**: Gemini API for parsing screenshots into POI data via share extension

## Database Schema (SQLite via Drift)
- `rois`: id, name, description, is_offline_cached, created_at
- `pois`: id, roi_id, name, description, address, lat, lng, business_hours, contact_info, cover_image_uri, tags, anime_series_ref
- `time_chunks`: id, poi_id, date, start_time, end_time, status (backlog/scheduled/skipped/completed)
- `media_assets`: id, poi_id, type (reference_frame/user_photo/ticket_qr/audio_bgm), local_uri, remote_url, metadata

## Tech Stack
- Flutter / Dart
- State Management: Riverpod
- Local DB: Drift (SQLite)
- AI Integration: Gemini API (VLM)
- Camera: Flutter camera package
- Navigation: Go Router

## Conventions
- Feature-first folder structure under lib/
- Use Riverpod providers for state
- Drift for all database operations
- UUID for all primary keys
