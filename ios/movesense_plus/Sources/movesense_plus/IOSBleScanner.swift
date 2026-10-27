import CoreBluetooth
import Foundation

private let movesenseServices = [
    CBUUID(string: "61353090-8231-49cc-b57a-886370740041"),
    CBUUID(string: "0000FDF3-0000-1000-8000-00805F9B34FB"),
]

final class IOSBleScanner: NSObject, CBCentralManagerDelegate {
    private let callbacks: MDSDartCallbacks
    private var centralManager: CBCentralManager!
    private var pendingScan = false
    private var peripherals = [UUID: CBPeripheral]()

    init(callbacks: MDSDartCallbacks) {
        self.callbacks = callbacks
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func setScanEnabled(_ enabled: Bool) {
        pendingScan = enabled
        guard centralManager.state == .poweredOn else {
            if enabled {
                callbacks.scanError(code: 0, message: "Bluetooth is not powered on.")
            }
            return
        }
        enabled ? startScan() : stopScan()
    }

    func connectForBleEvent(address: String) {
        guard let uuid = UUID(uuidString: address) else { return }
        let peripheral =
            peripherals[uuid]
            ?? centralManager.retrievePeripherals(withIdentifiers: [uuid]).first
        if let peripheral {
            peripherals[uuid] = peripheral
            centralManager.connect(peripheral, options: nil)
        }
    }

    func disconnectForBleEvent(address: String) {
        guard let uuid = UUID(uuidString: address), let peripheral = peripherals[uuid] else {
            return
        }
        centralManager.cancelPeripheralConnection(peripheral)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn, pendingScan {
            startScan()
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        callbacks.connection(type: "bleConnected", address: peripheral.identifier.uuidString)
    }

    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        peripherals[peripheral.identifier] = peripheral
        let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? peripheral.name
        guard let name, !name.isEmpty else { return }
        callbacks.scanDevice(name: name, address: peripheral.identifier.uuidString)
    }

    private func startScan() {
        guard !centralManager.isScanning else { return }
        centralManager.scanForPeripherals(
            withServices: movesenseServices,
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: true]
        )
    }

    private func stopScan() {
        guard centralManager.isScanning else { return }
        centralManager.stopScan()
    }
}
