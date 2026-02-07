//
//  VendorLookup.swift
//  Wifi Bands
//
//  Created by Claude Code
//

import Foundation

/// Simple vendor lookup based on OUI (first 3 bytes of MAC address)
struct VendorLookup {
    /// Common vendor OUI prefixes
    private static let vendors: [String: String] = [
        // Apple
        "00:03:93": "Apple", "00:0D:93": "Apple", "A4:5E:60": "Apple",
        "F0:D1:A9": "Apple", "00:1B:63": "Apple", "04:0C:CE": "Apple",
        "10:DD:B1": "Apple", "8C:85:90": "Apple", "BC:D0:74": "Apple",

        // Netgear
        "00:1E:8C": "Netgear", "A0:21:B7": "Netgear", "E0:91:F5": "Netgear",
        "20:E5:2A": "Netgear", "C0:3F:0E": "Netgear",

        // TP-Link
        "F8:1A:67": "TP-Link", "50:C7:BF": "TP-Link", "A4:2B:8C": "TP-Link",
        "E8:DE:27": "TP-Link", "90:F6:52": "TP-Link", "14:CF:92": "TP-Link",

        // Linksys
        "00:18:E7": "Linksys", "68:7F:74": "Linksys", "C0:56:27": "Linksys",

        // ASUS
        "20:AA:4B": "ASUS", "04:D9:F5": "ASUS", "F8:32:E4": "ASUS",
        "08:60:6E": "ASUS", "1C:87:2C": "ASUS",

        // D-Link
        "00:15:E9": "D-Link", "00:26:5A": "D-Link", "B8:A3:86": "D-Link",

        // Cisco
        "00:00:0C": "Cisco", "00:01:42": "Cisco", "00:01:43": "Cisco",
        "00:01:63": "Cisco", "00:01:64": "Cisco",

        // Ubiquiti
        "00:27:22": "Ubiquiti", "04:18:D6": "Ubiquiti", "24:A4:3C": "Ubiquiti",
        "68:72:51": "Ubiquiti", "F0:9F:C2": "Ubiquiti",

        // Belkin
        "00:11:50": "Belkin", "08:86:3B": "Belkin", "94:44:52": "Belkin",

        // Google
        "3C:5A:B4": "Google", "F4:F5:D8": "Google", "00:1A:11": "Google",

        // Amazon
        "84:D6:D0": "Amazon", "00:71:47": "Amazon", "68:37:E9": "Amazon",

        // Samsung
        "00:12:FB": "Samsung", "00:15:99": "Samsung", "00:16:32": "Samsung",
        "5C:0A:5B": "Samsung", "60:6B:FF": "Samsung",

        // Huawei
        "00:18:82": "Huawei", "00:25:9E": "Huawei", "84:A8:E4": "Huawei",

        // Xiaomi
        "34:CE:00": "Xiaomi", "64:09:80": "Xiaomi", "78:11:DC": "Xiaomi",

        // Aruba
        "00:0B:86": "Aruba", "00:1A:1E": "Aruba", "24:DE:C6": "Aruba"
    ]

    /// Looks up vendor name from BSSID
    /// - Parameter bssid: MAC address in format "XX:XX:XX:XX:XX:XX"
    /// - Returns: Vendor name if found, nil otherwise
    static func vendor(from bssid: String?) -> String? {
        guard let bssid = bssid else { return nil }

        // Extract first 8 characters (XX:XX:XX) and convert to uppercase
        let prefix = String(bssid.prefix(8)).uppercased()
        return vendors[prefix]
    }
}
