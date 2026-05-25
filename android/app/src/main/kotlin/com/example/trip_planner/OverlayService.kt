package com.example.trip_planner

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.graphics.BitmapFactory
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.IBinder
import android.util.Log
import android.view.GestureDetector
import android.view.Gravity
import android.view.MotionEvent
import android.view.ScaleGestureDetector
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.ImageView

class OverlayService : Service() {
    private val TAG = "AnimeOverlay"
    private var windowManager: WindowManager? = null
    private var overlayContainer: FrameLayout? = null
    private var layoutParams: WindowManager.LayoutParams? = null
    private var scaleDetector: ScaleGestureDetector? = null

    private var currentWidth = 360
    private var currentHeight = 480
    private var imageAspectRatio = 3f / 4f  // width / height

    companion object {
        const val CHANNEL_ID = "overlay_service_channel"
        const val NOTIFICATION_ID = 1
        const val ACTION_STOP_OVERLAY = "com.example.trip_planner.STOP_OVERLAY"
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP_OVERLAY) {
            stopSelf()
            return START_NOT_STICKY
        }

        val imagePath = intent?.getStringExtra("imagePath")
        if (imagePath == null) {
            Log.e(TAG, "No image path provided")
            stopSelf()
            return START_NOT_STICKY
        }

        startForegroundNotification()
        showOverlay(imagePath)
        return START_NOT_STICKY
    }

    private fun startForegroundNotification() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Reference Overlay",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Shows while the reference image overlay is active"
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }

        val stopIntent = Intent(this, OverlayService::class.java).apply {
            action = ACTION_STOP_OVERLAY
        }
        val stopPendingIntent = PendingIntent.getService(
            this, 0, stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }.apply {
            setContentTitle("Reference Overlay Active")
            setContentText("Tap to stop the overlay")
            setSmallIcon(android.R.drawable.ic_menu_camera)
            setOngoing(true)
            setContentIntent(stopPendingIntent)
            addAction(
                Notification.Action.Builder(
                    null, "Stop Overlay", stopPendingIntent
                ).build()
            )
        }.build()

        startForeground(NOTIFICATION_ID, notification)
    }

    private fun showOverlay(imagePath: String) {
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager

        val bitmap = BitmapFactory.decodeFile(imagePath)
        if (bitmap == null) {
            Log.e(TAG, "Failed to decode image: $imagePath")
            stopSelf()
            return
        }

        // Lock aspect ratio from the actual image
        imageAspectRatio = bitmap.width.toFloat() / bitmap.height.toFloat()

        // Initial size preserving aspect ratio
        if (imageAspectRatio > 1) {
            currentWidth = 420
            currentHeight = (420 / imageAspectRatio).toInt()
        } else {
            currentHeight = 420
            currentWidth = (420 * imageAspectRatio).toInt()
        }

        // Frame container — white border with rounded corners
        val container = FrameLayout(this).apply {
            val border = GradientDrawable().apply {
                setColor(Color.parseColor("#1A000000"))
                setStroke(4, Color.WHITE)
                cornerRadius = 12f
            }
            background = border
            setPadding(6, 6, 6, 6)
        }

        // Reference image inside the frame
        val imageView = ImageView(this).apply {
            setImageBitmap(bitmap)
            scaleType = ImageView.ScaleType.FIT_CENTER
            alpha = 0.7f
        }
        container.addView(imageView, FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT
        ))

        // Use TOP|START gravity so x/y are absolute from top-left
        // This makes position math predictable during resize
        val layoutType = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }

        val displayMetrics = resources.displayMetrics
        val screenWidth = displayMetrics.widthPixels

        val params = WindowManager.LayoutParams(
            currentWidth,
            currentHeight,
            layoutType,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = screenWidth - currentWidth - 24
            y = 120
        }
        layoutParams = params

        // Double-tap to dismiss
        val doubleTapDetector = GestureDetector(this,
            object : GestureDetector.SimpleOnGestureListener() {
                override fun onDoubleTap(e: MotionEvent): Boolean {
                    stopSelf()
                    return true
                }
            }
        )

        // Pinch-to-resize — uses raw screen coords for stable focal tracking
        // (computed from MotionEvent in the touch listener, not from detector)
        var prevRawFocusX = 0f
        var prevRawFocusY = 0f
        var pendingFocusDx = 0f
        var pendingFocusDy = 0f

        scaleDetector = ScaleGestureDetector(this,
            object : ScaleGestureDetector.SimpleOnScaleGestureListener() {
                override fun onScale(detector: ScaleGestureDetector): Boolean {
                    val scaleFactor = detector.scaleFactor
                    val oldWidth = currentWidth
                    val oldHeight = currentHeight

                    val maxWidth = displayMetrics.widthPixels
                    val maxHeight = displayMetrics.heightPixels
                    currentWidth = (currentWidth * scaleFactor).toInt().coerceIn(80, maxWidth)
                    currentHeight = (currentWidth / imageAspectRatio).toInt()
                    if (currentHeight > maxHeight) {
                        currentHeight = maxHeight
                        currentWidth = (currentHeight * imageAspectRatio).toInt()
                    }
                    if (currentHeight < 80) {
                        currentHeight = 80
                        currentWidth = (currentHeight * imageAspectRatio).toInt()
                    }

                    // Scale from center
                    val dx = (oldWidth - currentWidth) / 2
                    val dy = (oldHeight - currentHeight) / 2
                    params.x += dx
                    params.y += dy

                    // Apply pending focal point delta from touch listener
                    params.x += pendingFocusDx.toInt()
                    params.y += pendingFocusDy.toInt()
                    pendingFocusDx = 0f
                    pendingFocusDy = 0f

                    params.width = currentWidth
                    params.height = currentHeight

                    try {
                        windowManager?.updateViewLayout(container, params)
                        container.requestLayout()
                    } catch (_: Exception) {}
                    return true
                }
            }
        )

        // Touch handling: single finger = drag, two fingers = resize
        var initialX = 0
        var initialY = 0
        var initialTouchX = 0f
        var initialTouchY = 0f
        var isDragging = false

        container.setOnTouchListener { view, event ->
            doubleTapDetector.onTouchEvent(event)

            // Compute focal point in RAW screen coordinates before passing to detector
            // This avoids feedback loops since the view itself moves during interaction
            if (event.pointerCount >= 2) {
                val rawFocusX = (event.getRawX(0) + event.getRawX(1)) / 2f
                val rawFocusY = (event.getRawY(0) + event.getRawY(1)) / 2f

                when (event.actionMasked) {
                    MotionEvent.ACTION_POINTER_DOWN -> {
                        prevRawFocusX = rawFocusX
                        prevRawFocusY = rawFocusY
                        pendingFocusDx = 0f
                        pendingFocusDy = 0f
                    }
                    MotionEvent.ACTION_MOVE -> {
                        pendingFocusDx = rawFocusX - prevRawFocusX
                        pendingFocusDy = rawFocusY - prevRawFocusY
                        prevRawFocusX = rawFocusX
                        prevRawFocusY = rawFocusY
                    }
                }
            }

            scaleDetector?.onTouchEvent(event)

            when {
                event.pointerCount == 1 && !(scaleDetector?.isInProgress == true) -> {
                    when (event.actionMasked) {
                        MotionEvent.ACTION_DOWN -> {
                            initialX = params.x
                            initialY = params.y
                            initialTouchX = event.rawX
                            initialTouchY = event.rawY
                            isDragging = true
                            true
                        }
                        MotionEvent.ACTION_MOVE -> {
                            if (isDragging) {
                                params.x = initialX + (event.rawX - initialTouchX).toInt()
                                params.y = initialY + (event.rawY - initialTouchY).toInt()
                                try {
                                    windowManager?.updateViewLayout(view, params)
                                } catch (_: Exception) {}
                            }
                            true
                        }
                        MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                            isDragging = false
                            true
                        }
                        else -> false
                    }
                }
                event.pointerCount > 1 -> {
                    isDragging = false
                    true
                }
                else -> true
            }
        }

        overlayContainer = container

        try {
            windowManager?.addView(container, params)
            Log.d(TAG, "Overlay added: ${currentWidth}x${currentHeight}")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to add overlay: ${e.message}", e)
            stopSelf()
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        try {
            overlayContainer?.let { windowManager?.removeView(it) }
        } catch (e: Exception) {
            Log.e(TAG, "Error removing overlay: ${e.message}")
        }
        overlayContainer = null
        windowManager = null
        Log.d(TAG, "Overlay removed")
    }
}
