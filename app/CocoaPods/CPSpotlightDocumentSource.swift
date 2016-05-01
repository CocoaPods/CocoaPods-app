import Cocoa

class CPSpotlightDocumentSource: CPDocumentSource {
  let query = NSMetadataQuery()
  
  // CPDocumentSource demands a getter only property for `documents` but 
  // CPSpotlightDocumentSource wants to set this array directly so we create an 
  // internal managed array that the computed `documents` property can access
  var spotlightDocuments: [CPHomeWindowDocumentEntry] = []
  override var documents: [CPHomeWindowDocumentEntry] {
    return spotlightDocuments
  }

  override func awakeFromNib() {
    start();
  }

  func start() {
    let notificationCenter = NSNotificationCenter.defaultCenter()
    notificationCenter.addObserver(self, selector: #selector(queryUpdated(_:)), name: NSMetadataQueryDidUpdateNotification, object: self.query)
    notificationCenter.addObserver(self, selector: #selector(queryGatheringFinished(_:)), name: NSMetadataQueryDidFinishGatheringNotification, object: self.query)

    query.predicate = NSPredicate(format: "kMDItemFSName == 'Podfile'", argumentArray: nil)
    query.sortDescriptors = [NSSortDescriptor(key: kMDItemContentModificationDate as String, ascending: true)]
    query.searchScopes = [NSMetadataQueryIndexedLocalComputerScope]
    query.valueListAttributes = [NSMetadataItemPathKey]

    query.startQuery()
  }

  func queryUpdated(notification: NSNotification) {
    query.disableUpdates()

    guard let podfileMetadatas = notification.userInfo?[kMDQueryUpdateAddedItems] as? [NSMetadataItem] else { return }

    spotlightDocuments = podfileMetadatas.flatMap {
      guard let path = $0.valueForAttribute(NSMetadataItemPathKey) as? String else { return nil }
      let url = NSURL(fileURLWithPath: path)
      return CPHomeWindowDocumentEntry(URL: url)
    }

    query.enableUpdates()
    
    NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(queryFinished), object: nil)
    queryFinished()
  }

  func queryGatheringFinished(notification: NSNotification) {
    // let NSMetadataQuery finish when there are files available, if not finish the query
    self.performSelector(#selector(CPSpotlightDocumentSource.queryFinished), withObject: nil, afterDelay: 2.0)
  }
  
  func queryFinished() {
    let notificationCenter = NSNotificationCenter.defaultCenter()
    notificationCenter.removeObserver(self)
    query.stopQuery()

    if (query.stopped) {
      self.delegate?.documentSourceDidUpdate(self, documents: documents)
    }
  }
}
