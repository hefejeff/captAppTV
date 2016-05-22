//
//  AVExportCommand.m
//  CaptApp Apple TV
//
//  Created by Jorge Mendoza Martínez on 5/21/16.
//  Copyright © 2016 CaptApp TV Network. All rights reserved.
//

#import "AVExportCommand.h"

@implementation AVExportCommand

- (void)performWithAsset:(AVAsset *)asset
{
    
    // Step 1
    // Create an outputURL to which the exported movie will be saved
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *outputURL = paths[0];
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager createDirectoryAtPath:outputURL withIntermediateDirectories:YES attributes:nil error:nil];

    NSString *fileDirectory =  [NSString stringWithFormat:@"output-%d.mov",arc4random() % 1000];
    outputURL = [outputURL stringByAppendingPathComponent:fileDirectory];

    
    // Remove Existing File
    [manager removeItemAtPath:outputURL error:nil];
    
    
    // Step 2
    // Create an export session with the composition and write the exported movie to the photo library
    self.exportSession = [[AVAssetExportSession alloc] initWithAsset:[self.mutableComposition copy] presetName:AVAssetExportPresetPassthrough];
    
    self.exportSession.videoComposition = self.mutableVideoComposition;
    self.exportSession.audioMix = self.mutableAudioMix;
    self.exportSession.outputURL = [NSURL fileURLWithPath:outputURL];
    self.exportSession.outputFileType=AVFileTypeQuickTimeMovie;
    self.exportSession.shouldOptimizeForNetworkUse = YES;
    
    [self.exportSession exportAsynchronouslyWithCompletionHandler:^(void){
        switch (self.exportSession.status) {
            case AVAssetExportSessionStatusCompleted:
            {
                NSLog(@"The Video was expored");
                NSDictionary *optionsDictionary = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
                AVURLAsset *myAsset = [[AVURLAsset alloc] initWithURL:self.exportSession.outputURL options:optionsDictionary];
                
                [self.delegate exportedAsset:myAsset];
            }
                break;
            case AVAssetExportSessionStatusFailed:
                NSLog(@"Failed:%@",self.exportSession.error);
                [self.delegate exportedAsset:nil];
                break;
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"Canceled:%@",self.exportSession.error);
                break;
            default:
                break;
        }
    }];
}

@end
