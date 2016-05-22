//
//  LeaderBoardViewController.m
//  CaptApp Apple TV
//
//  Created by Jeffrey Wells on 2/25/16.
//  Copyright © 2016 CaptApp TV Network. All rights reserved.
//

#import "LeaderBoardViewController.h"
#import "NSMutableArray+QueueAdditions.h"

static void* const AVLoopPlayerCurrentItemObservationContext = (void*)&AVLoopPlayerCurrentItemObservationContext;

@interface LeaderBoardViewController ()

@property (nonatomic, strong) AVPlayerViewController *playerViewController;
@property BOOL isPlayerPresented;
@property BOOL isVideoComposition;
@property BOOL boolExportVideo;

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
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear");
    
    NSLog(@"Port Array %@", currentPort);
    NSLog(@"Port Name %@", portName);
    
    self.isPlayerPresented = NO;
    self.isVideoComposition = YES;
    self.boolExportVideo = YES;
 
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    
    reportQueuePlayer = [[AVQueuePlayer alloc] init];
    self.playerViewController = [AVPlayerViewController new];
    
    self.playerViewController.player = reportQueuePlayer;
    
     [self.playerViewController.player addObserver:self forKeyPath:@"status" options:0 context:nil];
    
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
    
    if (filteredvids == nil)
        filteredvids = [[NSMutableArray alloc]init];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:@"http://captapp.com/wp-json/all_video_reports" parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        self.Reports = (NSDictionary *)responseObject;
        self.vids = [responseObject allObjects];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"port == %@", currentPort ];
        NSArray *tempFilteredVideos = [vids filteredArrayUsingPredicate:predicate];
        for (id object in tempFilteredVideos) {
            [filteredvids push:object];
        }
        
        //filteredvids  = [vids filteredArrayUsingPredicate:predicate];
        
        [self playLoopWithComposition:self.isVideoComposition];
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
}

- (void) playLoopWithComposition:(BOOL) isComposition {
    
    // [activityView stopAnimating];
    if (reportArray == nil) {
        reportArray = [NSMutableArray array];
    }
    
    
    
    NSDictionary *report = (NSDictionary *)[filteredvids pop];
    
    if (report != nil)
    {
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
                
                __block CMTime current = kCMTimeZero;
                
                AVMutableComposition *composition = [AVMutableComposition composition];
                
                AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
                AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                                 preferredTrackID:kCMPersistentTrackID_Invalid];
                
                __block NSError *compositionError = nil;
                __block long clipsCounter = [clips count];
                __block BOOL trackReady = NO;
                
                for(NSArray *clip in clips) {
                    
                    NSURL *fileUrl = [NSURL URLWithString:[clip valueForKeyPath:@"file"]];
                    
                    NSDictionary *optionsDictionary = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
                    
                    AVURLAsset *myAsset = [[AVURLAsset alloc] initWithURL:fileUrl options:optionsDictionary];
                    
                    
                    NSLog(@"MyAsset: %@",myAsset);
                    
                    if (!isComposition)
                    {
                        
                        // Load the values of AVAsset keys to inspect subsequently
                        NSArray *assetKeysToLoadAndTest = @[@"playable", @"composable", @"tracks", @"duration"];
                        
                        // Tells the asset to load the values of any of the specified keys that are not already loaded.
                        [myAsset loadValuesAsynchronouslyForKeys:assetKeysToLoadAndTest completionHandler:^{
                            dispatch_async( dispatch_get_main_queue(),^{
                                AVPlayerItem *compositionPlayerItem = [AVPlayerItem playerItemWithAsset:myAsset];
                                
                                [reportArray addObject:compositionPlayerItem];
                                [self playVideos:nil];
                                
                                if ([filteredvids count] > 0)
                                    [self playLoopWithComposition:isComposition];
                                
                            });
                        }];
                        
                        
                    }
                    else
                    {
                        if ([[myAsset tracksWithMediaType:AVMediaTypeVideo] count] > 0 && [[myAsset tracksWithMediaType:AVMediaTypeAudio] count] > 0)
                        {
                            AVAssetTrack *tempAssetVideo = [[myAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
                            AVAssetTrack *tempAssetAudio = [[myAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
                            
                            BOOL result =  [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [myAsset duration])
                                                               ofTrack:tempAssetVideo
                                                                atTime:current
                                                                 error:&compositionError];
                            
                            result = [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [myAsset duration])
                                                         ofTrack:tempAssetAudio
                                                          atTime:current
                                                           error:&compositionError];
                            
                            if(!result) {
                                if(compositionError) {
                                    // manage the composition error case
                                }
                            } else {
                                current = CMTimeAdd(current, [myAsset duration]);
                            }
                            
                            
                            clipsCounter --;
                            
                            if (clipsCounter == 0 && !trackReady)
                            {
                                
                                trackReady = YES;
                                
                                [self exportingVideo:self.boolExportVideo withComposition: composition];
                                
                            }
                        }
                        
                    }
                }
                
                
            }
            else
            {
                if ([filteredvids count] > 0)
                    [self playLoopWithComposition:isComposition];
            }
            
            
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        
    }
    
    
}

- (void)exportingVideo:(BOOL)export withComposition: (AVMutableComposition *)mutableComposition
{

    if (export)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            exportCommand = [[AVExportCommand alloc] initWithComposition:mutableComposition
                                                        videoComposition:nil
                                                                audioMix:nil];
            exportCommand.delegate = self;
            
            [exportCommand performWithAsset:nil];
        });
        
    }
    else
    {
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:mutableComposition];
        [reportArray addObject:playerItem];
        [self playVideos:nil];
        
        if ([filteredvids count] > 0)
        {
            [self playLoopWithComposition:self.isVideoComposition];
        }
        
    }

 
    
}

- (void) exportedAsset:(AVAsset *)asset
{
    if (asset != nil) {
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
        [reportArray addObject:playerItem];
        [self playVideos:nil];
    }
    
    if ([filteredvids count] > 0)
    {
        [self playLoopWithComposition:self.isVideoComposition];
    }
}


- (BOOL)setUpPlaybackOfAsset:(AVAsset *)asset withKeys:(NSArray *)keys
{
    BOOL result = YES;
    // This method is called when AVAsset has completed loading the specified array of keys.
    // playback of the asset is set up here.
    
    // Check whether the values of each of the keys we need has been successfully loaded.
    for (NSString *key in keys) {
        NSError *error = nil;
        
        if ([asset statusOfValueForKey:key error:&error] == AVKeyValueStatusFailed) {
            return NO;
        }
    }
    
    return result;
}

- (void) playVideos:(id)sender
{
    
    
    // Validate if the Player was Displayed.
    if (!self.isPlayerPresented) {
        self.isPlayerPresented = YES;
        //Adding the logo to the player
        UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"waterMarkLogo"]];
        logo.frame = CGRectMake(50, 50, 252, 160);
        [self.playerViewController.view addSubview:logo];
        
        [self presentViewController:self.playerViewController animated:YES completion:^{
            
            if (self.playerViewController.player.status == AVPlayerStatusReadyToPlay) {
                [self.playerViewController.player play];
            }
            
        }];
    }
    
    
    // Add the Next report to the Queue
    AVPlayerItem *lastItem = [reportArray lastObject];
    [reportQueuePlayer insertItem:lastItem afterItem: nil];
    NSLog(@"Adding report");
    NSLog(@"reportQueue: %@", reportQueuePlayer);
    // Validate the Queue was instance
    if ([reportQueuePlayer.items count] == 1)
        {
            //adding an observer to the Queue when finish a track
            [reportQueuePlayer addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionOld context:AVLoopPlayerCurrentItemObservationContext];
        }
}


/*
    Observer for create a Loop
 */
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)changeDictionary
                       context:(void *)context
{
    
    if (object == self.playerViewController.player && [keyPath isEqualToString:@"status"]) {
        if (self.playerViewController.player.status == AVPlayerStatusReadyToPlay) {
           
        }
    }
    
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
