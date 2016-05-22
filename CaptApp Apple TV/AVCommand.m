//
//  AVCommand.m
//  CaptApp Apple TV
//
//  Created by Jorge Mendoza Martínez on 5/21/16.
//  Copyright © 2016 CaptApp TV Network. All rights reserved.
//

#import "AVCommand.h"

@implementation AVCommand

- (id)initWithComposition:(AVMutableComposition *)composition videoComposition:(AVMutableVideoComposition *)videoComposition audioMix:(AVMutableAudioMix *)audioMix
{
    self = [super init];
    if(self != nil) {
        self.mutableComposition = composition;
        self.mutableVideoComposition = videoComposition;
        self.mutableAudioMix = audioMix;
    }
    return self;
}

- (void)performWithAsset:(AVAsset*)asset
{
    [self doesNotRecognizeSelector:_cmd];
}

@end
