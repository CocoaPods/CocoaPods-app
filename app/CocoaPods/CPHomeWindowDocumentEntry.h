@import Cocoa;

/// Object representing a document on the home window

@interface CPHomeWindowDocumentEntry : NSObject <NSCopying>
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSURL *podfileURL;
@property (nonatomic, copy) NSImage *image;
@property (nonatomic, copy) NSString *fileDescription;

+ (CPHomeWindowDocumentEntry *)documentEntryWithURL:(NSURL *)url;

@end
