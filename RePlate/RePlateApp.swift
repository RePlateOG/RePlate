//
//  RePlateApp.swift
//  RePlate
//
//  Created by Jyotika Sadani on 5/26/26.
//

import SwiftUI
import UIKit

// MARK: - App Entry Point

@main
struct RePlateApp: App {
    @StateObject private var appState = AppState()
    @UIApplicationDelegateAdaptor(RePlateAppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}

// MARK: - App Delegate

class RePlateAppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Wrap the SwiftUI hosting controller in a container that enforces
        // white (light-content) status bar icons on all screens.
        // The green gradient headers cover the status-bar area on every main
        // tab; the brief white-background auth screens accept white icons as
        // an acceptable trade-off vs. a per-screen dynamic approach.
        DispatchQueue.main.async { [weak self] in
            self?.installStatusBarContainer()
        }

        // TODO: Uncomment after adding Stripe Swift package (StripePaymentSheet) in Xcode:
        // STPAPIClient.shared.publishableKey = StripeConfig.publishableKey

        // Global UIKit appearance config
        configureAppearance()
        return true
    }

    // MARK: - Status bar container

    private func installStatusBarContainer() {
        guard
            let scene  = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = scene.windows.first,
            let hosting = window.rootViewController
        else { return }

        // Only wrap once
        guard !(hosting is LightStatusBarContainerVC) else { return }

        let container = LightStatusBarContainerVC(child: hosting)
        window.rootViewController = container
        window.setNeedsLayout()
    }

    // MARK: - Global UIKit appearance

    private func configureAppearance() {
        // Navigation bars: tint and transparent background so views
        // that extend behind them look seamless.
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithTransparentBackground()
        navAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 17, weight: .bold)
        ]
        navAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        UINavigationBar.appearance().standardAppearance  = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance   = navAppearance
        UINavigationBar.appearance().tintColor           = UIColor(Color(hex: "5db996"))
    }
}

// MARK: - Light-Content Status Bar Container

/// A thin UIViewController wrapper whose sole purpose is to return
/// `.lightContent` (white clock / battery / signal icons) for the status bar.
/// It fills the window with its single child view controller so layout
/// is completely transparent to the SwiftUI content beneath.
final class LightStatusBarContainerVC: UIViewController {

    private let child: UIViewController

    init(child: UIViewController) {
        self.child = child
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(child)
        child.view.frame = view.bounds
        child.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    // ── Status bar ──────────────────────────────────────────────────────────
    override var preferredStatusBarStyle:  UIStatusBarStyle { .lightContent }
    override var prefersStatusBarHidden:   Bool             { false }

    // Do NOT defer to children — we own the style globally.
    override var childForStatusBarStyle:   UIViewController? { nil }
    override var childForStatusBarHidden:  UIViewController? { nil }
}
