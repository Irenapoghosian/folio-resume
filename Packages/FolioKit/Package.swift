// swift-tools-version: 5.10
import PackageDescription

/// Folio is split in two:
///
///   ResumeUI ──▶ ResumeCore (+ resume.json)
///
/// ResumeCore is plain Foundation: the résumé's types, loading and rules.
/// ResumeUI holds the screens, the view model and the PDF export.
let package = Package(
    name: "FolioKit",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "ResumeCore", targets: ["ResumeCore"]),
        .library(name: "ResumeUI", targets: ["ResumeUI"]),
    ],
    targets: [
        // The résumé itself lives here as JSON, so it is versioned, validated by tests and easy to edit.
        .target(name: "ResumeCore", resources: [.copy("Resources/resume.json")]),
        .target(name: "ResumeUI", dependencies: ["ResumeCore"]),

        .testTarget(name: "ResumeCoreTests", dependencies: ["ResumeCore"]),
        .testTarget(name: "ResumeUITests", dependencies: ["ResumeUI", "ResumeCore"]),
    ]
)
