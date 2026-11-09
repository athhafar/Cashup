package com.example.cash_up

import android.app.Activity
import android.content.Intent
import android.nfc.NfcAdapter
import android.nfc.TagLostException
import android.nfc.tech.IsoDep
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.IOException

class NfcBridge(
    private val activity: Activity,
    messenger: BinaryMessenger
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    private val adapter: NfcAdapter? = NfcAdapter.getDefaultAdapter(activity)
    private val main = Handler(Looper.getMainLooper())
    private var sink: EventChannel.EventSink? = null
    @Volatile private var isoDep: IsoDep? = null

    init {
        MethodChannel(messenger, "mini_cashupay/nfc").setMethodCallHandler(this)
        EventChannel(messenger, "mini_cashupay/nfc_events").setStreamHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isAvailable" -> result.success(adapter != null)
            "isEnabled" -> result.success(adapter?.isEnabled == true)
            "openSettings" -> {
                activity.startActivity(Intent(Settings.ACTION_NFC_SETTINGS))
                result.success(null)
            }
            "startSession" -> { startReader(); result.success(null) }
            "stopSession" -> { stopReader(); result.success(null) }
            "transceive" -> transceive(call.argument<String>("apdu"), result)
            else -> result.notImplemented()
        }
    }

    private fun startReader() {
        val a = adapter ?: return emit("error", "code" to "NFC_DISABLED")
        if (!a.isEnabled) return emit("error", "code" to "NFC_DISABLED")
        a.enableReaderMode(
            activity,
            { tag ->
                val uidHex = tag.id?.toHex() ?: "00000000"
                val iso = IsoDep.get(tag)
                if (iso != null) {
                    try {
                        iso.connect()
                        iso.timeout = 8000
                        isoDep = iso
                        emit("tagDiscovered", "uid" to uidHex, "hasIsoDep" to true)
                    } catch (e: IOException) {
                        emit("error", "code" to "CONNECT_FAILED")
                    }
                } else {
                    // Non-IsoDep card (e.g. Mifare / Contactless Token / e-Money / Flazz)
                    emit("tagDiscovered", "uid" to uidHex, "hasIsoDep" to false)
                }
            },
            NfcAdapter.FLAG_READER_NFC_A or NfcAdapter.FLAG_READER_NFC_B or
                NfcAdapter.FLAG_READER_NFC_F or NfcAdapter.FLAG_READER_NFC_V or
                NfcAdapter.FLAG_READER_SKIP_NDEF_CHECK,
            null
        )
    }

    fun stopReader() {
        adapter?.disableReaderMode(activity)
        try { 
            isoDep?.close() 
        } catch (_: Exception) {}
        isoDep = null
    }

    private fun transceive(hex: String?, result: MethodChannel.Result) {
        val iso = isoDep
        if (hex == null || iso == null || !iso.isConnected) {
            return result.error("TAG_LOST", "Tidak ada kartu terhubung", null)
        }
        Thread {
            try {
                val resp = iso.transceive(hex.hexToBytes()).toHex()
                main.post { result.success(resp) }
            } catch (e: TagLostException) {
                main.post { emit("tagLost"); result.error("TAG_LOST", e.message, null) }
            } catch (e: IOException) {
                main.post { result.error("IO_ERROR", e.message, null) }
            }
        }.start()
    }

    private fun emit(type: String, vararg extra: Pair<String, Any>) {
        main.post { sink?.success(mapOf("type" to type) + extra) }
    }

    override fun onListen(args: Any?, events: EventChannel.EventSink?) { sink = events }
    override fun onCancel(args: Any?) { sink = null }
}

private fun String.hexToBytes() = chunked(2).map { it.toInt(16).toByte() }.toByteArray()
private fun ByteArray.toHex() = joinToString("") { "%02X".format(it) }
