//
//  CPInstallAction.swift
//  CocoaPods
//
//  Created by Orta Therox on 25/11/2015.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import Cocoa

enum InstallActionType {
  case Install(verbose: Bool)
  case Update(verbose: Bool)
}

class CPInstallAction: NSObject, CPCLITaskDelegate {
  let userProject: CPUserProject
  dynamic var taskAttributedString: NSAttributedString?
  var task: CPCLITask?

  init(userProject: CPUserProject) {
    self.userProject = userProject
  }

  func performAction(type: InstallActionType) {
    switch type {
    case .Install(let verbose):
      executeTaskWithCommand(verbose ? "install --verbose" : "install")
    case .Update(let verbose):
      executeTaskWithCommand(verbose ? "update --verbose" : "update")
    }
  }

  private func executeTaskWithCommand(command: String) {
    task = CPCLITask(userProject: userProject, command: command, delegate: self, qualityOfService: .UserInitiated)
    task?.run()
  }

  func task(task: CPCLITask!, didUpdateOutputContents updatedOutput: NSAttributedString!) {
    self.taskAttributedString = updatedOutput
  }
}
