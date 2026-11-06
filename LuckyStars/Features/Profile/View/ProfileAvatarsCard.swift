//
//  ProfileAvatarsCard.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 16/02/2026.
//
import SwiftUI

struct ProfileAvatarsCard: View {
    let partner1Initial: String
    let partner2Initial: String?
    let profileImage: UIImage?
    /// The partner's photo, when they have one.
    let partnerImage: UIImage?
    let onCameraClick: () -> Void
    let onAddPartnerClick: () -> Void
    
    var body: some View {
        ZStack {
            HStack(spacing: -14){

                // First avatar (current user)
                Circle()
                    .fill(Color.cardFill)
                    .frame(width: 84, height: 84)
                    .overlay(
                        Group {
                            if let image = profileImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 84, height: 84)
                                    .clipShape(Circle())
                            } else {
                                Text(partner1Initial)
                                    .font(.luckyTitle)
                                    .foregroundStyle(Color.luckyBlue)
                            }
                        }
                    )
                    .overlay(Circle().strokeBorder(Color.charcoal, lineWidth: Outline.thick))
                    .background(Circle().fill(Color.charcoal).offset(x: Outline.shadowMin, y: Outline.shadowMin))
                    .zIndex(0)

                // Second avatar (partner or add button)
                Circle()
                    .fill(Color.avatarPink)
                    .frame(width: 84, height: 84)
                    .overlay(
                        Group {
                            if let partnerImage {
                                Image(uiImage: partnerImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 84, height: 84)
                                    .clipShape(Circle())
                            } else if let initial = partner2Initial {
                                Text(initial)
                                    .font(.luckyTitle)
                                    .foregroundStyle(Color.charcoal)
                            } else {
                                Button {
                                    onAddPartnerClick()
                                } label: {
                                    Image(systemName: "person.badge.plus.fill")
                                        .font(.system(size: 30))
                                        .foregroundStyle(Color.charcoal)
                                }
                            }
                        }
                    )
                    .overlay(Circle().strokeBorder(Color.charcoal, lineWidth: Outline.thick))
                    .background(Circle().fill(Color.charcoal).offset(x: Outline.shadowMin, y: Outline.shadowMin))
                    .zIndex(1)
            }
            .overlay(alignment: .bottomLeading) {
                // Camera icon
                Button {
                    onCameraClick()
                } label: {
                    Image(systemName: "camera.fill")
                        .foregroundStyle(Color.charcoal)
                        .font(.system(size: 14))
                        .frame(width: 32, height: 32)
                        .luckyOutline(Circle(), shadowOffset: 0)
                }
                .offset(x: -4, y: 6)
                .zIndex(2)
                .accessibilityLabel("Change photo")
            }
        }
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    /// Called with the picture the user chose (not when a saved one is loaded).
    var onPick: ((UIImage) -> Void)? = nil
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
                ProfileImageStore.save(image)
                parent.onPick?(image)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
