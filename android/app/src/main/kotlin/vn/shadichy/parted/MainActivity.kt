package vn.shadichy.parted

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedInputStream
import java.io.File
import java.io.FileOutputStream
import java.util.zip.ZipEntry
import java.util.zip.ZipInputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "vn.shadichy.parted"
    private val REQUEST_CODE_OPEN_DIRECTORY = 1001
    private var resultPending: MethodChannel.Result? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val marker = File(context.filesDir, ".prebuilts_extracted")
        if (!marker.exists()) {
            performExtraction()
            marker.writeText("")
        }
    }

    private fun performExtraction() {
        val assetManager = assets
        assetManager.open("prebuilts.zip").use { input ->
            ZipInputStream(BufferedInputStream(input)).use { zis ->
                var entry: ZipEntry?
                while (zis.nextEntry.also { entry = it } != null) {
                    entry?.let { ze ->
                        val outFile = File(context.filesDir, ze.name)
                        if (ze.isDirectory) {
                            outFile.mkdirs()
                        } else {
                            outFile.parentFile?.mkdirs()
                            FileOutputStream(outFile).use { fos ->
                                val buffer = ByteArray(4096)
                                var count: Int
                                while (zis.read(buffer).also { count = it } > 0) {
                                    fos.write(buffer, 0, count)
                                }
                            }
                            outFile.setExecutable(true)
                        }
                        zis.closeEntry()
                    }
                }
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "pickFolder") {
                    if (resultPending != null) {
                        result.error("IN_PROGRESS", "A pickFolder call is already in progress", null)
                        return@setMethodCallHandler
                    }
                    resultPending = result
                    openFolderPicker()
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun openFolderPicker() {
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
            // Optionally: start at a specific location
            // putExtra(DocumentsContract.EXTRA_INITIAL_URI, initialUri)
        }
        startActivityForResult(intent, REQUEST_CODE_OPEN_DIRECTORY)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_CODE_OPEN_DIRECTORY) {
            val pending = resultPending ?: return
            resultPending = null

            if (resultCode == Activity.RESULT_OK && data != null) {
                val treeUri: Uri = data.data!!
                // Persist access permissions
                contentResolver.takePersistableUriPermission(
                    treeUri,
                    Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
                )
                pending.success(treeUri.toString())
            } else {
                // User cancelled or no data
                pending.success(null)
            }
        }
    }

}
