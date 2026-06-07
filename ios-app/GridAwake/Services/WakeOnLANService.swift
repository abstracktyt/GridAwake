import Foundation
import Network

// MARK: - Wake-on-LAN

enum WakeOnLANService {

    /// Build a 102-byte magic packet for the given MAC address.
    static func buildPacket(mac: String) -> Data? {
        let clean = mac
            .replacingOccurrences(of: ":", with: "")
            .replacingOccurrences(of: "-", with: "")
            .uppercased()

        guard clean.count == 12 else { return nil }

        var bytes = [UInt8]()
        for i in stride(from: 0, to: 12, by: 2) {
            let start = clean.index(clean.startIndex, offsetBy: i)
            let end   = clean.index(start, offsetBy: 2)
            guard let b = UInt8(clean[start..<end], radix: 16) else { return nil }
            bytes.append(b)
        }

        // 6 × 0xFF  +  16 × MAC
        var packet = [UInt8](repeating: 0xFF, count: 6)
        for _ in 0..<16 { packet.append(contentsOf: bytes) }
        return Data(packet)
    }

    /// Send a WoL magic packet via UDP broadcast on port 9.
    static func wake(mac: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let packet = buildPacket(mac: mac) else {
            completion(.failure(WoLError.invalidMAC))
            return
        }

        let conn = NWConnection(
            host: "255.255.255.255",
            port: 9,
            using: .udp
        )

        conn.stateUpdateHandler = { state in
            switch state {
            case .ready:
                conn.send(content: packet, completion: .contentProcessed { error in
                    DispatchQueue.main.async {
                        if let e = error { completion(.failure(e)) }
                        else             { completion(.success(())) }
                    }
                    conn.cancel()
                })
            case .failed(let err):
                DispatchQueue.main.async { completion(.failure(err)) }
            default:
                break
            }
        }

        conn.start(queue: .global(qos: .userInitiated))
    }

    enum WoLError: LocalizedError {
        case invalidMAC
        var errorDescription: String? { "Invalid MAC address (expected AA:BB:CC:DD:EE:FF)" }
    }
}
