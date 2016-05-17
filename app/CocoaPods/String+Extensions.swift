extension String {
  func trim() -> String {
    return stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
  }
}