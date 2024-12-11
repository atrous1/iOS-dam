import UIKit
import SwiftUI

class HomeViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Masquer la tabBar UIKit pour utiliser celle de SwiftUI
        self.tabBar.isHidden = true
        print("HomeViewController Loaded") // Vérification si cette ligne s'affiche
       
        // Crée un UIHostingController pour héberger la vue SwiftUI
        let customTabBarView = UIHostingController(rootView: CustomTabBarView())
       
        // Vérifier si le customTabBarView est bien initialisé
        print("customTabBarView initialized")
      
        // Ajouter le UIHostingController en tant qu’enfant
        addChild(customTabBarView)
        view.addSubview(customTabBarView.view)
        /*
        // Configurer les contraintes pour afficher customTabBarView correctement
        customTabBarView.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            customTabBarView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customTabBarView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customTabBarView.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            customTabBarView.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
         */
        // Informer que le controller a été ajouté
        customTabBarView.didMove(toParent: self)
        print("UIHostingController ajouté comme enfant")
       
      
    }
}


