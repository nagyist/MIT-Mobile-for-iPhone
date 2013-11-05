#import <Foundation/Foundation.h>

#define kFPDefaultEpsilon (0.001)
BOOL CGFloatIsEqual(CGFloat f0, CGFloat f1, double epsilon);

@interface NSURL (MITAdditions)

+ (NSURL *)internalURLWithModuleTag:(NSString *)tag path:(NSString *)path;
+ (NSURL *)internalURLWithModuleTag:(NSString *)tag path:(NSString *)path query:(NSString *)query;

@end

@interface NSArray (MITAdditions)

- (NSArray *)mapObjectsUsingBlock:(id (^)(id obj, NSUInteger idx))block;

@end

@interface NSSet (MITAdditions)

- (NSSet *)mapObjectsUsingBlock:(id (^)(id obj))block;

@end

@interface NSMutableString (MITAdditions)
/** Replace all the occurrences of the strings in targets with the
 *  values in replacements.
 *
 *  @param targets The strings to replace. Raises an NSInvalidArgumentException if targets and replacements do not have the same number of strings.
 *  @param replacements The strings with which to replace target. Raises an NSInvalidArgumentException if targets and replacements do not have the same number of strings.
 *  @param opts See replaceOccurrencesOfString:withString:options:range:
 *
 *  @see replaceOccurrencesOfString:withString:options:range:
 */
- (void)replaceOccurrencesOfStrings:(NSArray *)targets withStrings:(NSArray *)replacements options:(NSStringCompareOptions)options;

@end

@interface NSString (MITAdditions)
- (BOOL)containsSubstring:(NSString*)string options:(NSStringCompareOptions)mask;

/** Returns a copy of the receiver which has whitespace
 *  and punctuation removed and normalized using NFKD form.
 */
- (NSString*)stringBySearchNormalization;
- (NSString *)substringToMaxIndex:(NSUInteger)to;
@end

@interface NSString (MITAdditions_URLEncoding)
- (NSString*)urlEncodeUsingEncoding:(NSStringEncoding)encoding;
- (NSString*)urlEncodeUsingEncoding:(NSStringEncoding)encoding useFormURLEncoded:(BOOL)formUrlEncoded;
- (NSString*)urlDecodeUsingEncoding:(NSStringEncoding)encoding;
@end

@interface NSString (MITAdditions_HTMLEntity)

- (NSString *)stringByDecodingXMLEntities;

/** String representation with HTML tags removed.

 Replaces all angle bracketed text with spaces, collapses all spaces down to a single space, and trims leading and trailing whitespace and newlines.

 @return A plain text string suitable for display in a UILabel.
 */
- (NSString *)stringByStrippingTags;

@end

@interface NSDate (MITAdditions)
+ (NSDate *)fakeDateForDining;
+ (NSDate *) dateForTodayFromTimeString:(NSString *)time;
- (BOOL) isEqualToDateIgnoringTime: (NSDate *) aDate;
- (BOOL) isToday;
- (BOOL) isTomorrow;
- (BOOL) isYesterday;
- (NSDate *) startOfDay;
- (NSDate *) endOfDay;
- (NSDate *) dayBefore;
- (NSDate *) dayAfter;
- (NSString *) MITShortTimeOfDayString; // e.g. "1pm", "10:30am", etc
- (NSDateComponents *) dayComponents;
- (NSDateComponents *) timeComponents;
- (NSDate *)dateWithTimeOfDayFromDate:(NSDate *)date;

@end

@interface NSCalendar (MITAdditions)

+ (NSCalendar *)cachedCurrentCalendar;

@end
