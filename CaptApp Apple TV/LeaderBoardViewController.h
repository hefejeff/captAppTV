//
//  LeaderBoardViewController.h
//  CaptApp Apple TV
//
//  Created by Jeffrey Wells on 2/25/16.
//  Copyright © 2016 CaptApp TV Network. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>


@interface LeaderBoardViewController : UIViewController
@property (nonatomic, strong) NSString *currentPort;
@property (strong, nonatomic) NSDictionary *Reports;
@property (strong, nonatomic) NSDictionary *PlayList;
@property (nonatomic, strong) NSMutableArray *reportArray;
@property (nonatomic, strong) AVQueuePlayer *reportQueuePlayer;
@property (nonatomic, strong) NSArray *vids;
@property (nonatomic, strong) NSArray *clips;
@property (nonatomic, strong) NSArray *filteredvids;
@property (nonatomic, strong) NSString *logoURL;
@property (nonatomic, strong) NSString *portName;
@property (weak, nonatomic) IBOutlet UIImageView *marinaLogoImage;






@end
