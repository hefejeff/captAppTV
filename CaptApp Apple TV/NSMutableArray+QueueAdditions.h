//
//  NSMutableArray+QueueAdditions.h
//  CaptApp Apple TV
//
//  Created by Jorge Mendoza Martínez on 4/27/16.
//  Copyright © 2016 CaptApp TV Network. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (QueueAdditions)

- (id)pop;
- (void)push:(id)obj;

@end
