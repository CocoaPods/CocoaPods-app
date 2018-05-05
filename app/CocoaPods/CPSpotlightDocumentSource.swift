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
    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(self, selector: #selector(queryUpdated(_:)), name: NSNotification.Name.NSMetadataQueryDidUpdate, object: self.query)
    notificationCenter.addObserver(self, selector: #selector(queryGatheringFinished(_:)), name: NSNotification.Name.NSMetadataQueryDidFinishGathering, object: self.query)

    query.predicate = NSPredicate(format: "kMDItemFSName == 'Podfile'", argumentArray: nil)
    query.sortDescriptors = [NSSortDescriptor(key: kMDItemContentModificationDate as String, ascending: true)]
    query.searchScopes = [NSMetadataQueryIndexedLocalComputerScope]
    query.valueListAttributes = [NSMetadataItemPathKey]

    query.start()
  }

  func queryUpdated(_ notification: Notification) {
    query.disableUpdates()

    guard let podfileMetadatas = notification.userInfo?[kMDQueryUpdateAddedItems] as? [NSMetadataItem] else { return }

    spotlightDocuments = podfileMetadatas.flatMap {
      guard let path = $0.value(forAttribute: NSMetadataItemPathKey) as? String else { return nil }
      let url = URL(fileURLWithPath: path)
      return CPHomeWindowDocumentEntry(url: url)
    }

    query.enableUpdates()
    
    NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(queryFinished), object: nil)
    queryFinished()
  }

  func queryGatheringFinished(_ notification: Notification) {
    // let NSMetadataQuery finish when there are files available, if not finish the query
    self.perform(#selector(CPSpotlightDocumentSource.queryFinished), with: nil, afterDelay: 2.0)
  }
  
  func queryFinished() {
    let notificationCenter = NotificationCenter.default
    notificationCenter.removeObserver(self)
    query.stop()

    if (query.isStopped) {
      self.delegate?.documentSourceDidUpdate(self, documents: documents)
    }
  }
}
