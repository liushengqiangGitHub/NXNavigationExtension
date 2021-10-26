//
//  MainTabBarController.swift
//  NXNavigationExtensionDemo
//
//  Created by lidan on 2021/10/14.
//

import UIKit

#if canImport(SwiftUI)
import SwiftUI
#endif

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        if #available(iOS 13.0, *) {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithDefaultBackground()
            tabBar.standardAppearance = tabBarAppearance
            if #available(iOS 15.0, *) {
                tabBar.scrollEdgeAppearance = tabBarAppearance
            }
            viewControllers = [hostingController, featureNavigationController]
        } else {
            // fix: iOS Modal -> Dismiss -> Push, TabBar BUG
            tabBar.isTranslucent = false
            updateOtherNavigationControllerBorderStyle()
            viewControllers = [featureNavigationController, otherNavigationController]
        }
        
        tabBar.tintColor = UIColor.customColor(lightModeColor: {
            return .customDarkGray
        }, darkModeColor: {
            return .customLightGray
        })
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *) { } else {
            updateOtherNavigationControllerBorderStyle()
        }
    }
    
    private lazy var featureNavigationController: FeatureNavigationController = {
        var featureTableViewController = FeatureTableViewController(style: .grouped)
        if #available(iOS 13.0, *) {
            featureTableViewController = FeatureTableViewController(style: .insetGrouped)
        }
        
        let customNormal = UIImage(named: "TabBarCustomNormal")
        let customSelected = UIImage(named: "TabBarCustomSelected")
        
        let featureNavigationController = FeatureNavigationController(rootViewController: featureTableViewController)
        if #available(iOS 13.0, *) {
            featureTableViewController.navigationItem.title = "UIKit🎉🎉🎉"
            featureNavigationController.tabBarItem = UITabBarItem(title: "UIKit", image: customNormal, selectedImage: customSelected)
        } else {
            featureTableViewController.navigationItem.title = "NXNavigationBar🎉🎉🎉"
            featureNavigationController.tabBarItem = UITabBarItem(title: "Custom", image: customNormal, selectedImage: customSelected)
        }
        return featureNavigationController
    }()
    
    // iOS13 before
    private lazy var otherNavigationController: OtherNavigationController = {
        var featureTableViewController = FeatureTableViewController(style: .grouped)
        if #available(iOS 13.0, *) {
            featureTableViewController = FeatureTableViewController(style: .insetGrouped)
        }
        
        featureTableViewController.navigationItem.title = "UINavigationBar❌❌❌"
        
        let systemNormal = UIImage(named: "TabBarSystemNormal")
        let systemSelected = UIImage(named: "TabBarSystemSelected")
        
        let otherNavigationController = OtherNavigationController(rootViewController: featureTableViewController)
        otherNavigationController.tabBarItem = UITabBarItem(title: "System", image: systemNormal, selectedImage: systemSelected)
        otherNavigationController.view.layer.borderWidth = 3.0
        return otherNavigationController
    }()
    
    // iOS13 or Later
    @available(iOS 13, *)
    private lazy var hostingController: UIHostingController<ContentView> = {
        let hostingController = UIHostingController(rootView: ContentView())
        let systemNormal = UIImage(named: "TabBarSystemNormal")
        let systemSelected = UIImage(named: "TabBarSystemSelected")
        hostingController.tabBarItem = UITabBarItem(title: "SwiftUI", image: systemNormal, selectedImage: systemSelected)
        return hostingController
    }()
    
}

extension MainTabBarController {
    
    private func updateOtherNavigationControllerBorderStyle() {
        otherNavigationController.view.layer.borderColor = UIColor.customColor(lightModeColor: {
            return .red
        }, darkModeColor: {
            return .orange
        }).cgColor
    }
    
}

extension MainTabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if (UIDevice.isPhoneDevice) { return }
        
        guard var viewControllers = splitViewController?.viewControllers else { return }
        guard let lastViewController = viewControllers.last else { return }
        
        if viewController.isMember(of: type(of: lastViewController.self)) { return }
        
        guard let oldDetailNavigationController = viewControllers.last as? UINavigationController else { return }
        guard let oldDetailViewController = oldDetailNavigationController.viewControllers.last else { return }
        
        let detailViewController = type(of: oldDetailViewController).init()
        detailViewController.navigationItem.title = oldDetailViewController.navigationItem.title
        
        guard let viewController = viewController as? UINavigationController else { return }
        let detailNavigationController = type(of: viewController).init(rootViewController: detailViewController)
        
        _ = viewControllers.firstIndex(of: oldDetailNavigationController).map { viewControllers.remove(at: $0) }
        viewControllers.append(detailNavigationController)
        
        splitViewController?.viewControllers = viewControllers
    }
    
}