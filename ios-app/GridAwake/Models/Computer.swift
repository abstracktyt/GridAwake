import Foundation

// MARK: - Computer

struct Computer: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var ip: String
    var port: Int = 7070
    var mac: String
    var secret: String = ""

    var agentBaseURL: URL? {
        URL(string: "http://\(ip):\(port)")
    }

    var isValid: Bool {
        !name.isEmpty && !ip.isEmpty && port > 0 && port <= 65535
    }

    /// Validate and normalise a MAC address string.
    var normalisedMAC: String {
        let clean = mac
            .replacingOccurrences(of: ":", with: "")
            .replacingOccurrences(of: "-", with: "")
            .uppercased()
        guard clean.count == 12 else { return mac }
        return stride(from: 0, to: 12, by: 2)
            .map { i -> String in
                let start = clean.index(clean.startIndex, offsetBy: i)
                let end   = clean.index(start, offsetBy: 2)
                return String(clean[start..<end])
            }
            .joined(separator: ":")
    }

    static let preview = Computer(name: "Gaming PC", ip: "192.168.1.50",
                                  port: 7070, mac: "AA:BB:CC:DD:EE:FF")
}
