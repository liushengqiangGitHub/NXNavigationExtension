//
//  View01_EdgePopGestureDisable.swift
//  NXNavigationExtensionDemo
//
//  Created by lidan on 2021/10/15.
//

#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOS 13.0, *)
struct View01_EdgePopGestureDisable: View {
    private let randomDark = UIColor.randomDark
    private let randomLight = UIColor.randomLight
    private let item: NavigationFeatureItem

    init(_ item: NavigationFeatureItem) {
        self.item = item
    }

    var body: some View {
        ColorListView()
            .navigationBarTitle(item.title)
            .useNXNavigationView(onPrepareConfiguration: { configuration in
                let userInterfaceStyle = configuration.viewControllerPreferences.traitCollection?.userInterfaceStyle ?? .light
                configuration.navigationBarAppearance.backgroundColor = userInterfaceStyle == .dark ? randomDark : randomLight
                configuration.viewControllerPreferences.disableInteractivePopGesture = true
            })
    }
}

@available(iOS 13.0, *)
struct View01_EdgePopGestureDisable_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            View01_EdgePopGestureDisable(NavigationFeatureItem(style: .edgePopGestureDisable))
        }
    }
}