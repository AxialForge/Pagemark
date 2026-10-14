package com.axialforge.pagemark

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.provider.DocumentsContract
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.io.File

/**
 * Lets Pagemark save its backup files into a folder the user picked with Android's own file picker (the Storage Access Framework).
 * That folder can live on the phone, a USB drive, or in Google Drive / OneDrive / Dropbox when those apps are installed; Android then
 * handles the cloud side, so Pagemark needs no sign-in and no permission beyond the one folder the user chose.
 */
class FolderChannel(private val activity: Activity, messenger: BinaryMessenger) {
    private var pendingPick: MethodChannel.Result? = null

    init {
        MethodChannel(messenger, "pagemark/folder").setMethodCallHandler { call, result ->
            when (call.method) {
                "pick" -> pick(result)
                "check" -> result.success(canWrite(call.argument<String>("tree") ?: ""))
                "write" -> background(result) {
                    write(call.argument<String>("tree")!!, call.argument<String>("name")!!, call.argument<String>("mime") ?: "application/octet-stream", call.argument<String>("path")!!)
                }
                "list" -> background(result) { list(call.argument<String>("tree")!!) }
                "delete" -> background(result) { DocumentsContract.deleteDocument(activity.contentResolver, Uri.parse(call.argument<String>("uri")!!)) }
                else -> result.notImplemented()
            }
        }
    }

    private fun pick(result: MethodChannel.Result) {
        pendingPick?.success(null)
        pendingPick = result
        val i = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).addFlags(
            Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION or Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION,
        )
        activity.startActivityForResult(i, REQ_TREE)
    }

    /** Called from MainActivity.onActivityResult. Returns true when the request was ours. */
    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != REQ_TREE) return false
        val r = pendingPick
        pendingPick = null
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) {
            r?.success(null)
            return true
        }
        activity.contentResolver.takePersistableUriPermission(uri, Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
        r?.success(mapOf("uri" to uri.toString(), "name" to displayName(uri)))
        return true
    }

    private fun root(tree: Uri): Uri = DocumentsContract.buildDocumentUriUsingTree(tree, DocumentsContract.getTreeDocumentId(tree))

    private fun displayName(tree: Uri): String =
        activity.contentResolver.query(root(tree), arrayOf(DocumentsContract.Document.COLUMN_DISPLAY_NAME), null, null, null)?.use { c ->
            if (c.moveToFirst()) c.getString(0) else null
        } ?: "Chosen folder"

    /** The permission we were given is still there and the folder still exists. */
    private fun canWrite(tree: String): Boolean {
        if (tree.isEmpty()) return false
        val uri = Uri.parse(tree)
        val held = activity.contentResolver.persistedUriPermissions.any { it.uri == uri && it.isWritePermission }
        if (!held) return false
        return try {
            activity.contentResolver.query(root(uri), arrayOf(DocumentsContract.Document.COLUMN_DOCUMENT_ID), null, null, null)?.use { it.moveToFirst() } ?: false
        } catch (e: Exception) {
            false
        }
    }

    private fun write(tree: String, name: String, mime: String, path: String): String {
        val treeUri = Uri.parse(tree)
        val doc = DocumentsContract.createDocument(activity.contentResolver, root(treeUri), mime, name)
            ?: throw IllegalStateException("The folder would not let Pagemark create a file.")
        activity.contentResolver.openOutputStream(doc, "w")!!.use { out ->
            File(path).inputStream().use { it.copyTo(out) }
        }
        return doc.toString()
    }

    private fun list(tree: String): List<Map<String, Any?>> {
        val treeUri = Uri.parse(tree)
        val children = DocumentsContract.buildChildDocumentsUriUsingTree(treeUri, DocumentsContract.getTreeDocumentId(treeUri))
        val out = mutableListOf<Map<String, Any?>>()
        activity.contentResolver.query(
            children,
            arrayOf(DocumentsContract.Document.COLUMN_DOCUMENT_ID, DocumentsContract.Document.COLUMN_DISPLAY_NAME, DocumentsContract.Document.COLUMN_LAST_MODIFIED),
            null, null, null,
        )?.use { c ->
            while (c.moveToNext()) {
                out.add(mapOf(
                    "uri" to DocumentsContract.buildDocumentUriUsingTree(treeUri, c.getString(0)).toString(),
                    "name" to c.getString(1),
                    "modified" to c.getLong(2),
                ))
            }
        }
        return out
    }

    /** File work off the main thread; the answer (or the error text) goes back on it. */
    private fun background(result: MethodChannel.Result, work: () -> Any?) {
        Thread {
            try {
                val v = work()
                activity.runOnUiThread { result.success(v) }
            } catch (e: Exception) {
                activity.runOnUiThread { result.error("folder", e.message ?: e.javaClass.simpleName, null) }
            }
        }.start()
    }

    companion object {
        const val REQ_TREE = 7301
    }
}
