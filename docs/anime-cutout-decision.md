# Anime cutout → composite: tech decision

**Date:** 2026-05-30
**Feature:** Cut an object out of a reference anime image and composite it (deliberate "sticker" look) onto the user's real photo, inside the Anime Camera flow. On-device (edge), Flutter, Android-first (Pixel 6), iOS later. Color-matching is handled separately, so heavy alpha-matting / relighting is **not** needed.

## Decision: **Path A — auto-detect subjects + tap-to-pick** (not SAM)

Use the OS/SDK on-device subject-segmentation built-ins, with multi-subject mode so the user taps the subject they want. Ship this; revisit SAM only if arbitrary-region selection becomes a hard requirement.

- **Android (primary):** `google_mlkit_subject_segmentation` (Google ML Kit Subject Segmentation). On-device via Play Services (model downloaded on first use), no network at inference. Multi-subject mode returns each detected subject with its own **PNG cutout bitmap** (transparent background) + bounding box → render boxes as tap targets.
- **iOS (later):** ML Kit Subject Segmentation is **Android-only**. iOS needs a small **platform channel** to Apple's VisionKit `ImageAnalysisInteraction.subject(at:)` / Vision `VNGenerateForegroundInstanceMaskRequest` (iOS 17+, free, same tap-to-pick UX). Separate native work — deferred.

## Why Path A over promptable SAM (Path B)

From the 2026-05-30 deep-research pass (22 sources, adversarially verified):

- **No shipped OS/SDK built-in does freeform box/point (SAM-style) prompting.** Every production cutout API — Apple subject-lift, ML Kit Subject Segmentation, PhotoRoom's on-device Core ML cutout — is **automatic** or **tap-among-auto-detected-subjects**. (PhotoRoom-is-promptable and remove.bg specifics were *refuted* in verification.)
- **remove.bg is cloud-only** (no on-device SDK) → disqualified for an edge app.
- **isnet-anime / SkyTNT anime-segmentation is auto + character-only** → can't pick an arbitrary non-character object.
- **True promptable = the SAM family** (MobileSAM/EdgeSAM → ONNX → `onnxruntime_v2`, encode-once/prompt-many). Real and on-device-feasible (e.g. `shubham0204/Segment-Anything-Android`), but **no one has shipped distilled-SAM-in-Flutter end-to-end**, full SAM is slow on mobile, and EdgeSAM's "30+ FPS iPhone 14" is a **paper** figure, not production-verified. Too much risk/effort for the first cut.

Path A is the only **proven-in-production**, on-device, Flutter-reachable route — and since the object is usually the prominent subject of a reference frame, auto-detection should nail it.

## Gotchas (carry into the real implementation)
- ML Kit auto-detects "most prominent people, pets, or objects in the foreground" — a **small background prop may be missed**. That's the boundary where Path B (SAM) would be needed.
- **Static images only** (fine — cutting from a still reference).
- ~200 ms on a Pixel 7 Pro; Pixel 6 similar — fine for a one-shot tap, not a live feed.
- First use **downloads the model** via Play Services (needs network once).
- `Subject.bitmap` is **PNG bytes** (native does `Bitmap.compress(PNG)`), so `Image.memory(...)` / writing a `.png` works directly.
- Subject `startX/startY/width/height` are in **original-image pixel coords** — scale to the displayed image for the tap overlay.

## Where it lands in the app (the gate)
The cutout becomes a new artifact in the **`media_assets`** pipeline (likely a new `type`, e.g. `cutout_sticker`) and overlays onto a camera capture in the Anime Camera flow. That write path interacts with `persistMediaAsset` / the photo editor save flow — **verify before merge** (same class as the cover-wipe bug).

## Spike
`lib/features/anime/screens/cutout_spike_screen.dart`, reachable at **`/cutout-spike`** (temporary Home card "Cutout spike"). Pick any gallery image → ML Kit segments → tap a detected subject's box → preview + save its cutout PNG. Throwaway; not wired into Anime Camera. Android-only (uses ML Kit).

## Sources
- ML Kit Subject Segmentation (Android): https://developers.google.com/ml-kit/vision/subject-segmentation/android
- Apple Vision `VNGenerateForegroundInstanceMaskRequest`: https://developer.apple.com/documentation/vision/vngenerateforegroundinstancemaskrequest
- VisionKit `ImageAnalysisInteraction`: https://developer.apple.com/documentation/visionkit/imageanalysisinteraction
- PhotoRoom on-device Core ML: https://www.photoroom.com/inside-photoroom/core-ml-performance-2022
- MobileSAM (Path B reference): https://docs.ultralytics.com/models/mobile-sam
- On-device SAM via ONNX on Android (Path B feasibility): https://github.com/shubham0204/Segment-Anything-Android
- `onnxruntime_v2` Flutter plugin (Path B bridge): https://pub.dev/packages/onnxruntime_v2
