package com.example.trip_planner

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.provider.Settings
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.text.SimpleDateFormat
import java.util.*

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.trip_planner/camera"
    private val TAG = "AnimeCamera"
    private val REQUEST_CAMERA = 1001
    private val REQUEST_OVERLAY_PERMISSION = 1002
    private var pendingResult: MethodChannel.Result? = null
    private var photoPath: String? = null
    private var overlayImagePath: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasOverlayPermission" -> {
                        result.success(hasOverlayPermission())
                    }
                    "requestOverlayPermission" -> {
                        requestOverlayPermission()
                        result.success(true)
                    }
                    "launchCameraWithOverlay" -> {
                        val imagePath = call.argument<String>("imagePath")
                        if (imagePath == null) {
                            result.error("NO_IMAGE", "No reference image path provided", null)
                            return@setMethodCallHandler
                        }
                        pendingResult = result
                        overlayImagePath = imagePath
                        launchCameraWithOverlay(imagePath)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun hasOverlayPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(this)
        } else {
            true
        }
    }

    private fun requestOverlayPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:$packageName")
            )
            startActivityForResult(intent, REQUEST_OVERLAY_PERMISSION)
        }
    }

    private fun launchCameraWithOverlay(imagePath: String) {
        try {
            // Create temp file for the captured photo
            val timeStamp = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.US).format(Date())
            val storageDir = getExternalFilesDir(Environment.DIRECTORY_PICTURES)
            val photoFile = File.createTempFile("IMG_${timeStamp}_", ".jpg", storageDir)
            photoPath = photoFile.absolutePath

            val photoUri = FileProvider.getUriForFile(
                this,
                "${applicationContext.packageName}.fileprovider",
                photoFile
            )

            // Request notification permission (Android 13+) so the foreground
            // service notification is visible
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                if (ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS)
                    != PackageManager.PERMISSION_GRANTED) {
                    ActivityCompat.requestPermissions(
                        this, arrayOf(Manifest.permission.POST_NOTIFICATIONS), 1003
                    )
                }
            }

            // Start the overlay service with the reference image
            val overlayIntent = Intent(this, OverlayService::class.java).apply {
                putExtra("imagePath", imagePath)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(overlayIntent)
            } else {
                startService(overlayIntent)
            }
            Log.d(TAG, "Overlay service started with image: $imagePath")

            // Launch system camera
            val cameraIntent = Intent(MediaStore.ACTION_IMAGE_CAPTURE).apply {
                putExtra(MediaStore.EXTRA_OUTPUT, photoUri)
                addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
            }
            startActivityForResult(cameraIntent, REQUEST_CAMERA)
            Log.d(TAG, "Camera launched")
        } catch (e: Exception) {
            Log.e(TAG, "Error: ${e.message}", e)
            pendingResult?.error("CAMERA_ERROR", e.message, null)
            pendingResult = null
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        Log.d(TAG, "onActivityResult: request=$requestCode, result=$resultCode")

        if (requestCode == REQUEST_CAMERA) {
            // Stop the overlay
            stopService(Intent(this, OverlayService::class.java))

            if (resultCode == RESULT_OK && photoPath != null) {
                Log.d(TAG, "Photo captured: $photoPath")
                pendingResult?.success(photoPath)
            } else {
                Log.d(TAG, "Camera cancelled")
                pendingResult?.success(null)
                photoPath?.let { File(it).delete() }
            }
            pendingResult = null
            photoPath = null
        }
    }
}
