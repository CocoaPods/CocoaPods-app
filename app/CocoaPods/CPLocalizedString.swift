import Foundation

/// Adds support for using localized strings in
/// the format of ~"my key", also transforming it
/// into uppercase, and swapping spaces to underscores

prefix func ~ (string: String) -> String {
  let key = string.uppercaseString.stringByReplacingOccurrencesOfString(" ", withString: "_")
  return NSLocalizedString(key, comment:"")
}