//
//  ServiceProvider.m
//  captAppTopShelf
//
//  Created by Jeffrey Wells on 2/23/16.
//  Copyright © 2016 CaptApp TV Network. All rights reserved.
//

#import "ServiceProvider.h"

@interface ServiceProvider ()

@end

@implementation ServiceProvider


- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

#pragma mark - TVTopShelfProvider protocol

- (TVTopShelfContentStyle)topShelfStyle {
    // Return desired Top Shelf style.
    return TVTopShelfContentStyleInset;
}

- (NSArray *)topShelfItems {
    // Create an array of TVContentItems.
    
    TVContentIdentifier *identifier = [[TVContentIdentifier alloc] initWithIdentifier:@"id" container:nil];
    TVContentItem *recentItem1 = [[TVContentItem alloc] initWithContentIdentifier:identifier];
    recentItem1.imageURL =  [NSURL URLWithString:@"http://captapp.com/wp-content/uploads/2016/02/leader-01.png"];
    
    TVContentIdentifier *identifier2 = [[TVContentIdentifier alloc] initWithIdentifier:@"id2" container:nil];
    TVContentItem *recentItem2 = [[TVContentItem alloc] initWithContentIdentifier:identifier2];
    recentItem2.imageURL =  [NSURL URLWithString:@"http://captapp.com/wp-content/uploads/2016/02/marlin-01.png"];
    
    TVContentIdentifier *identifier3 = [[TVContentIdentifier alloc] initWithIdentifier:@"id3" container:nil];
    TVContentItem *recentItem3 = [[TVContentItem alloc] initWithContentIdentifier:identifier3];
    recentItem3.imageURL =  [NSURL URLWithString:@"http://captapp.com/wp-content/uploads/2015/10/dorado1-01.jpg"];
    
    return @[recentItem1, recentItem2, recentItem3];
}

@end
