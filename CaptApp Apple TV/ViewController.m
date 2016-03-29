//
//  ViewController.m
//  CaptApp Apple TV
//
//  Created by Jeffrey Wells on 12/25/15.
//  Copyright © 2015 CaptApp TV Network. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@end

@implementation ViewController

@synthesize vidArray;
@synthesize portArray;
@synthesize Videos;
@synthesize Reports;
@synthesize PortsMarinas;
@synthesize collectionView;
@synthesize pArray;
@synthesize segmentedControl;
@synthesize marinaNameLabelMain;


- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"viewWillAppear");
    
    [super viewWillAppear:animated];
        
    [self get_ports:nil];
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [collectionView reloadData];
    
    [[UISegmentedControl appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"STHeitiSC-Medium" size:33.0], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showActivityIndicator {
    [UIView animateWithDuration:0.3 animations:^{_activityIndicatorView.alpha = 1.0; } completion:^(BOOL finshied){
        [activityView startAnimating];
    }];
    
}

-(void)hideActivityIndicator {
    [UIView animateWithDuration:0.3 animations:^{_activityIndicatorView.alpha = 0.0; } completion:^(BOOL finshied){
        [activityView stopAnimating];
        self.activityImage.hidden = YES;
    }];
    
}

-(IBAction)indexChanged:(UISegmentedControl *)sender
{
    switch (self.segmentedControl.selectedSegmentIndex)
    {
        case 0:
            [self get_ports:nil];
            break;
        case 1:
            //self.textLabel.text = @"Second Segment selected";
            break;
        case 2:
            //self.textLabel.text = @"Second Segment selected";
            break;
        case 3:
            //self.textLabel.text = @"Second Segment selected";
            break;
        case 4:
            //self.textLabel.text = @"Second Segment selected";
            break;
        default:
            break; 
    } 
}


- (void)get_ports:(id)sender {
    
     [self showActivityIndicator];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:@"http://captapp.com/wp-json/pods/portmarina" parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        
        self.PortsMarinas = (NSDictionary *)responseObject;
        self.pArray = [responseObject allObjects];
        [collectionView reloadData];
        
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
}


- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return [pArray count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}



- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    
    NSDictionary *tempDictionary= [pArray objectAtIndex:indexPath.row];

    ReportsCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"theCell"
                                        forIndexPath:indexPath];
       
        NSString *logoURL = [tempDictionary valueForKeyPath:@"logo.guid"];
        NSString *marinaName = [tempDictionary valueForKeyPath:@"post_title"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
    
        NSData *logoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:logoURL]];
        UIImage *logo = [UIImage imageWithData:logoData];
        
    dispatch_async(dispatch_get_main_queue(), ^{
            
        [cell.vid_thumb setImage:logo];
        cell.marinaNameLabel.text = marinaName;
        [cell setNeedsLayout];
       
        });
        
        
        
        
    });
     NSLog(@"State: %@", @"logo download");
    [self hideActivityIndicator];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"SETTING SIZE FOR ITEM AT INDEX %ld", (long)indexPath.row);
    CGSize mElementSize = CGSizeMake(420, 286);
    return mElementSize;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 30.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 30.0;
}

// Layout: Set Edges
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    // return UIEdgeInsetsMake(0,8,0,8);  // top, left, bottom, right
    return UIEdgeInsetsMake(30,30,30,30);  // top, left, bottom, right
}


-(void)didUpdateFocusInContext:(UIFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator {
    
    
    if (context.nextFocusedView) {
        [coordinator addCoordinatedAnimations:^{
            context.nextFocusedView.transform = CGAffineTransformMakeScale(1.1, 1.1);
        } completion:nil];
    }
    if (context.previouslyFocusedView) {
        [coordinator addCoordinatedAnimations:^{
            context.previouslyFocusedView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:nil];
    }
    
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    NSLog(@"prepareForSegue: %@", segue.identifier);
    if ([segue.identifier isEqualToString:@"toVideosSegue"])
    {

        NSIndexPath *indexPath = [[self collectionView] indexPathForCell:sender];
        NSString *portID = [[pArray objectAtIndex:indexPath.row] valueForKey:@"ID"];
        NSString *portName = [[pArray objectAtIndex:indexPath.row] valueForKey:@"post_title"];
        NSString *logo = [[pArray objectAtIndex:indexPath.row] valueForKeyPath:@"logo.guid"];

        NSLog(@"portID: %@", portID);
        NSLog(@"portNamer: %@", portName);
        
        [segue.destinationViewController setCurrentPort : portID];
        [segue.destinationViewController setLogoURL : logo];
        [segue.destinationViewController setPortName : portName];
        
        
    }
}

@end
