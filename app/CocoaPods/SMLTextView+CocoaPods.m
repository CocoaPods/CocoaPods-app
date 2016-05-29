@import Fragaria;
#import <objc/runtime.h>

// Hack SMLTextView to also consider the leading colon when completing words, which are all the
// symbols that we support.
//
@implementation SMLTextView (CPIncludeLeadingColonsInCompletions)

+ (void)load;
{
  Method m1 = class_getInstanceMethod(self, @selector(rangeForUserCompletion));
  Method m2 = class_getInstanceMethod(self, @selector(CP_rangeForUserCompletion));
  method_exchangeImplementations(m1, m2);
  
  Method m3 = class_getInstanceMethod(self, @selector(completionsForPartialWordRange:indexOfSelectedItem:));
  Method m4 = class_getInstanceMethod(self, @selector(CP_completionsForPartialWordRange:indexOfSelectedItem:));
  method_exchangeImplementations(m3, m4);
}

-(NSRange)CP_rangeForUserCompletion;
{
  NSRange range = [self CP_rangeForUserCompletion];
  NSRange cursor = [self selectedRange];
  NSUInteger loc = cursor.location;
  
  // Allow completion at the start of string literals
  NSCharacterSet *stringDelimiters = [NSCharacterSet characterSetWithCharactersInString:@"'\""];
  if (loc > 1 &&
    [stringDelimiters characterIsMember:[[self string] characterAtIndex:loc-1]] &&
    [[NSCharacterSet whitespaceCharacterSet] characterIsMember:[[self string] characterAtIndex:loc-2]]) {
    return cursor;
  }
  
  if (range.location != NSNotFound && range.location > 0
      && [self.string characterAtIndex:range.location -1] == ':') {
    
    range = NSMakeRange(range.location -1, range.length +1);
  }
  return range;
}

-(NSArray<NSString *> *)CP_completionsForPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index
{
  NSArray<NSString *> *completions = [self CP_completionsForPartialWordRange:charRange indexOfSelectedItem:index];
  if (charRange.length == 0) { // Return all available completions at cursor position within strings
    id <SMLAutoCompleteDelegate> delegate;
    if (!self.autoCompleteDelegate)
      delegate = self.syntaxColouring.syntaxDefinition;
    else
      delegate = self.autoCompleteDelegate;
    NSMutableArray* allCompletions = [[delegate completions] mutableCopy];
    return allCompletions;
  }
  return completions;
}

@end
