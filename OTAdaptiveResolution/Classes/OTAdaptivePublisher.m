//
//  OTAdaptivePublisher.m
//  Pods
//
//  Created by Charley Robinson on 12/8/16.
//
//

#import "OTAdaptivePublisher.h"
#import "OTAdaptiveResolution.h"
#import "OTNotificationCenter.h"

@interface SizeRequest : NSObject
@property CGSize size;
@property NSDate* requestTime;
@property NSString* subscriberId;
@end

@implementation SizeRequest
@synthesize size;
@synthesize requestTime;
@synthesize subscriberId;
@end

@implementation OTAdaptivePublisher {
    NSMutableDictionary* _requestedSizes;
}

- (instancetype)initWithDelegate:(id<OTPublisherKitDelegate>)delegate
                       settings:(OTPublisherSettings*)settings
{
    self = [super initWithDelegate:delegate settings:settings];
    if (self) {
        // Snoope for session signals
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(signalReceived:)
         name:kOTSessionReceivedSignalEvent
         object:nil];

        _requestedSizes = [NSMutableDictionary new];
    }
    return self;
}

- (void)signalReceived:(NSNotification*)notification
{
    NSString* type = [notification.object objectForKey:kOTSessionSignalTypeKey];
    if (![kOTAdaptiveResolutionSignalType isEqualToString:type]) {
        // ignore
        return;
    }
    NSString* str =
    [notification.object objectForKey:kOTSessionSignalPayloadKey];
    NSError* error = nil;
    NSDictionary* payload =
    [NSJSONSerialization JSONObjectWithData:
     [str dataUsingEncoding:NSUTF8StringEncoding]
                                    options:0
                                      error:&error];
    NSString* subscriberId = [payload objectForKey:@"subscriberId"];
    if (!payload || !subscriberId) {
        // ignore
        return;
    }
    SizeRequest* request = [SizeRequest new];
    CGSize requestedSize = CGSizeZero;
    requestedSize.width =
    ((NSNumber*)[payload objectForKey:@"width"]).floatValue;
    requestedSize.height =
    ((NSNumber*)[payload objectForKey:@"height"]).floatValue;
    [request setSize:requestedSize];
    [request setSubscriberId:subscriberId];
    [request setRequestTime:[NSDate new]];
    [_requestedSizes setValue:request forKey:subscriberId];

    NSLog(@"Desired size received: %@", NSStringFromCGSize(requestedSize));

    [self updatePublisherDimensions];
}

- (void)updatePublisherDimensions
{
    if (_requestedSizes.count < 1) {
        // No requests for size.
        return;
    }
    CGSize recommendedSize = CGSizeZero;

    // select the largest renderer
    for (NSString* key in _requestedSizes) {
        SizeRequest* request = [_requestedSizes objectForKey:key];
        if (recommendedSize.width < request.size.width &&
            recommendedSize.height < request.size.height)
        {
            recommendedSize = request.size;
        }
    }

    NSLog(@"recommended size publisher: %@",
          NSStringFromCGSize(recommendedSize));
}

@end
