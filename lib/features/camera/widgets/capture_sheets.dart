import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

import '../../poi/models/poi_model.dart';
import '../../poi/models/reference_image_model.dart';
import '../../poi/providers/media_provider.dart';
import '../../poi/providers/poi_provider.dart';

// Sheets and routing shared by both Anime Camera flows — the in-app camera
// (`CameraScreen`, used on iOS) and the phone's own camera with a floating
// reference window (Android, `openAnimeCamera`) — and the photo editor they
// hand their shots to.

/// Result of the photo editor's POI picker ([pickPhotoPoi]): an existing
/// POI to save the photo into, no POI (the photo then only goes to the
/// phone's gallery), or a request to create a POI first.
class PhotoPoiChoice {
  final String? poiId;
  final bool createNew;

  const PhotoPoiChoice.existing(String id) : poiId = id, createNew = false;

  const PhotoPoiChoice.none() : poiId = null, createNew = false;

  const PhotoPoiChoice.create() : poiId = null, createNew = true;
}

/// Bottom sheet listing every POI. Returns the picked POI's id, or null
/// when the sheet is dismissed or there are no POIs yet (with a snackbar).
Future<String?> pickPoiId(BuildContext context, WidgetRef ref) async {
  final poisMap = await ref.read(allPoisProvider.future);
  final pois = poisMap.values.toList();

  if (!context.mounted) return null;
  if (pois.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No POIs yet. Create one first.')),
    );
    return null;
  }

  final picked = await showModalBottomSheet<PoiModel>(
    context: context,
    backgroundColor: Colors.grey[900],
    builder: (ctx) => ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: pois.length,
      itemBuilder: (ctx, index) {
        final poi = pois[index];

        return ListTile(
          leading: const Icon(Icons.location_on, color: Colors.white70),
          title: Text(poi.name, style: const TextStyle(color: Colors.white)),
          subtitle: poi.address != null
              ? Text(
                  poi.address!,
                  style: const TextStyle(color: Colors.white54),
                )
              : null,
          onTap: () => Navigator.pop(ctx, poi),
        );
      },
    ),
  );
  return picked?.id;
}

/// Bottom sheet of [poiId]'s reference images. Returns the picked image once
/// its local file is confirmed to exist; null when the sheet is dismissed,
/// the POI has none, or the image is cloud-only / missing on disk.
Future<ReferenceImageModel?> pickPoiReferenceImage(
  BuildContext context,
  WidgetRef ref,
  String poiId,
) async {
  final images = await ref.read(referenceImagesByPoiProvider(poiId).future);

  if (!context.mounted) return null;
  if (images.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No reference images. Add some on the POI page.'),
      ),
    );
    return null;
  }

  final picked = await showModalBottomSheet<ReferenceImageModel>(
    context: context,
    backgroundColor: Colors.grey[900],
    builder: (ctx) => ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: images.length,
      itemBuilder: (ctx, index) {
        final image = images[index];

        // 1. Build a safe image widget with fallback strategy (Local -> Remote -> Placeholder)
        Widget imageWidget;
        if (image.localPath != null && image.localPath!.isNotEmpty) {
          imageWidget = Image.file(
            File(image.localPath!),
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const ColoredBox(
              color: Colors.black26,
              child: Icon(Icons.broken_image, color: Colors.white54),
            ),
          );
        } else if (image.remoteUrl != null && image.remoteUrl!.isNotEmpty) {
          imageWidget = Image.network(
            image.remoteUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const ColoredBox(
              color: Colors.black26,
              child: Icon(Icons.broken_image, color: Colors.white54),
            ),
          );
        } else {
          imageWidget = const ColoredBox(
            color: Colors.black26,
            child: Icon(Icons.image_not_supported, color: Colors.white54),
          );
        }

        // 2. Build a safe title with fallback text
        String titleText = 'Unknown Image';
        if (image.metadata != null && image.metadata!.isNotEmpty) {
          titleText = image.metadata!;
        } else if (image.localPath != null && image.localPath!.isNotEmpty) {
          titleText = p.basenameWithoutExtension(image.localPath!);
        } else if (image.remoteUrl != null && image.remoteUrl!.isNotEmpty) {
          titleText = 'Cloud Reference Image';
        }

        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(width: 52, height: 52, child: imageWidget),
          ),
          title: Text(
            titleText,
            style: const TextStyle(color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => Navigator.pop(ctx, image),
        );
      },
    ),
  );

  if (picked == null) return null;

  if (picked.localPath == null || picked.localPath!.isEmpty) {
    debugPrint('Local path is missing. This image might be cloud-only.');
    return null;
  }

  final file = File(picked.localPath!);
  if (!await file.exists()) {
    if (!context.mounted) return null;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Image file not found: ${picked.localPath}')),
    );
    return null;
  }
  return picked;
}

/// The photo editor's POI picker: which POI the photo is saved into — none
/// (only the phone's gallery), a new one, or an existing one. [current] is
/// ticked. Null when the sheet is dismissed.
Future<PhotoPoiChoice?> pickPhotoPoi(
  BuildContext context,
  WidgetRef ref, {
  String? current,
}) async {
  final poisMap = await ref.read(allPoisProvider.future);
  final pois = poisMap.values.toList();
  if (!context.mounted) return null;

  const tick = Icon(Icons.check, color: Colors.white);
  return showModalBottomSheet<PhotoPoiChoice>(
    context: context,
    backgroundColor: Colors.grey[900],
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.location_off, color: Colors.white),
            title: const Text('No POI', style: TextStyle(color: Colors.white)),
            subtitle: const Text(
              "Only save it to the phone's gallery",
              style: TextStyle(color: Colors.white54),
            ),
            trailing: current == null ? tick : null,
            onTap: () => Navigator.pop(ctx, const PhotoPoiChoice.none()),
          ),
          ListTile(
            leading: const Icon(Icons.add_location_alt, color: Colors.white),
            title: const Text(
              'Create new POI',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              'Save the photo into a POI you make now',
              style: TextStyle(color: Colors.white54),
            ),
            onTap: () => Navigator.pop(ctx, const PhotoPoiChoice.create()),
          ),
          const Divider(color: Colors.white24, height: 1),
          Flexible(
            child: pois.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No existing POIs yet.',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: pois.length,
                    itemBuilder: (ctx, index) {
                      final poi = pois[index];
                      return ListTile(
                        leading: const Icon(
                          Icons.location_on,
                          color: Colors.white70,
                        ),
                        title: Text(
                          poi.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: poi.address != null
                            ? Text(
                                poi.address!,
                                style: const TextStyle(color: Colors.white54),
                              )
                            : null,
                        trailing: poi.id == current ? tick : null,
                        onTap: () =>
                            Navigator.pop(ctx, PhotoPoiChoice.existing(poi.id)),
                      );
                    },
                  ),
          ),
        ],
      ),
    ),
  );
}

/// Hands a fresh capture straight to the photo editor, saving into [poiId]
/// when the shot was taken for one. Without one nobody is asked first: the
/// photo goes to the phone's gallery, and the editor's POI button can add a
/// POI (or a new one). [referencePath] / [referenceImageId] ride along for
/// the editor's overlay, Match Color, and the saved photo's link to its
/// reference frame.
///
/// The editor is pushed as a route, so backing out of it (save, discard)
/// returns to whatever opened the camera.
void openCaptureInEditor(
  BuildContext context, {
  required String photoPath,
  String? poiId,
  String? referencePath,
  String? referenceImageId,
}) {
  // A fresh capture isn't in the phone's gallery yet; the editor's Save puts
  // the original there next to the edit.
  final qs = <String, String>{
    'path': Uri.encodeComponent(photoPath),
    'capture': '1',
  };
  if (referencePath != null) qs['ref'] = Uri.encodeComponent(referencePath);
  if (referenceImageId != null) qs['refId'] = referenceImageId;
  final query = qs.entries.map((e) => '${e.key}=${e.value}').join('&');
  context.push(
    poiId == null ? '/photo-edit?$query' : '/pois/$poiId/photo-edit?$query',
  );
}
