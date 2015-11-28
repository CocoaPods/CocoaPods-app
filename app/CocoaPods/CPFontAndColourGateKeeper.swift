import Cocoa

class CPFontAndColourGateKeeper: NSObject {
  let defaultFont = NSFont(name: "Menlo", size: 16)

  let cpBlack = NSColor(calibratedRed:0.180, green:0.000, blue:0.008, alpha:1.00)
  let cpRed = NSColor(calibratedRed:0.682, green:0.000, blue:0.000, alpha:1.00)
  let cpGreen = NSColor(calibratedRed:0.161, green:0.608, blue:0.086, alpha:1.00)
  let cpYellow = NSColor(calibratedRed:0.659, green:0.675, blue:0.055, alpha:1.00)
  let cpBlue = NSColor(calibratedRed:0.227, green:0.463, blue:0.733, alpha:1.00)
  let cpMagenta = NSColor(calibratedRed:0.427, green:0.404, blue:0.698, alpha:1.00)
  let cpCyan = NSColor(calibratedRed:0.239, green:0.616, blue:0.753, alpha:1.00)
  let cpWhite = NSColor(calibratedRed:0.812, green:0.812, blue:0.812, alpha:1.00)
  let cpBrightBlack = NSColor(calibratedRed:0.012, green:0.012, blue:0.012, alpha:1.00)
  let cpBrightRed = NSColor(calibratedRed:0.980, green:0.000, blue:0.000, alpha:1.00)
  let cpBrightGreen = NSColor(calibratedRed:0.192, green:0.745, blue:0.098, alpha:1.00)
  let cpBrightYellow = NSColor(calibratedRed:0.659, green:0.675, blue:0.055, alpha:1.00)
  let cpBrightBlue = NSColor(calibratedRed:0.282, green:0.576, blue:0.902, alpha:1.00)
  let cpBrightMagenta = NSColor(calibratedRed:0.553, green:0.522, blue:0.898, alpha:1.00)
  let cpBrightCyan = NSColor(calibratedRed:0.282, green:0.729, blue:0.902, alpha:1.00)
  let cpBrightWhite = NSColor(calibratedRed:0.773, green:0.773, blue:0.773, alpha:1.00)
  let cpBrightLightBrown = NSColor(calibratedRed: 232/255, green:226/255 , blue: 224/255, alpha: 1)
  let cpBrightBrown = NSColor(calibratedRed: 209/255, green:196/255 , blue: 192/255, alpha: 1)
}
