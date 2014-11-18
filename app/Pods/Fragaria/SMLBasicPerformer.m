/*
 
 MGSFragaria
 Written by Jonathan Mitchell, jonathan@mugginsoft.com
 Find the latest version at https://github.com/mugginsoft/Fragaria
 
Smultron version 3.6b1, 2009-09-12
Written by Peter Borg, pgw3@mac.com
Find the latest version at http://smultron.sourceforge.net

Copyright 2004-2009 Peter Borg
 
Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 
http://www.apache.org/licenses/LICENSE-2.0
 
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
*/

#import "MGSFragaria.h"
#import "MGSFragariaFramework.h"

@implementation SMLBasicPerformer

static id sharedInstance = nil;

#pragma mark -
#pragma mark Class methods


/*
 
 + sharedInstance
 
 */
+ (SMLBasicPerformer *)sharedInstance
{ 
	if (sharedInstance == nil) { 
		sharedInstance = [[self alloc] init];
	}
	
	return sharedInstance;
} 

#pragma mark -
#pragma mark Instance methods

/*
 
 - init
 
 */
- (id)init 
{
    if (sharedInstance == nil) {
        self = [super init];
		sharedInstance = self;
        
		thousandFormatter = [[NSNumberFormatter alloc] init];
		[thousandFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
		[thousandFormatter setFormat:@"#,##0"];	
    }
    return sharedInstance;
}

#pragma mark -
#pragma mark Data fetching

/*
 
 - insertFetchRequests
 
 */
- (void)insertFetchRequests
{
	
	// in Smultron this would build a dictionary of CoreData fetches
	fetchRequests = [[NSMutableDictionary alloc] init];
}


/*
 
 - fetchAll:
 
 */
- (NSArray *)fetchAll:(NSString *)key
{
	
	// in Smultron this would initiate a given fetch
	return [fetchRequests valueForKey:key];
}

#pragma mark -
#pragma mark Utiltity methods


/*
 
 - removeAllItemsFromMenu:
 
 */
- (void)removeAllItemsFromMenu:(NSMenu *)menu
{
	NSArray *array = [menu itemArray];
	for (id item in array) {
		[menu removeItem:item];
	}
}

/*
 
 - newUUID
 
 */
- (NSString *)newUUID
{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef uuidString = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    
    return CFBridgingRelease(uuidString);
}

/*
 
 - insertSortOrderNumbersForArrayController
 
 */
- (void)insertSortOrderNumbersForArrayController:(NSArrayController *)arrayController
{
	NSArray *array = [arrayController arrangedObjects];
	NSInteger idx = 0;
	for (id item in array) {
		[item setValue:[NSNumber numberWithInteger:idx] forKey:@"sortOrder"];
		idx++;
	}
}

/*
 
 - thousandFormatedStringFromNumber:
 
 */
- (NSString *)thousandFormatedStringFromNumber:(NSNumber *)number
{
	return [thousandFormatter stringFromNumber:number];
}


/*
 
 - resolveAliasInPath:
 
 */
- (NSString *)copyResolveAliasInPath:(NSString *)path
{
	NSString *resolvedPath = nil;
	CFURLRef url = CFURLCreateWithFileSystemPath(NULL, (CFStringRef)path, kCFURLPOSIXPathStyle, NO);
	
	if (url != NULL) {
		FSRef fsRef;
		if (CFURLGetFSRef(url, &fsRef)) {
			Boolean targetIsFolder, wasAliased;
			if (FSResolveAliasFile (&fsRef, true, &targetIsFolder, &wasAliased) == noErr && wasAliased) {
				CFURLRef resolvedURL = CFURLCreateFromFSRef(NULL, &fsRef);
				if (resolvedURL != NULL) {
					resolvedPath = (NSString*)CFBridgingRelease(CFURLCopyFileSystemPath(resolvedURL, kCFURLPOSIXPathStyle));
                    CFRelease(resolvedURL);
				}
			}
		}
        CFRelease(url);
	}
	
	if (resolvedPath==nil) {
		return path;
	}
	
	return  CFBridgingRelease(CFBridgingRetain(resolvedPath));
}

@end
