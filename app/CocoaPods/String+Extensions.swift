extension String {
  func trim() -> String {
    return trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
  }
}
