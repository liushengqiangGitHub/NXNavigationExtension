//
//  View10_Present.swift
//  NXNavigationExtensionDemo
//
//  Created by lidan on 2021/10/17.
//

#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOS 13.0, *)
struct View10_Present: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding private var presentedAsModal: Bool
    
    private let item: NavigationFeatureItem
    
    init(_ item: NavigationFeatureItem, presentedAsModal: Binding<Bool>) {
        self.item = item
        self._presentedAsModal = presentedAsModal
    }
    
    var body: some View {
        ColorListView()
            .navigationBarTitle(item.title)
            .navigationBarItems(leading:Button (action: {
                self.presentedAsModal = false
            }, label: {
                Image(systemName: "xmark")
            }).foregroundColor(colorScheme == .dark ? Color.white : Color.black))
            .useNXNavigationView(onPrepareConfiguration: { configuration in
                configuration.navigationBarAppearance.backgroundColor = .clear
                configuration.viewControllerPreferences.useBlurNavigationBar = true
            })
    }
}

@available(iOS 13.0, *)
struct View10_Present_Previews: PreviewProvider {
    @State static var presentedAsModal = false
    static var previews: some View {
        NavigationView {
            View10_Present(NavigationFeatureItem(style: .present), presentedAsModal: $presentedAsModal)
        }
    }
}