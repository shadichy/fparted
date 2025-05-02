package vn.shadichy.parted

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import java.io.BufferedInputStream
import java.io.File
import java.io.FileOutputStream
import java.util.zip.ZipEntry
import java.util.zip.ZipInputStream

class MainActivity : FlutterActivity() {
//    override fun onCreate(savedInstanceState: Bundle?) {
//        super.onCreate(savedInstanceState)
//
//        val libDir = File(applicationInfo.nativeLibraryDir)
//
////        val marker = File(libDir, ".prebuilts_extracted")
////        if (!marker.exists()) {
//////            performExtraction()
////            marker.writeText("")
////        }
//    }

    private fun performExtraction() {
        val assetManager = assets
        assetManager.open("prebuilts.zip").use { input ->
            ZipInputStream(BufferedInputStream(input)).use { zis ->
                var entry: ZipEntry?
                while (zis.nextEntry.also { entry = it } != null) {
                    entry?.let { ze ->
                        val outFile = File(applicationInfo.nativeLibraryDir, ze.name)
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
}
