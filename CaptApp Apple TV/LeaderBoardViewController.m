//
//  LeaderBoardViewController.m
//  CaptApp Apple TV
//
//  Created by Jeffrey Wells on 2/25/16.
//  Copyright © 2016 CaptApp TV Network. All rights reserved.
//

#import "LeaderBoardViewController.h"



@interface LeaderBoardViewController ()

@end

@implementation LeaderBoardViewController

@synthesize currentPort;
@synthesize Reports;
@synthesize vids;
@synthesize clips;
@synthesize filteredvids;
@synthesize logoURL;
@synthesize marinaLogoImage;
@synthesize portName;
@synthesize PlayList;
@synthesize reportArray;
@synthesize reportQueuePlayer;


- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"viewWillAppear");
    
    NSLog(@"Port Array %@", currentPort);
    NSLog(@"Port Name %@", portName);
    
    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self downloadVideos:nil];
    
    
    NSLog(@"Current Port ID: %@", currentPort);
    NSLog(@"Port Array: %@",logoURL);
    
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        
        NSData *logoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:logoURL]];
        UIImage *logoImg = [UIImage imageWithData:logoData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.marinaLogoImage.image = logoImg;
            
          //  [activityView stopAnimating];
        });
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


- (void)downloadVideos:(id)sender {
    
   // [activityView startAnimating];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:@"http://captapp.com/wp-json/all_video_reports" parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        self.Reports = (NSDictionary *)responseObject;
        self.vids = [responseObject allObjects];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"port == %@", currentPort ];
        filteredvids  = [vids filteredArrayUsingPredicate:predicate];
        
        [self playLoop:nil];
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
}

- (void) playLoop:(id)sender {
    
   // [activityView stopAnimating];
    
    reportArray = [NSMutableArray array];
    
    for (NSDictionary *report in filteredvids) {
        
    NSNumber *reportID = [report valueForKeyPath:@"report_id"];
    NSLog(@"Report ID: %@",reportID);
    NSString *myString = [reportID stringValue];
    NSLog(@"myString: %@",myString);
    NSString *baseURL = @"http://captapp.com/wp-json/jwplayer/daily-report?dailyreport_id=";
    baseURL = [baseURL stringByAppendingString:myString];
    
    NSLog(@"Base URL: %@",baseURL);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:baseURL parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        self.PlayList = (NSDictionary *)responseObject;
        self.clips = [responseObject allObjects];
        NSLog(@"Clips Array: %@",clips);
        
        AVMutableComposition *reportClipsComposition = [AVMutableComposition composition];
        CMTime current = kCMTimeZero;
        NSError *compositionError = nil;
        for(NSArray *clip in clips) {
            
            NSURL *fileUrl = [NSURL URLWithString:[clip valueForKeyPath:@"file"]];
            NSDictionary *optionsDictionary = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
            AVURLAsset *myAsset = [AVURLAsset URLAssetWithURL:fileUrl options:optionsDictionary];
            
            NSLog(@"MyAsset: %@",myAsset);
            
            BOOL result = [reportClipsComposition insertTimeRange:CMTimeRangeMake(kCMTimeZero, [myAsset duration])
                                                          ofAsset:myAsset
                                                           atTime:current
                                                            error:&compositionError];
            if(!result) {
                if(compositionError) {
                    // manage the composition error case
                }
            } else {
                current = CMTimeAdd(current, [myAsset duration]);
                
            }
            
        }
        AVPlayerItem *compositionPlayerItem = [AVPlayerItem playerItemWithAsset:reportClipsComposition];
        [reportArray addObject:compositionPlayerItem];
       [self playVideos:nil];
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
       
    }
    
}

- (void) playVideos:(id)sender
{
    reportQueuePlayer = [AVQueuePlayer queuePlayerWithItems:reportArray];
    NSLog(@"reportQueue: %@", reportQueuePlayer);
    
    AVPlayerViewController *playerViewController = [AVPlayerViewController new];
    playerViewController.player = reportQueuePlayer;
    [reportQueuePlayer play];
    
     [self presentViewController:playerViewController animated:YES completion:nil];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
