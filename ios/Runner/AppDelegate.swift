import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  /// Set from Dart (`Secure.set`) while the locked library is on screen.
  private var secure = false
  private let coverTag = 0x5061_6765 // "Page"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // lets flutter_local_notifications show reminders while Pagemark is open
    UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    // iOS has no FLAG_SECURE: cover the window before the app-switcher snapshot is taken
    NotificationCenter.default.addObserver(self, selector: #selector(sceneWillDeactivate(_:)), name: UIScene.willDeactivateNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(sceneDidActivate(_:)), name: UIScene.didActivateNotification, object: nil)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "PagemarkSecure") else { return }
    let channel = FlutterMethodChannel(name: "pagemark/secure", binaryMessenger: registrar.messenger())
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "setSecure", let on = call.arguments as? Bool else {
        result(FlutterMethodNotImplemented)
        return
      }
      self?.secure = on
      result(nil)
    }
  }

  @objc private func sceneWillDeactivate(_ note: Notification) {
    guard secure, let window = (note.object as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow }) ?? (note.object as? UIWindowScene)?.windows.first,
          window.viewWithTag(coverTag) == nil else { return }
    let cover = UIView(frame: window.bounds)
    cover.tag = coverTag
    cover.backgroundColor = .systemBackground
    cover.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    window.addSubview(cover)
  }

  @objc private func sceneDidActivate(_ note: Notification) {
    (note.object as? UIWindowScene)?.windows.forEach { $0.viewWithTag(coverTag)?.removeFromSuperview() }
  }
}
