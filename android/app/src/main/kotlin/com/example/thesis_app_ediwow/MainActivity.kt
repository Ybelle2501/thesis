package com.example.thesis_app_ediwow

import android.Manifest
import android.content.ContentValues
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.DocumentsContract
import android.provider.MediaStore
import android.provider.OpenableColumns
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
        private const val BACKUP_CHANNEL =
            "com.example.thesis_app_ediwow/data_backup"
        private const val WRITE_STORAGE_REQUEST = 4107
        private const val PICK_BACKUP_REQUEST = 4108
        private const val MAX_BACKUP_BYTES = 250 * 1024 * 1024
        private const val BACKUP_FOLDER = "LeafLens Data"
        private const val BACKUP_FILE = "leaflens_backup.leaflensbackup"
    }

    private data class PendingSave(
        val filename: String,
        val folderName: String,
        val bytes: ByteArray,
        val result: MethodChannel.Result,
    )

    private data class PendingBackup(
        val bytes: ByteArray,
        val result: MethodChannel.Result,
    )

    private var pendingSave: PendingSave? = null
    private var pendingBackup: PendingBackup? = null
    private var pendingImport: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, STORAGE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "savePdfToDownloads" -> handleSaveRequest(call, result)
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BACKUP_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "saveBackup" -> handleBackupSave(call, result)
                    "pickBackup" -> openBackupPicker(result)
                    else -> result.notImplemented()
                }
            }
    }

    private fun handleBackupSave(call: MethodCall, result: MethodChannel.Result) {
        val bytes = call.argument<ByteArray>("bytes")
        val filename = call.argument<String>("filename")
        if (bytes == null || filename != BACKUP_FILE) {
            result.error("INVALID_BACKUP", "The LeafLens backup data is invalid.", null)
            return
        }
        if (bytes.size > MAX_BACKUP_BYTES) {
            result.error("BACKUP_TOO_LARGE", "The backup is larger than 250 MB.", null)
            return
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            saveBackupWithMediaStore(bytes, result)
            return
        }

        if (
            Build.VERSION.SDK_INT < Build.VERSION_CODES.M ||
                checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) ==
                PackageManager.PERMISSION_GRANTED
        ) {
            saveBackupLegacy(bytes, result)
            return
        }
        if (pendingBackup != null || pendingSave != null) {
            result.error("SAVE_IN_PROGRESS", "Another file is already being saved.", null)
            return
        }
        pendingBackup = PendingBackup(bytes, result)
        requestPermissions(
            arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE),
            WRITE_STORAGE_REQUEST,
        )
    }

    private fun saveBackupWithMediaStore(bytes: ByteArray, result: MethodChannel.Result) {
        var uri: Uri? = null
        var committed = false
        val relativeDirectory = "${Environment.DIRECTORY_DOWNLOADS}/$BACKUP_FOLDER"
        try {
            val collection = MediaStore.Downloads.EXTERNAL_CONTENT_URI
            val values = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, "$BACKUP_FILE.pending")
                put(MediaStore.MediaColumns.MIME_TYPE, "application/octet-stream")
                put(MediaStore.MediaColumns.RELATIVE_PATH, relativeDirectory)
                put(MediaStore.MediaColumns.IS_PENDING, 1)
            }
            val backupUri = contentResolver.insert(collection, values)
                ?: throw IOException("Android could not create the backup file.")
            uri = backupUri
            contentResolver.openOutputStream(backupUri, "w")?.use { output ->
                output.write(bytes)
                output.flush()
            } ?: throw IOException("Android could not write the backup file.")

            values.clear()
            values.put(MediaStore.MediaColumns.DISPLAY_NAME, BACKUP_FILE)
            values.put(MediaStore.MediaColumns.IS_PENDING, 0)
            if (contentResolver.update(backupUri, values, null, null) <= 0) {
                throw IOException("Android could not finalize the backup file.")
            }
            committed = true

            val selection = "${MediaStore.MediaColumns.DISPLAY_NAME}=? AND " +
                "${MediaStore.MediaColumns.RELATIVE_PATH}=?"
            contentResolver.query(
                collection,
                arrayOf(MediaStore.MediaColumns._ID),
                selection,
                arrayOf(BACKUP_FILE, "$relativeDirectory/"),
                null,
            )?.use { cursor ->
                val idColumn = cursor.getColumnIndexOrThrow(MediaStore.MediaColumns._ID)
                while (cursor.moveToNext()) {
                    val existing = Uri.withAppendedPath(
                        collection,
                        cursor.getLong(idColumn).toString(),
                    )
                    if (existing != backupUri) contentResolver.delete(existing, null, null)
                }
            }
            result.success("$relativeDirectory/$BACKUP_FILE")
        } catch (error: Exception) {
            if (!committed) uri?.let { contentResolver.delete(it, null, null) }
            result.error("BACKUP_SAVE_FAILED", error.message ?: "Could not save backup.", null)
        }
    }

    @Suppress("DEPRECATION")
    private fun saveBackupLegacy(bytes: ByteArray, result: MethodChannel.Result) {
        try {
            val downloads = Environment.getExternalStoragePublicDirectory(
                Environment.DIRECTORY_DOWNLOADS,
            )
            val directory = File(downloads, BACKUP_FOLDER)
            if (!directory.exists() && !directory.mkdirs()) {
                throw IOException("Could not create the LeafLens Data folder.")
            }
            val temporaryFile = File(directory, "$BACKUP_FILE.pending")
            val backupFile = File(directory, BACKUP_FILE)
            val previousFile = File(directory, "$BACKUP_FILE.previous")
            FileOutputStream(temporaryFile).use { output ->
                output.write(bytes)
                output.flush()
            }
            if (previousFile.exists() && !previousFile.delete()) {
                throw IOException("Could not replace the previous backup safely.")
            }
            if (backupFile.exists() && !backupFile.renameTo(previousFile)) {
                throw IOException("Could not preserve the previous backup.")
            }
            if (!temporaryFile.renameTo(backupFile)) {
                if (previousFile.exists()) previousFile.renameTo(backupFile)
                throw IOException("Could not finalize the new backup file.")
            }
            previousFile.delete()
            result.success("${Environment.DIRECTORY_DOWNLOADS}/$BACKUP_FOLDER/$BACKUP_FILE")
        } catch (error: Exception) {
            result.error("BACKUP_SAVE_FAILED", error.message ?: "Could not save backup.", null)
        }
    }

    private fun openBackupPicker(result: MethodChannel.Result) {
        if (pendingImport != null) {
            result.error("PICKER_IN_PROGRESS", "The file picker is already open.", null)
            return
        }
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "*/*"
            putExtra(
                Intent.EXTRA_MIME_TYPES,
                arrayOf("application/octet-stream", "application/zip"),
            )
            val initialFolder = Uri.parse(
                "content://com.android.externalstorage.documents/document/" +
                    "primary%3ADownload%2FLeafLens%20Data",
            )
            putExtra(DocumentsContract.EXTRA_INITIAL_URI, initialFolder)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        pendingImport = result
        try {
            startActivityForResult(intent, PICK_BACKUP_REQUEST)
        } catch (error: Exception) {
            pendingImport = null
            result.error("PICKER_FAILED", error.message ?: "Could not open file picker.", null)
        }
    }

    @Suppress("DEPRECATION")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode != PICK_BACKUP_REQUEST) {
            super.onActivityResult(requestCode, resultCode, data)
            return
        }
        val result = pendingImport ?: return
        pendingImport = null
        if (resultCode != RESULT_OK) {
            result.success(null)
            return
        }
        val uri = data?.data
        if (uri == null) {
            result.error("NO_FILE", "No backup file was selected.", null)
            return
        }
        try {
            val name = contentResolver.query(uri, null, null, null, null)?.use { cursor ->
                val column = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                if (column >= 0 && cursor.moveToFirst()) cursor.getString(column) else null
            } ?: uri.lastPathSegment.orEmpty()
            if (!name.endsWith(".leaflensbackup", ignoreCase = true)) {
                result.error("INVALID_FILE_TYPE", "Select a .leaflensbackup file.", null)
                return
            }
            val bytes = contentResolver.openInputStream(uri)?.use { input ->
                val output = java.io.ByteArrayOutputStream()
                val buffer = ByteArray(8192)
                var total = 0
                while (true) {
                    val count = input.read(buffer)
                    if (count < 0) break
                    total += count
                    if (total > MAX_BACKUP_BYTES) {
                        throw IOException("The backup is larger than 250 MB.")
                    }
                    output.write(buffer, 0, count)
                }
                output.toByteArray()
            } ?: throw IOException("Android could not read the selected backup.")
            result.success(mapOf("name" to name, "bytes" to bytes))
        } catch (error: Exception) {
            result.error("BACKUP_READ_FAILED", error.message ?: "Could not read backup.", null)
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

        val save = pendingSave
        val backup = pendingBackup
        pendingSave = null
        pendingBackup = null
        if (save == null && backup == null) return
        if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            if (save != null) saveLegacy(save) else saveBackupLegacy(backup!!.bytes, backup.result)
        } else {
            if (save != null) {
                save.result.error(
                    "PERMISSION_DENIED",
                    "Storage permission is required to save reports in Downloads.",
                    null,
                )
            } else {
                backup!!.result.error(
                    "PERMISSION_DENIED",
                    "Storage permission is required to save backups in Downloads.",
                    null,
                )
            }
        }
    }
}
