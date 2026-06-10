# Sync Engine — Review Findings & TODO

Review of `feature/sync-engine-core` (Firestore cloud sync for shared trips).
The push path, optimistic versioning, `syncLock`, and self-heal are solid and
working. The gaps below are what stand between "single-device backup" and real
two-way collaboration.

## 🔴 Blocker

- [ ] **Wire up `executePull` — sync is currently upload-only.**
  `executePull` is dead code (no caller, no Firestore snapshot listener); the
  only `.listen()` is the local DB watcher that triggers *push*. Results:
  - A collaborator's changes never download to other devices.
  - A 2nd member (local `cloudVersion 0`, cloud already at `1`) has their push
    rejected as "Local version obsolete" and, with no pull, can never reconcile
    → permanently stuck.
  Fix: call `executePull` on trip-open / app-foreground (ideally a `snapshots()`
  listener on the trip doc's `cloudVersion`), and **pull-before-push** when a
  push hits the obsolete-version path.

## 🔴 High

- [ ] **Deletes don't propagate.**
  Push hard-deletes the cloud chunk doc; `fetchTripData` returns only existing
  docs; pull iterates only those → a device that had the chunk never removes it.
  The `isRemoteDeleted` branch in pull is dead code (cloud docs never carry
  `isDeleted: true`).
  - [ ] **POI deletes are worse** — full-snapshot push never deletes, and pull
        only upserts → a deleted POI lingers in the cloud *and* on every device.
  Fix: reconcile by ID-set difference (delete local *synced* rows whose IDs are
  absent from the cloud set, for both chunks and POIs).

## 🟠 Medium

- [ ] **Multi-batch push isn't atomic.** Only the last batch bumps the version +
  releases the lock. If a later batch fails after an earlier one commits, the
  cloud holds partial chunks at the old version. Only a real risk at >490 ops
  (multiple batches); single-batch trips are fine.
- [ ] **`syncLock` is stealable on the lock-only path.** The
  `affectedKeys().hasOnly(['syncLock'])` rule branch lets any member overwrite
  `syncLock` unconditionally. The version-bump path checks ownership, so it's
  mostly contained, but the lock isn't bulletproof.
- [ ] **"Sync to Cloud now" / push bumps `cloudVersion` every call.** POIs are
  always in the push op list, so `ops` is rarely empty → version bumps even when
  nothing changed → peers pull needlessly (once pull is wired). Make it a no-op
  when nothing is dirty and the trip already exists.

## 🟡 Low

- [ ] **Conflict stash is lossy.** `_stashLocalEffort` keeps only date + original
  times; drops `sortOrder` / `duration` / `transitDuration` / `isFixedTime`. The
  rescued item becomes a bare backlog entry.
- [ ] **No in-flight guard on auto-push.** Rapid edits can launch overlapping
  `executePush` for the same ROI; the lock makes the 2nd throw "Resource locked"
  (caught/logged). Harmless but noisy. Consider a per-ROI in-flight flag.
- [ ] **Lock expiry uses the client clock.** `DateTime.now() + 30s` is compared
  against the server's `request.time` in rules → clock skew can expire a lock
  early/late. Consider `FieldValue.serverTimestamp()`-based expiry.
- [ ] **`get()`-per-write in rules.** Every chunk/POI write re-reads the trip doc
  via `isTripMember`; cost (and the per-request `get` limit) adds up on large
  batches.

## ✅ Decisions / notes

- **"Sync to Cloud now" button: keep it.** It's the only re-push trigger for a
  fully-synced trip, deleted-trip recovery, and POI-only changes. But it's
  push-only — once `executePull` exists it should pull-then-push.
- **POIs sync as a full snapshot** (no dirty-tracking columns), pushed/pulled
  whole. Fine for small trips; revisit if POI counts grow.
