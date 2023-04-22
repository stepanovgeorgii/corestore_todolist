//
//  AppDelegate.swift
//  TodoList_CoreStore
//
//  Created by Georgy Stepanov on 21.04.23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    private var coreStoreManager: CoreStoreManagerProtocol?
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let coreStoreManager = CoreStoreManager()
        self.coreStoreManager = coreStoreManager
                
        coreStoreManager.setup { [weak self] in
            guard let self else { return }
            let screenWindow = UIWindow()
            let viewController = ViewController()
            screenWindow.rootViewController = UINavigationController(rootViewController: viewController)
            self.window = screenWindow
            screenWindow.makeKeyAndVisible()
        }
        
        return true
    }
}

