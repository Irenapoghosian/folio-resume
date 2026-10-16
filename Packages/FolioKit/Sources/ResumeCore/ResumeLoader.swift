import Foundation

/// Reads `resume.json`.
public enum ResumeLoader {
    public enum LoadError: Error, Equatable {
        case missingFile
        case invalid(String)
    }

    public static func decode(_ data: Data) throws -> Resume {
        do {
            return try JSONDecoder().decode(Resume.self, from: data)
        } catch let error as DecodingError {
            throw LoadError.invalid(describe(error))
        }
    }

    public static func load(named name: String = "resume", in bundle: Bundle) throws -> Resume {
        guard let url = bundle.url(forResource: name, withExtension: "json") else { throw LoadError.missingFile }
        return try decode(Data(contentsOf: url))
    }

    /// The résumé shipped with the app.
    public static func bundled() throws -> Resume {
        try load(in: .module)
    }

    /// Where the shipped `resume.json` is, for tests that read it as text.
    public static var bundledFileURL: URL? {
        Bundle.module.url(forResource: "resume", withExtension: "json")
    }

    /// "projects[2].repository: …" instead of Swift's long debug description.
    private static func describe(_ error: DecodingError) -> String {
        switch error {
        case .keyNotFound(let key, let context):
            return "\(path(context.codingPath + [key])): missing"
        case .typeMismatch(_, let context), .valueNotFound(_, let context), .dataCorrupted(let context):
            return "\(path(context.codingPath)): \(context.debugDescription)"
        @unknown default:
            return String(describing: error)
        }
    }

    private static func path(_ keys: [CodingKey]) -> String {
        let parts = keys.map { key in key.intValue.map { "[\($0)]" } ?? ".\(key.stringValue)" }
        let joined = parts.joined()
        return joined.hasPrefix(".") ? String(joined.dropFirst()) : joined
    }
}
