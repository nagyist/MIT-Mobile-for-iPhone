#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@class MITShuttleRoute;
@class MITShuttleStop;

typedef void(^MITShuttleRoutesCompletionBlock)(NSArray *routes, NSError *error);
typedef void(^MITShuttleRouteDetailCompletionBlock)(MITShuttleRoute *route, NSError *error);
typedef void(^MITShuttleStopDetailCompletionBlock)(MITShuttleStop *route, NSError *error);
typedef void(^MITShuttlePredictionsCompletionBlock)(NSArray *predictions, NSError *error);
typedef void(^MITShuttleVehiclesCompletionBlock)(NSArray *vehicles, NSError *error);

@interface MITShuttleController : NSObject

+ (MITShuttleController *)sharedController;

- (void)getRoutes:(MITShuttleRoutesCompletionBlock)completion;
- (void)getRouteDetail:(MITShuttleRoute *)route completion:(MITShuttleRouteDetailCompletionBlock)completion;
- (void)getStopDetail:(MITShuttleStop *)stop completion:(MITShuttleStopDetailCompletionBlock)completion;

- (void)getPredictionsForStops:(NSArray *)stops completion:(MITShuttlePredictionsCompletionBlock)completion;
- (void)getPredictionsForStop:(MITShuttleStop *)stop completion:(MITShuttlePredictionsCompletionBlock)completion;

- (void)getVehiclesForRoutes:(NSArray *)routes completion:(MITShuttleVehiclesCompletionBlock)completion;

@end
