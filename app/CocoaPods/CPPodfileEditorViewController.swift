//
//  CPPodfileEditorViewController.swift
//  CocoaPods
//
//  Created by Orta on 11/15/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import Cocoa
import Fragaria

/// The Editor's role is to show our Fragaria editor
/// and ensure the changes are sent back upstream to the 
/// CPPodfileViewController's CPUserProject

class CPPodfileEditorViewController: NSViewController, NSTextViewDelegate{

  @IBOutlet var editor: MGSFragariaView!
  
  // As the userProject is DI'd into the PodfileVC
  // it occurs after the view is set up.

  override func viewWillAppear() {
    super.viewWillAppear()

    guard let podfileVC = podfileViewController, project = podfileVC.userProject else {
      return print("CPPodfileEditorViewController is not set up with a PodfileVC in the VC heirarchy.")
    }

    editor.syntaxColoured = true
    editor.syntaxDefinitionName = "Podfile"
    editor.string = project.contents

    let settings = CPFontAndColourGateKeeper()
    editor.textFont = settings.defaultFont
    editor.colourForNumbers = settings.cpGreen
    editor.colourForStrings = settings.cpRed
    editor.colourForComments = settings.cpBrightWhite
    editor.colourForKeywords = settings.cpBlue
    editor.colourForVariables = settings.cpGreen
    editor.colourForInstructions = settings.cpBrightMagenta
    editor.colourForCommands = settings.cpBrightCyan

    project.undoManager = editor.textView.undoManager
  }

  func textDidChange(notification: NSNotification) {
    if let textView = notification.object as? NSTextView,
           podfileVC = podfileViewController {

      podfileVC.userProject.contents = textView.string
    }
  }
}
