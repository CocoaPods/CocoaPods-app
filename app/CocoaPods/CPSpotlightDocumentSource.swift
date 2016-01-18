import Cocoa

class CPSpotlightDocumentSource: NSObject, CPMiniPromiseDelegate {
  let query = NSMetadataQuery()
  var documents = [CPHomeWindowDocumentEntry]()
  var completedPromise = CPMiniPromise()

  override func awakeFromNib() {
    start();
    completedPromise.delegate = self
  }

  func start() {
    let notificationCenter = NSNotificationCenter.defaultCenter()
    notificationCenter.addObserver(self, selector: "queryUpdated:", name: NSMetadataQueryDidUpdateNotification, object: self.query)
    notificationCenter.addObserver(self, selector: "queryFinished:", name: NSMetadataQueryDidUpdateNotification, object: self.query)

    query.predicate = NSPredicate(format: "kMDItemFSName == 'Podfile'", argumentArray: nil)
    query.sortDescriptors = [NSSortDescriptor(key: kMDItemContentModificationDate as String, ascending: true)]
    query.searchScopes = [NSMetadataQueryIndexedLocalComputerScope]
    query.valueListAttributes = [NSMetadataItemPathKey]

    query.startQuery()
  }

  func queryUpdated(notification: NSNotification) {
    query.disableUpdates()

    guard let podfileMetadatas = notification.userInfo?[kMDQueryUpdateAddedItems] as? [NSMetadataItem] else { return }

    documents = podfileMetadatas.flatMap {
      guard let path = $0.valueForAttribute(NSMetadataItemPathKey) as? String else { return nil }
      let url = NSURL(fileURLWithPath: path)
      return CPHomeWindowDocumentEntry(URL: url)
    }

    query.enableUpdates()
  }

  func queryFinished(notification: NSNotification) {
    let notificationCenter = NSNotificationCenter.defaultCenter()
    notificationCenter.removeObserver(self)
    query.stopQuery()
    completedPromise.checkForFulfillment()
  }

  func shouldFulfillPromise(promise: CPMiniPromise!) -> Bool {
    return query.stopped
  }
}
