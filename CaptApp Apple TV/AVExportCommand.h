//
//  AVExportCommand.h
//  CaptApp Apple TV
//
//  Created by Jorge Mendoza Martínez on 5/21/16.
//  Copyright © 2016 CaptApp TV Network. All rights reserved.
//

#import "AVCommand.h"

@protocol AVExportCommandDelegate <NSObject>
@optional

- (void)exportedAsset:(AVAsset*)asset;
// ... other methods here
@end

@interface AVExportCommand : AVCommand

@property AVAssetExportSession *exportSession;
@property (nonatomic, weak) id <AVExportCommandDelegate> delegate;


@end
