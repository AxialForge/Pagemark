# Appendix B - Inventories

## B1. Permissions (merged manifest, sideload arm64)
| Permission | Source | Needed for | Runtime prompt | Verdict |
|---|---|---|---|---|
| INTERNET | app | book lookup, covers, update check | no | justified |
| CAMERA | app | barcode scanner | yes, on first scan | justified |
| USE_BIOMETRIC | app | fingerprint unlock | no | justified |
| USE_FINGERPRINT | local_auth (legacy) | same, older Android | no | justified, missing from policy |
| POST_NOTIFICATIONS | app | reminders and backup-problem notice | yes (Android 13+) | justified |
| REQUEST_INSTALL_PACKAGES | sideload flavor only | install a downloaded update | special access | justified, absent from Play build |
| ACCESS_NETWORK_STATE | plugin | backup and lookup network checks | no | justified |
| WAKE_LOCK | WorkManager | scheduled work | no | missing from policy |
| RECEIVE_BOOT_COMPLETED | WorkManager / notifications | re-schedule reminders after reboot | no | missing from policy |
| FOREGROUND_SERVICE | WorkManager | long background work | no | confirm needed; missing from policy |
| VIBRATE | notifications | notification vibration | no | missing from policy |
| com.axialforge.pagemark.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION | AndroidX | internal receiver protection | no | normal |

Removed on purpose with `tools:node="remove"`: READ_EXTERNAL_STORAGE, READ_MEDIA_IMAGES, READ_MEDIA_VIDEO, READ_MEDIA_AUDIO. Not present: location, contacts, microphone, SMS, storage, accounts, advertising ID. On the Android 17 emulator the system also showed ACCESS_LOCAL_NETWORK as granted automatically for this older target SDK; the app does not declare it.

## B2. Application components
| Component | Exported | Guard | Notes |
|---|---|---|---|
| MainActivity | yes | none needed | MAIN/LAUNCHER and a SEND text/plain share target; shared text is capped, whitelisted and only pre-fills the search box |
| PagemarkWidgetProvider (receiver) | no | | home-screen widget, main library only |
| androidx.glance GlanceRemoteViewsService | yes | BIND_REMOTEVIEWS | system-only binding |
| WorkManager SystemJobService | yes | BIND_JOB_SERVICE | system-only binding |
| WorkManager DiagnosticsReceiver, profileinstaller ProfileInstallReceiver | yes | DUMP | system and shell only |
| ML Kit, content providers and other library components | no | | |

Application flags: allowBackup=false, fullBackupContent=false, dataExtractionRules exclude root, file, database, sharedpref and external for both cloud backup and device transfer, not debuggable, extractNativeLibs=false.

## B3. Network endpoints (all HTTPS, from source)
| Host | Purpose | Trigger | Data sent |
|---|---|---|---|
| openlibrary.org, covers.openlibrary.org | search, ISBN lookup, covers | user search or scan, cover display | query text or ISBN, IP address |
| www.googleapis.com (Google Books) | second lookup source, can be switched off | user search | query text |
| api.github.com, github.com | update check and APK download (sideload flavor) | at most daily, switchable | public release request only |

No cleartext configuration, no custom TrustManager or HostnameVerifier, no certificate pinning (not needed for public book data). A test in the repository enforces the host allow-list (`promiseHosts`).

## B4. Data-flow inventory
| Data | Where stored | Encrypted at rest | Leaves device? | Recipient | Deletion |
|---|---|---|---|---|---|
| Books, reads, ratings, thoughts, quotes, shelves | SQLite in app-private storage | no (owner-accepted, MOB-SEC-0006) | only through exports and backups the user saves | user-chosen location | uninstall, or in-app delete and Trash |
| Locked library | same database, `locked` flag | no | in the full-database backup only, optionally AES-256-GCM encrypted | user-chosen location | in-app |
| PIN hash, salt, recovery hash | flutter_secure_storage (Keystore backed) | yes | no | | clear lock, or uninstall |
| Backup passphrase | flutter_secure_storage | yes | no | | uninstall |
| Settings, filters, timer state | SharedPreferences | no (non-sensitive) | no | | uninstall |
| Event log (200 KB cap, SQL details scrubbed) | app files | no | only if the user shares a problem report | user | in-app |
| Cover images | cache and `local:` cover store; locked covers in a separate cache wiped on lock | no | no | | in-app |
| Search text and ISBN | memory | n/a | yes, to the lookup hosts above | Open Library, Google Books | not retained by the app |
| Camera frames | memory only | n/a | not stored or sent by the app; the ML Kit library may report technical data (MOB-PRV-0002) | | |

Accounts, advertising IDs, analytics, crash reporting, location and contacts: none. Account deletion requirements: not applicable (no accounts).

## B5. Cryptography and local security
| Item | Finding |
|---|---|
| PIN | PBKDF2-HMAC-SHA256, 150,000 iterations, random 16-byte salt per install, constant-time compare, attempt limiting with lockout up to 1 hour (clock-skew capped), recovery code stored as a hash; legacy SHA-256 PIN upgraded on use |
| Backup encryption | "PGMKENC1": AES-256-GCM, 16-byte random salt, 12-byte nonce, key from PBKDF2-SHA256 at 150,000 iterations |
| Secrets in source | none found; signing config reads an untracked `key.properties` |
| Screen capture | FLAG_SECURE while the locked library is open; the vault relocks on pause (static review; recents thumbnail not verified at runtime) |
| Locked-library leaks | exports, stats, widget and suggestions filter on `locked`; covered by repository tests |

## B6. Dependencies (pub.dev, from pubspec.lock)
187 packages. OSV result: no known vulnerabilities.

Direct packages of note: drift 2.35.2, sqlite3 3.7.0, (sqlite3_flutter_libs 0.6.0+eol was removed 2026-10-14, MOB-AND-0004; the list below is the pre-fix SBOM and still shows it), http 1.6.0, local_auth 3.0.2, flutter_secure_storage 11.2.0, cryptography 2.9.0, mobile_scanner 7.4.2 (Google ML Kit), home_widget 0.10.0, flutter_local_notifications 22.3.2, file_picker 13.1.0, share_plus 13.3.1, open_filex 4.7.0, image_picker 1.2.4, pdf 3.13.1, archive 4.5.1, cached_network_image 4.0.4, package_info_plus 10.2.2, device_info_plus 13.3.0, android_intent_plus 6.1.0. No analytics, advertising, crash-reporting or payment SDK.

Native libraries in the arm64 APK: libflutter, libapp, libsqlite3, libbarhopper_v3 (ML Kit barcode), libdartjni, libimage_processing_util_jni, libsurface_util_jni, libdatastore_shared_counter.

### Full package list (SBOM)

| Package | Version |
|---|---|
| _fe_analyzer_shared | 109.0.0 |
| analyzer | 14.5.0 |
| android_file_picker | 2.0.1 |
| android_intent_plus | 6.1.0 |
| archive | 4.5.1 |
| args | 2.7.0 |
| async | 2.13.1 |
| barcode | 2.2.9 |
| bidi | 2.0.13 |
| boolean_selector | 2.1.2 |
| build | 4.0.11 |
| build_config | 1.3.3 |
| build_daemon | 4.1.6 |
| build_runner | 2.16.2 |
| built_collection | 5.1.2 |
| built_value | 8.13.0 |
| cached_network_image | 4.0.4 |
| cached_network_image_platform_interface | 5.0.3 |
| cached_network_image_web | 2.0.3 |
| characters | 1.4.1 |
| charcode | 1.4.0 |
| checked_yaml | 2.0.4 |
| cli_util | 0.6.0 |
| clock | 1.1.3 |
| code_assets | 2.1.0 |
| collection | 1.19.1 |
| convert | 3.1.2 |
| cross_file | 0.3.5+5 |
| crypto | 3.0.7 |
| cryptography | 2.9.0 |
| cryptography_flutter | 2.3.4 |
| csv | 8.0.0 |
| cupertino_icons | 1.0.9 |
| cupertino_ui | 1.1.2 |
| dart_style | 3.1.13 |
| dbus | 0.8.0 |
| device_info_plus | 13.3.0 |
| device_info_plus_platform_interface | 8.1.0 |
| drift | 2.35.2 |
| drift_dev | 2.35.1 |
| fake_async | 1.3.3 |
| ffi | 2.2.0 |
| ffi_leak_tracker | 0.1.2 |
| file | 7.0.1 |
| file_picker | 13.1.0 |
| file_picker_darwin | 2.2.0 |
| file_picker_linux | 2.0.2 |
| file_picker_platform_interface | 4.1.0 |
| file_picker_web | 4.1.0 |
| file_selector_linux | 0.9.4+1 |
| file_selector_macos | 0.9.5+1 |
| file_selector_platform_interface | 2.7.0 |
| file_selector_windows | 0.9.3+6 |
| fixnum | 1.1.1 |
| flutter | 0.0.0 |
| flutter_cache_manager | 3.4.5 |
| flutter_lints | 6.0.0 |
| flutter_local_notifications | 22.3.2 |
| flutter_local_notifications_linux | 8.0.2 |
| flutter_local_notifications_platform_interface | 12.2.0 |
| flutter_local_notifications_web | 1.0.0 |
| flutter_local_notifications_windows | 3.1.1 |
| flutter_localizations | 0.0.0 |
| flutter_plugin_android_lifecycle | 2.0.35 |
| flutter_secure_storage | 11.2.0 |
| flutter_secure_storage_darwin | 0.4.3 |
| flutter_secure_storage_linux | 3.0.3 |
| flutter_secure_storage_platform_interface | 2.1.1 |
| flutter_secure_storage_web | 2.1.1 |
| flutter_secure_storage_windows | 4.2.2 |
| flutter_test | 0.0.0 |
| flutter_web_plugins | 0.0.0 |
| glob | 2.2.0 |
| graphs | 2.3.2 |
| home_widget | 0.10.0 |
| hooks | 2.2.0 |
| http | 1.6.0 |
| http_multi_server | 3.2.2 |
| http_parser | 4.1.2 |
| image | 4.12.0 |
| image_picker | 1.2.4 |
| image_picker_android | 0.8.13+25 |
| image_picker_for_web | 3.1.1 |
| image_picker_ios | 0.8.13+10 |
| image_picker_linux | 0.2.2 |
| image_picker_macos | 0.2.2+1 |
| image_picker_platform_interface | 2.11.2 |
| image_picker_windows | 0.2.2 |
| intl | 0.20.3 |
| io | 1.1.0 |
| jni | 1.1.0 |
| jni_flutter | 1.0.4+1 |
| jni_util | 1.0.0 |
| json_annotation | 4.12.0 |
| leak_tracker | 11.0.2 |
| leak_tracker_flutter_testing | 3.0.10 |
| leak_tracker_testing | 3.0.2 |
| lints | 6.1.0 |
| local_auth | 3.0.2 |
| local_auth_android | 2.2.0 |
| local_auth_darwin | 2.0.4 |
| local_auth_platform_interface | 1.1.0 |
| local_auth_windows | 2.0.2 |
| logging | 1.3.0 |
| matcher | 0.12.20 |
| material_color_utilities | 0.13.0 |
| material_ui | 1.6.0 |
| meta | 1.19.0 |
| mime | 2.1.0 |
| mobile_scanner | 7.4.2 |
| native_toolchain_c | 0.19.5 |
| objective_c | 9.6.2 |
| octo_image | 2.1.2 |
| open_filex | 4.7.0 |
| package_config | 3.0.0 |
| package_info_plus | 10.2.2 |
| package_info_plus_platform_interface | 4.1.0 |
| path | 1.9.1 |
| path_parsing | 1.1.0 |
| path_provider | 2.1.6 |
| path_provider_android | 2.3.1 |
| path_provider_foundation | 2.6.0 |
| path_provider_linux | 2.2.2 |
| path_provider_platform_interface | 2.1.3 |
| path_provider_windows | 2.3.0 |
| pdf | 3.13.1 |
| petitparser | 7.1.0 |
| platform | 3.2.0 |
| plugin_platform_interface | 2.1.8 |
| pool | 1.5.3 |
| posix | 6.5.2 |
| process | 5.0.6 |
| pub_semver | 2.2.1 |
| pubspec_parse | 1.6.0 |
| qr | 3.0.2 |
| recase | 4.1.0 |
| record_use | 1.1.1 |
| rxdart | 0.28.0 |
| share_plus | 13.3.1 |
| share_plus_platform_interface | 7.2.0 |
| shared_preferences | 2.5.6 |
| shared_preferences_android | 2.4.28 |
| shared_preferences_foundation | 2.5.7 |
| shared_preferences_linux | 2.4.1 |
| shared_preferences_platform_interface | 2.4.2 |
| shared_preferences_web | 2.4.3 |
| shared_preferences_windows | 2.4.1 |
| shelf | 1.4.2 |
| shelf_web_socket | 3.0.0 |
| sky_engine | 0.0.0 |
| source_gen | 4.3.0 |
| source_span | 1.10.2 |
| sqflite | 2.4.4+1 |
| sqflite_android | 2.4.4 |
| sqflite_common | 2.5.13+1 |
| sqflite_darwin | 2.4.4 |
| sqflite_platform_interface | 2.4.2 |
| sqlite3 | 3.7.0 |
| sqlite3_flutter_libs | 0.6.0+eol |
| sqlparser | 0.45.0 |
| stack_trace | 1.12.2 |
| stream_channel | 2.1.4 |
| stream_transform | 2.1.2 |
| string_scanner | 1.4.1 |
| synchronized | 3.4.2 |
| term_glyph | 1.2.2 |
| test_api | 0.7.12 |
| timezone | 0.11.2 |
| typed_data | 1.4.0 |
| url_launcher_linux | 3.2.3 |
| url_launcher_platform_interface | 2.3.2 |
| url_launcher_web | 2.4.3 |
| url_launcher_windows | 3.1.6 |
| uuid | 4.6.0 |
| vector_math | 2.4.3 |
| vm_service | 15.3.0 |
| watcher | 1.2.1 |
| web | 1.1.1 |
| web_socket | 1.0.1 |
| web_socket_channel | 3.0.3 |
| win32 | 6.4.0 |
| win32_registry | 3.0.3 |
| windows_file_picker | 2.0.1 |
| xdg_directories | 1.1.0 |
| xml | 7.1.0 |
| yaml | 3.1.4 |
| yaml_edit | 2.2.4 |
