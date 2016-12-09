//
//  OTAdaptiveSubscriber.m
//  Pods
//
//  Created by Charley Robinson on 12/8/16.
//
//

#import "OTAdaptiveSubscriber.h"
#import "OTAdaptiveResolution.h"

@implementation OTAdaptiveSubscriber {
    NSTimer* _updater;
    CGSize _lastAnnouncedSize;
}

- (id)initWithStream:(OTStream*)stream
            delegate:(id<OTSubscriberKitDelegate>)delegate
{
    self = [super initWithStream:stream delegate:delegate];
    if (self) {
        _updater = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                   repeats:YES
                                                     block:
                    ^(NSTimer * _Nonnull timer) {
                        [self update];
                    }];
    }
    return self;
}

- (bool)myStreamIsActive
{
    for (NSString* streamId in [self.session.streams allKeys]) {
        if ([streamId isEqualToString:self.stream.streamId]) {
            return YES;
        }
    }
    return NO;
}

- (bool)checkup
{
    if (OTSessionConnectionStatusConnected !=
        self.session.sessionConnectionStatus)
    {
        return NO;
    }
    if (![self myStreamIsActive]) {
        return NO;
    }

    return YES;
}

- (void)update
{
    if (![self checkup])
    {
        NSLog(@"Checkup indicates subscriber is no longer valid. "
              "Aborting automatic adaptive resolution updates.");
        [_updater invalidate];
        return;
    }

    CGSize currentRenderingSize = self.view.frame.size;

    // Send signal to preferred resolution
    if (!CGSizeEqualToSize(self.view.frame.size, self.preferredResolution)) {
        [self setPreferredResolution:currentRenderingSize];
    }

    if (!CGSizeEqualToSize(self.view.frame.size, _lastAnnouncedSize)) {
        // In case preferred resolution is unavailable, let's also notify
        // the publisher of our current rendering for this subscriber
        OTError* error = nil;
        NSString* signal =
        [NSString stringWithFormat:
         @"{\"subscriberId\":\"%@\",\"width\":\"%d\",\"height\":\"%d\"}",
         self.session.connection.connectionId, (int)currentRenderingSize.width,
         (int)currentRenderingSize.height];
        [self.session signalWithType:kOTAdaptiveResolutionSignalType
                              string:signal
                          connection:self.stream.connection
                               error:&error];
        if (error) {
            NSLog(@"ERROR[OTAdaptiveResolution]: %@", error);
        }

        _lastAnnouncedSize = self.view.frame.size;
    }
}

@end
