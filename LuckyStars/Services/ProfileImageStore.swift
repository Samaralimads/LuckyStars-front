//
//  ProfileImageStore.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 28/09/2026.
//

import UIKit

// Persists the profile photo locally so it survives app relaunches.
// Not synced to the backend yet — there's no image upload endpoint, so the
// partner's device won't see it until that's built.
struct ProfileImageStore {
    private static let fileName = "profile-photo.jpg"

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

    static func clear() {
        guard let fileURL else { return }
        try? FileManager.default.removeItem(at: fileURL)
    }

    static func load() -> UIImage? {
        guard let fileURL, let data = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: data)
    }
}
