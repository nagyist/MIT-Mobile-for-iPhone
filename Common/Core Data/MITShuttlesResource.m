#import "MITShuttlesResource.h"

#import "MITMobile.h"
#import "MITMobileRouteConstants.h"
#import "MITShuttleRoute.h"
#import "MITShuttleStop.h"
#import "MITShuttlePrediction.h"
#import "MITShuttleVehicle.h"

@implementation MITShuttleRoutesResource

- (instancetype)initWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel
{
    self = [super initWithName:MITShuttlesRoutesResourceName pathPattern:MITShuttlesRoutesPathPattern managedObjectModel:managedObjectModel];
    if (self) {
        [self addMapping:[MITShuttleRoute objectMapping]
               atKeyPath:nil
        forRequestMethod:RKRequestMethodGET];
    }
    
    return self;
}

@end

@implementation MITShuttleRouteDetailResource : MITMobileManagedResource

- (instancetype)initWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel
{
    self = [super initWithName:MITShuttlesRouteResourceName pathPattern:MITShuttlesRoutePathPattern managedObjectModel:managedObjectModel];
    if (self) {
        [self addMapping:[MITShuttleRoute objectMapping]
               atKeyPath:nil
        forRequestMethod:RKRequestMethodGET];
    }
    
    return self;
}

@end

@implementation MITShuttleStopDetailResource : MITMobileManagedResource

- (instancetype)initWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel
{
    self = [super initWithName:MITShuttlesStopResourceName pathPattern:MITShuttlesStopsPathPattern managedObjectModel:managedObjectModel];
    if (self) {
        [self addMapping:[MITShuttleStop objectMapping]
               atKeyPath:nil
        forRequestMethod:RKRequestMethodGET];
    }
    
    return self;
}

@end

@implementation MITShuttlePredictionsResource : MITMobileManagedResource

- (instancetype)initWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel
{
    self = [super initWithName:MITShuttlesPredictionsResourceName pathPattern:MITShuttlesPredictionsPathPattern managedObjectModel:managedObjectModel];
    if (self) {
        [self addMapping:[MITShuttlePrediction objectMapping]
               atKeyPath:nil
        forRequestMethod:RKRequestMethodGET];
    }
    
    return self;
}

@end

@implementation MITShuttleVehiclesResource : MITMobileManagedResource

- (instancetype)initWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel
{
    self = [super initWithName:MITShuttlesVehiclesResourceName pathPattern:MITShuttlesVehiclesPathPattern managedObjectModel:managedObjectModel];
    if (self) {
        [self addMapping:[MITShuttleVehicle objectMapping]
               atKeyPath:nil
        forRequestMethod:RKRequestMethodGET];
    }
    
    return self;
}

@end