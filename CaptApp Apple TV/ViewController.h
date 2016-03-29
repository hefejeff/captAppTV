//
//  ViewController.h
//  CaptApp Apple TV
//
//  Created by Jeffrey Wells on 12/25/15.
//  Copyright © 2015 CaptApp TV Network. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AFNetworking.h"
#import "AppDelegate.h"
#import "ReportsCollectionViewCell.h"
#import "LeaderBoardViewController.h"



@interface ViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, AVPlayerViewControllerDelegate> {
    
    
    IBOutlet UIActivityIndicatorView *activityView;
}

@property (strong, nonatomic) AppDelegate *appDelegate;
@property (nonatomic, strong) NSMutableArray *vidArray;
@property (nonatomic, strong) NSMutableArray *portArray;
@property (nonatomic, strong) NSArray *pArray;
@property (strong, nonatomic) NSDictionary *Reports;
@property (strong, nonatomic) NSDictionary *PortsMarinas;
@property (strong, nonatomic) NSMutableArray *Videos;
@property (strong, nonatomic) IBOutlet UILabel *marinaNameLabelMain;

@property (strong, nonatomic) IBOutlet UIView *activityIndicatorView;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) IBOutlet UIImageView *activityImage;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@end