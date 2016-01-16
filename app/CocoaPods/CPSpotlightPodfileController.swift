import Cocoa

class CPSpotlightPodfileController: NSObject {
  let query = NSMetadataQuery()
  var documents = [CPHomeWindowDocumentEntry]()

  override func awakeFromNib() {
    start();
  }

  func start() {

    let notificationCenter = NSNotificationCenter.defaultCenter()
    notificationCenter.addObserver(self, selector: "queryUpdated:", name: NSMetadataQueryDidUpdateNotification, object: self.query)
    notificationCenter.addObserver(self, selector: "queryFinished:", name: NSMetadataQueryDidUpdateNotification, object: self.query)

    query.predicate = NSPredicate(format: "kMDItemFSName == 'Podfile'", argumentArray: nil)
    query.sortDescriptors = [NSSortDescriptor(key: kMDItemLastUsedDate as String, ascending: true)]
    query.searchScopes = [NSMetadataQueryIndexedLocalComputerScope]
    query.startQuery()
  }

  func queryUpdated(notification: NSNotification) {
    guard let podfiles = notification.userInfo?[kMDQueryUpdateAddedItems] as? [NSMetadataItem] else { return }

    documents = podfiles.flatMap { (metadata) -> CPHomeWindowDocumentEntry? in
      print(metadata.attributes)
      guard let url = metadata.valueForAttribute(kMDItemURL as String) else {
        return nil
      }
      print(url)
      // TODO: the NSMetadataThings dont seem to have a URL?!
      return CPHomeWindowDocumentEntry(URL: url as! NSURL)
    }

  }

  func queryFinished(notification: NSNotification) {
    let notificationCenter = NSNotificationCenter.defaultCenter()
    notificationCenter.removeObserver(self)
  }
}
