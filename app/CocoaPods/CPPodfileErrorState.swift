import Foundation

enum CPPodfileErrorState {
  case emptyFile
  case syntaxError
  
  init?(fromProject project: CPUserProject) {
    if project.contents.isEmpty {
      self = .emptyFile
    } else if project.syntaxErrors.count > 0 {
      self = .syntaxError
    } else {
      return nil
    }
  }
}
