package com.example.thesis_app_ediwow

import android.Manifest
import android.content.ContentValues
import android.content.pm.PackageManager
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.io.IOException

class MainActivity : FlutterActivity() {
    companion object {
        private const val STORAGE_CHANNEL =
            "com.example.thesis_app_ediwow/report_storage"
        private const val WRITE_STORAGE_REQUEST = 4107
    }

    private data class PendingSave(
        val filename: String,
        val folderName: String,
        val bytes: ByteArray,
        val result: MethodChannel.Result,
    )

    private var pendingSave: PendingSave? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, STORAGE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "savePdfToDownloads" -> handleSaveRequest(call, result)
                    else -> result.notImplemented()
                }
            }
    }

    private fun handleSaveRequest(call: MethodCall, result: MethodChannel.Result) {
        val filename = call.argument<String>("filename")
        val folderName = call.argument<String>("folderName")
        val bytes = call.argument<ByteArray>("bytes")
        if (filename.isNullOrBlank() || folderName.isNullOrBlank() || bytes == null) {
            result.error("INVALID_ARGUMENTS", "The report name, folder, or PDF data is missing.", null)
            return
        }

        val save = PendingSave(filename, folderName, bytes, result)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            saveWithMediaStore(save)
            return
        }

        if (
            Build.VERSION.SDK_INT < Build.VERSION_CODES.M ||
                checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) ==
                    PackageManager.PERMISSION_GRANTED
        ) {
            saveLegacy(save)
            return
        }

        if (pendingSave != null) {
            result.error("SAVE_IN_PROGRESS", "Another report is already being saved.", null)
            return
        }
        pendingSave = save
        requestPermissions(
            arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE),
            WRITE_STORAGE_REQUEST,
        )
    }

    private fun saveWithMediaStore(save: PendingSave) {
        var uri: android.net.Uri? = null
        try {
            val relativeDirectory = "${Environment.DIRECTORY_DOWNLOADS}/${save.folderName}"
            val values = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, save.filename)
                put(MediaStore.MediaColumns.MIME_TYPE, "application/pdf")
                put(MediaStore.MediaColumns.RELATIVE_PATH, relativeDirectory)
                put(MediaStore.MediaColumns.IS_PENDING, 1)
            }
            uri = contentResolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
                ?: throw IOException("Android could not create the report file.")
            contentResolver.openOutputStream(uri, "w")?.use { output ->
                output.write(save.bytes)
                output.flush()
            } ?: throw IOException("Android could not open the report file.")

            values.clear()
            values.put(MediaStore.MediaColumns.IS_PENDING, 0)
            contentResolver.update(uri, values, null, null)
            save.result.success("$relativeDirectory/${save.filename}")
        } catch (error: Exception) {
            uri?.let { contentResolver.delete(it, null, null) }
            save.result.error("SAVE_FAILED", error.message ?: "Could not save the PDF.", null)
        }
    }

    @Suppress("DEPRECATION")
    private fun saveLegacy(save: PendingSave) {
        try {
            val downloads = Environment.getExternalStoragePublicDirectory(
                Environment.DIRECTORY_DOWNLOADS,
            )
            val reportDirectory = File(downloads, save.folderName)
            if (!reportDirectory.exists() && !reportDirectory.mkdirs()) {
                throw IOException("Could not create the report folder.")
            }
            val reportFile = File(reportDirectory, save.filename)
            FileOutputStream(reportFile).use { output ->
                output.write(save.bytes)
                output.flush()
            }
            save.result.success(
                "${Environment.DIRECTORY_DOWNLOADS}/${save.folderName}/${save.filename}",
            )
        } catch (error: Exception) {
            save.result.error("SAVE_FAILED", error.message ?: "Could not save the PDF.", null)
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != WRITE_STORAGE_REQUEST) return

        val save = pendingSave ?: return
        pendingSave = null
        if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            saveLegacy(save)
        } else {
            save.result.error(
                "PERMISSION_DENIED",
                "Storage permission is required to save reports in Downloads.",
                null,
            )
        }
    }
}
