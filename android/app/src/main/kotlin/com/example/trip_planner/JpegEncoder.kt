package com.example.trip_planner

import android.graphics.Bitmap
import android.util.Log
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.BinaryCodec
import io.flutter.plugin.common.BinaryMessenger
import java.io.ByteArrayOutputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder

/**
 * The `trip_planner/jpeg` channel: JPEG-encodes the editor's full-resolution
 * render with Android's own encoder (libjpeg-turbo), several times faster
 * than the pure-Dart one in package:image (`encodeJpeg` in
 * `full_res_render.dart`, which falls back to that if this fails).
 *
 * The message is a 12-byte little-endian header (width, height, quality)
 * followed by the RGBA pixels; the reply is the JPEG, or empty on failure.
 * Runs on a background task queue, off the main thread.
 */
object JpegEncoder {
    private const val TAG = "JpegEncoder"

    fun register(messenger: BinaryMessenger) {
        BasicMessageChannel(
            messenger,
            "trip_planner/jpeg",
            // Hands over the message without copying it; it stays valid
            // while the handler runs, which is all it's needed for.
            BinaryCodec.INSTANCE_DIRECT,
            messenger.makeBackgroundTaskQueue(),
        ).setMessageHandler { message, reply ->
            reply.reply(message?.let { encode(it) })
        }
    }

    private fun encode(message: ByteBuffer): ByteBuffer? {
        var bitmap: Bitmap? = null
        return try {
            message.order(ByteOrder.LITTLE_ENDIAN)
            val width = message.int
            val height = message.int
            val quality = message.int
            bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
            // ARGB_8888 keeps its pixels as R G B A bytes, the layout sent;
            // copying starts at the buffer's position, just past the header.
            bitmap.copyPixelsFromBuffer(message)
            val out = ByteArrayOutputStream()
            if (!bitmap.compress(Bitmap.CompressFormat.JPEG, quality, out)) return null
            val jpeg = out.toByteArray()
            // The reply's length is its position, so it isn't flipped.
            ByteBuffer.allocateDirect(jpeg.size).put(jpeg)
        } catch (e: Throwable) {
            // Out of memory included: the Dart side then encodes it itself.
            Log.w(TAG, "encode failed", e)
            null
        } finally {
            bitmap?.recycle()
        }
    }
}
