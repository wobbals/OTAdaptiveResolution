//
//  OTAdaptivePublisher.m
//  Pods
//
//  Created by Charley Robinson on 12/8/16.
//
//

#import "OTAdaptivePublisher.h"

@implementation OTAdaptivePublisher

-(instancetype)initWithDelegate:(id<OTPublisherKitDelegate>)delegate
                       settings:(OTPublisherSettings*)settings
{
    self = [super initWithDelegate:delegate settings:settings];
    if (self) {
        // inject signal snooper
    }
    return self;
}

@end
