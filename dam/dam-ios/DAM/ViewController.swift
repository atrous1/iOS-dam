//
//  ViewController.swift
//  DAM
//
//  Created by Mac-Mini-2021 on 6/11/2024.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var termsButton: UIButton!
    
    override func viewDidLoad() {
            super.viewDidLoad()
            setupTermsAndConditions() // Configure le bouton "Terms and Conditions"
        }
        
        private func setupTermsAndConditions() {
            // Le texte et ses attributs pour le bouton
            let text = "Terms and Conditions"
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.blue, // Couleur bleue
                .underlineStyle: NSUnderlineStyle.single.rawValue // Texte souligné
            ]
            let attributedString = NSAttributedString(string: text, attributes: attributes)
            
            // Assigner le texte attribué au bouton
            termsButton.setAttributedTitle(attributedString, for: .normal)
            
            // Ajouter l'action pour ouvrir l'URL lors d'un appui
            termsButton.addTarget(self, action: #selector(openTermsAndConditions), for: .touchUpInside)
        }

        @objc private func openTermsAndConditions() {
            // Lien vers les conditions d'utilisation
            if let url = URL(string: "https://www.freeprivacypolicy.com/live/6bcf6418-363a-4e43-9e76-2a51080fb704") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
