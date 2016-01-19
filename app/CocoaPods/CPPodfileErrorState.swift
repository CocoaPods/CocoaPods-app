import Foundation

enum CPPodfileErrorState {
  case EmptyFile
  case SyntaxError
  
  init?(fromProject project: CPUserProject) {
    if project.contents.isEmpty {
      self = .EmptyFile
    } else if project.syntaxErrors.count > 0 {
      self = .SyntaxError
    } else {
      return nil
    }
  }
}