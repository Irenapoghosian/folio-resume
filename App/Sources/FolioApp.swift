import ResumeCore
import ResumeUI
import SwiftUI

@main
struct FolioApp: App {
    /// The résumé ships inside the app as JSON; a broken file shows what's wrong instead of crashing.
    private let resume = Result { try ResumeLoader.bundled() }

    var body: some Scene {
        WindowGroup {
            switch resume {
            case .success(let resume):
                FolioRootView(model: ResumeViewModel(resume: resume))
            case .failure(let error):
                ContentUnavailableView(
                    "The résumé couldn't be read",
                    systemImage: "doc.badge.ellipsis",
                    description: Text(String(describing: error))
                )
            }
        }
    }
}
