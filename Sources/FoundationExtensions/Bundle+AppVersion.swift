//
 //  Bundle+AppVersion.swift
 //  SwiftyKit
 //
 //  Created by Dmitriy Ignatyev on 13.12.2024.
 //

//import StdLibExtensions

public import struct IndependentDeclarations.SemVer

extension Bundle {
  public enum Key {
    public static let appVersion = "CFBundleShortVersionString"
    public static let appBuildNumber = "CFBundleVersion"
  }
  
  public static let mainAppVersionString: String = (Bundle.main.infoDictionary?[Key.appVersion] as? String) ?? "0"
  
  public static let mainAppBuildNumberString: String = (Bundle.main.infoDictionary?[Key.appBuildNumber] as? String) ?? "0"
  
  public static var mainAppFullVersionString: String { String(describing: mainAppVersion) + " (\(mainAppBuildNumberString))" }

  public static let mainAppVersion: SemVer = Bundle.mainBundleVersion
  public static let mainAppBuildNumber = Int(mainAppBuildNumberString)!
  
  fileprivate static let mainBundleVersion: SemVer = {
    do {
      let parsed = try SemVer(description: Bundle.mainAppVersionString)
      return parsed
    } catch {
      assertionFailure(String(describing: error))
      return SemVer(major: 0, minor: 0, patch: 0)
    }
  }()
  // FIXME: - build number exist in Bundle but not added here
}
