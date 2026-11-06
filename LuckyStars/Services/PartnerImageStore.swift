//
//  PartnerImageStore.swift
//  LuckyStars
//
//  The partner's profile photo, kept on this phone so it shows right away (the server has the real copy).
//

import UIKit

struct PartnerImageStore {
    private static let fileName = "partner-photo.jpg"

    private static var fileURL: URL? {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(fileName)
    }

    static func save(_ image: UIImage) {
        guard let fileURL, let data = image.jpegData(compressionQuality: 0.8) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    static func load() -> UIImage? {
        guard let fileURL, let data = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: data)
    }

    static func clear() {
        guard let fileURL else { return }
        try? FileManager.default.removeItem(at: fileURL)
    }
}
