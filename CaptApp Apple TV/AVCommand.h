//
//  AVCommand.h
//  CaptApp Apple TV
//
//  Created by Jorge Mendoza Martínez on 5/21/16.
//  Copyright © 2016 CaptApp TV Network. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AVCommand : NSObject

@property AVMutableComposition *mutableComposition;
@property AVMutableVideoComposition *mutableVideoComposition;
@property AVMutableAudioMix *mutableAudioMix;
@property CALayer *watermarkLayer;

- (id)initWithComposition:(AVMutableComposition*)composition videoComposition:(AVMutableVideoComposition*)videoComposition audioMix:(AVMutableAudioMix*)audioMix;
- (void)performWithAsset:(AVAsset*)asset;

@end
