//
//  ShareSheet.swift
//  LuckyStars
//
//  The system share sheet, with a callback for when the user has actually shared.
//  (SwiftUI's ShareLink has no way to tell.)
//

import SwiftUI
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
    let message: String
    var subject: String? = nil
    /// Called when the sheet closes: true if the user shared (or copied), false if they cancelled.
    var onFinish: (Bool) -> Void

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let source = MessageSource(message: message, subject: subject)
        let controller = UIActivityViewController(activityItems: [source], applicationActivities: nil)
        controller.completionWithItemsHandler = { _, completed, _, _ in
            onFinish(completed)
        }
        return controller
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}

/// Gives the share sheet the message, plus a subject for apps that have one (Mail).
private final class MessageSource: NSObject, UIActivityItemSource {
    let message: String
    let subject: String?

    init(message: String, subject: String?) {
        self.message = message
        self.subject = subject
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        message
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        message
    }

    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        subject ?? ""
    }
}
