#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

/// Sets up and acts as a datasource to the Home Window's sidebar
/// which shows recent documents from the NSDocumentStore

/// Note: Interactions are handed by CPHomeWindowController

@interface CPRecentDocumentsController : NSObject

/// Used in NSTableView via IB bindings
@property (nonatomic, readwrite, copy) NSArray *recentDocuments;

/// Used to set the first responder once data has been loadded in
@property (nonatomic, readwrite, weak) IBOutlet NSTableView *documentsTableView;


@end

/// Object representing a document

@interface CPHomeWindowDocumentEntry : NSObject <NSCopying>
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSURL *podfileURL;
@property (nonatomic, copy) NSImage *image;
@property (nonatomic, copy) NSString *fileDescription;
@end
