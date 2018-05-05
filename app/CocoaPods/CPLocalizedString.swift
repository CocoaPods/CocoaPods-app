import Foundation

/// Adds support for using localized strings in
/// the format of ~"my key", also transforming it
/// into uppercase, and swapping spaces to underscores

prefix func ~ (string: String) -> String {
  let key = string.uppercased().replacingOccurrences(of: " ", with: "_")
  return NSLocalizedString(key, comment:"")
}
