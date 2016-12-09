//
//  OTAdaptivePublisher.h
//  Pods
//
//  Created by Charley Robinson on 12/8/16.
//
//

#import <OpenTok/OpenTok.h>

@class OTPublisherSettings;

@interface OTAdaptivePublisher : OTPublisher

-(instancetype)initWithDelegate:(id<OTPublisherKitDelegate>)delegate
                       settings:(OTPublisherSettings*)settings;


@end
