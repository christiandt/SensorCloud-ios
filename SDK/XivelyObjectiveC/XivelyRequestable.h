#import <Foundation/Foundation.h>

/** XivelyRequestable is a base class used by XivelyModel and XivelyFeedCollection to add parameters to a `fetch` request.

 For example, historical queries can be made by adding the paramenters `start` and `end` to a XivelyFeedCollection and then calling `fetch` */
@interface XivelyRequestable : NSObject

///---------------------------------------------------------------------------------------
/// @name Request Data
///---------------------------------------------------------------------------------------

/** A mutable dictionary of any request parameter which will be used when a model or collection fetches from Xively. */
@property (strong, nonatomic) NSMutableDictionary *parameters;

/** Convenience method for adding parameters to any models or collection. This is used for adding parameters to any fetch request such as `per_page` or for creating filters for fetch request as in the case of historical queries. */
- (void)useParameter:(NSString*)parameterName withValue:(NSString*)value;

/** Convience method for removing all the parameters of a model or collection. */
- (void)resetParameters;

@end
