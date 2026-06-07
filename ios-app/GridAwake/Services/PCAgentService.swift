import Foundation

// MARK: - PC Agent HTTP Client

actor PCAgentService {

    private let computer: Computer
    private let session: URLSession

    init(computer: Computer) {
        self.computer = computer
        let cfg = URLSessionConfiguration.default
        cfg.timeoutIntervalForRequest  = 8
        cfg.timeoutIntervalForResource = 10
        self.session = URLSession(configuration: cfg)
    }

    // MARK: - Public API

    func ping() async -> Bool {
        do {
            _ = try await get("/api/ping")
            return true
        } catch { return false }
    }

    func status() async throws -> PCStatus {
        let json = try await get("/api/status")
        return PCStatus(
            name:   json["name"]   as? String ?? computer.name,
            volume: json["volume"] as? Int    ?? 50,
            muted:  json["muted"]  as? Bool   ?? false
        )
    }

    func shutdown(delay: Int = 0) async throws {
        _ = try await post("/api/shutdown", body: ["delay": delay])
    }

    func restart(delay: Int = 0) async throws {
        _ = try await post("/api/restart", body: ["delay": delay])
    }

    func sleep() async throws {
        _ = try await post("/api/sleep")
    }

    func hibernate() async throws {
        _ = try await post("/api/hibernate")
    }

    func lock() async throws {
        _ = try await post("/api/lock")
    }

    func cancelAction() async throws {
        _ = try await post("/api/cancel")
    }

    func setVolume(_ level: Int) async throws {
        _ = try await post("/api/volume", body: ["level": level])
    }

    // MARK: - Private helpers

    private func get(_ path: String) async throws -> [String: Any] {
        try await request(path: path, method: "GET")
    }

    private func post(_ path: String, body: [String: Any]? = nil) async throws -> [String: Any] {
        try await request(path: path, method: "POST", body: body)
    }

    private func request(path: String, method: String, body: [String: Any]? = nil) async throws -> [String: Any] {
        guard let base = computer.agentBaseURL else { throw AgentError.noURL }

        var req = URLRequest(url: base.appendingPathComponent(path))
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if !computer.secret.isEmpty {
            req.setValue(computer.secret, forHTTPHeaderField: "X-GridAwake-Secret")
        }
        if let body { req.httpBody = try JSONSerialization.data(withJSONObject: body) }

        let (data, response) = try await session.data(for: req)

        guard let http = response as? HTTPURLResponse else { throw AgentError.badResponse }
        guard (200...299).contains(http.statusCode)   else { throw AgentError.statusCode(http.statusCode) }

        return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] ?? [:]
    }

    // MARK: - Errors

    enum AgentError: LocalizedError {
        case noURL
        case badResponse
        case statusCode(Int)

        var errorDescription: String? {
            switch self {
            case .noURL:            return "Invalid computer URL"
            case .badResponse:      return "Invalid server response"
            case .statusCode(let c): return "Server error \(c)"
            }
        }
    }
}

// MARK: - Response model

struct PCStatus {
    let name: String
    let volume: Int
    let muted: Bool
}
