//
//  ReportsCollectionViewCell.h
//  CaptApp Apple TV
//
//  Created by Jeffrey Wells on 12/28/15.
//  Copyright © 2015 CaptApp TV Network. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportsCollectionViewCell : UICollectionViewCell


@property (weak, nonatomic) IBOutlet UIImageView *vid_thumb;
@property (weak, nonatomic) IBOutlet UILabel *boatNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *reportDateLabel;

@property (weak, nonatomic) NSString *boatNameString;
@property (strong, nonatomic) IBOutlet UILabel *marinaNameLabel;

@end
