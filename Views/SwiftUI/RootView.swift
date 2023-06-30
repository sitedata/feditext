// Copyright © 2020 Metabolist. All rights reserved.

import AppUrls
import ServiceLayer
import SwiftUI
import UIKit
import ViewModels

struct RootView: View {
    @StateObject var viewModel: RootViewModel

    var body: some View {
        if let navigationViewModel = viewModel.navigationViewModel {
            MainNavigationView { navigationViewModel }
                .id(navigationViewModel.identityContext.identity.id)
                .environmentObject(viewModel)
                .transition(.opacity)
                .handlesExternalEvents(preferring: ["*"], allowing: ["*"])
                .onOpenURL(perform: { openURL(navigationViewModel, $0) })
                .edgesIgnoringSafeArea(.all)
                .onReceive(navigationViewModel.identityContext.$appPreferences.map(\.colorScheme),
                           perform: setColorScheme)
        } else {
            NavigationView {
                AddIdentityView(
                    viewModelClosure: { viewModel.addIdentityViewModel() },
                    displayWelcome: true)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarHidden(true)
            }
            .environmentObject(viewModel)
            .navigationViewStyle(StackNavigationViewStyle())
            .transition(.opacity)
        }
    }

    /// Open `metatext:` URLs from the action extension.
    private func openURL(_ navigationViewModel: NavigationViewModel, _ metatextUrl: URL) {
        guard
            let components = URLComponents(url: metatextUrl, resolvingAgainstBaseURL: true),
            components.scheme == AppUrls.scheme
        else {
            return
        }
        switch components.path {
        case AppUrls.searchPath:
            // Expecting `feditext:search?url=https://…`, which we open by searching for the wrapped URL.
            guard
                let searchUrlString = components.queryItems?.first(
                    where: { $0.name == AppUrls.searchUrlParam }
                )?.value,
                let searchComponents = URLComponents(string: searchUrlString),
                searchComponents.scheme == "https",
                let searchUrl = searchComponents.url
            else {
                return
            }
            navigationViewModel.navigateToURL(searchUrl)
        default:
            break
        }
    }
}

private extension RootView {
    func setColorScheme(_ colorScheme: AppPreferences.ColorScheme) {
        for scene in UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }) {
            for window in scene.windows {
                window.overrideUserInterfaceStyle = colorScheme.uiKit
            }
        }
    }
}

extension AppPreferences.ColorScheme {
    var uiKit: UIUserInterfaceStyle {
        switch self {
        case .system:
            return .unspecified
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

#if DEBUG
import Combine
import PreviewViewModels

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(viewModel: .preview)
    }
}
#endif
