package dk.carp.carp_movesense_flutter

import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.le.ScanCallback
import android.bluetooth.le.ScanFilter
import android.bluetooth.le.ScanResult
import android.bluetooth.le.ScanSettings
import android.os.ParcelUuid
import java.util.UUID

private val MOVESENSE_SERVICE_UUIDS = listOf(
    UUID.fromString("61353090-8231-49cc-b57a-886370740041"),
    UUID.fromString("0000FDF3-0000-1000-8000-00805F9B34FB")
)

/** BLE scanner filtered to Movesense services. */
class MovesenseBleScanner(
    private val bluetoothAdapter: BluetoothAdapter?,
    private val callbacks: MdsDartCallbacks
) {
    private val scanCallback = object : ScanCallback() {
        override fun onScanResult(callbackType: Int, result: ScanResult) {
            val device = result.device
            callbacks.scanDevice(result.scanRecord?.deviceName ?: device.name, device.address)
        }

        override fun onScanFailed(errorCode: Int) {
            callbacks.scanError(errorCode.toLong(), "BLE scan failed with code $errorCode")
        }
    }

    @SuppressLint("MissingPermission")
    fun setScanEnabled(enabled: Boolean) {
        if (enabled) startScan() else stopScan()
    }

    @SuppressLint("MissingPermission")
    private fun startScan() {
        val scanner = bluetoothAdapter?.bluetoothLeScanner
        if (scanner == null) {
            callbacks.scanError(0, "Bluetooth LE scanner is not available.")
            return
        }
        val filters = MOVESENSE_SERVICE_UUIDS.map {
            ScanFilter.Builder().setServiceUuid(ParcelUuid(it)).build()
        }
        try {
            scanner.startScan(filters, ScanSettings.Builder().build(), scanCallback)
        } catch (error: SecurityException) {
            callbacks.scanError(0, error.message ?: "Missing Bluetooth scan permission.")
        }
    }

    @SuppressLint("MissingPermission")
    private fun stopScan() {
        try {
            bluetoothAdapter?.bluetoothLeScanner?.stopScan(scanCallback)
        } catch (ignored: SecurityException) {
            // Permission may have been revoked after scanning started.
        }
    }
}
