//
//  ImagePickerViewController.swift
//  DAM
//
//  Created by Apple Esprit on 12/11/2024.
//

import UIKit
import SwiftUI
import PhotosUI


struct ImagePickerViewController: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
        
    }
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    func makeCoordinator() -> Coordinator  {
        Coordinator(self)
        
    }
    class Coordinator: NSObject, PHPickerViewControllerDelegate  {
        var parent: ImagePickerViewController
        init(_ parent: ImagePickerViewController) {
            self.parent = parent
            
        }
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let  provider =      results.first?.itemProvider else
            { return                             }
            if  provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { (image, error) in
                    DispatchQueue.main.async {
                        
                        self.parent.selectedImage = image as? UIImage
                        
                    }
                }
            }
            }
    }
 }

