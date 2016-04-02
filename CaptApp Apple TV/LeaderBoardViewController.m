//
//  LeaderBoardViewController.m
//  CaptApp Apple TV
//
//  Created by Jeffrey Wells on 2/25/16.
//  Copyright © 2016 CaptApp TV Network. All rights reserved.
//

#import "LeaderBoardViewController.h"

static void* const AVLoopPlayerCurrentItemObservationContext = (void*)&AVLoopPlayerCurrentItemObservationContext;

@interface LeaderBoardViewController ()

@property (nonatomic, strong) AVPlayerViewController *playerViewController;
@property BOOL isPlayerPresented;
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
    
    self.isPlayerPresented = NO;
    
    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.playerViewController = [AVPlayerViewController new];
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
        
        // Do not add a empty clip
        if (clips.count > 0)
        {
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
        }
        
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
       
    }
    
}

- (void) playVideos:(id)sender
{
    // Validate the Queue was instance
    if (reportQueuePlayer == nil)
    {
        reportQueuePlayer = [[AVQueuePlayer alloc] initWithItems:reportArray];
        NSLog(@"reportQueue: %@", reportQueuePlayer);
        self.playerViewController.player = reportQueuePlayer;
        
        //adding an observer to the Queue when finish a track
        [reportQueuePlayer addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionOld context:AVLoopPlayerCurrentItemObservationContext];
        
        [reportQueuePlayer play];
    }
    else
    {
        // Add the Next report to the Queue
        AVPlayerItem *lastItem = [reportArray lastObject];
        [reportQueuePlayer insertItem:lastItem afterItem: nil];
        NSLog(@"Adding next report");

    }
    
    
    // Validate if the Player was Displayed.
    if (!self.isPlayerPresented) {
        self.isPlayerPresented = YES;
        
        //Adding the logo to the player
        UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"waterMarkLogo"]];
        logo.frame = CGRectMake(50, 50, 252, 160);
        [self.playerViewController.view addSubview:logo];
        [self presentViewController:self.playerViewController animated:YES completion:nil];
    }
    

}


/*
    Observer for create a Loop
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)changeDictionary context:(void *)context
{
    if (context == AVLoopPlayerCurrentItemObservationContext)
    {
        AVQueuePlayer *player = (AVQueuePlayer *)object;
        
        NSLog(@"AVPlayerItem finished to play");
        
        // Append the previous current item to the player's queue
        AVPlayerItem *itemRemoved = changeDictionary[NSKeyValueChangeOldKey];
        
        // An initial change from a nil currentItem yields NSNull here.
        // Check to make sure the class is AVPlayerItem before appending it to the end of the queue
        if ([itemRemoved isKindOfClass:[AVPlayerItem class]])
        {
            [itemRemoved seekToTime:kCMTimeZero];
            NSLog(@"Adding AVPlayerItem to the loop");
            
            //AVPlayerItem *lastItemInPlayer = [player.items lastObject];
            
            [player insertItem:itemRemoved afterItem: nil];
        }
    }
}
@end
