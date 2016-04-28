//
//  NSMutableArray+QueueAdditions.m
//  CaptApp Apple TV
//
//  Created by Jorge Mendoza Martínez on 4/27/16.
//  Copyright © 2016 CaptApp TV Network. All rights reserved.
//

#import "NSMutableArray+QueueAdditions.h"

@implementation NSMutableArray (QueueAdditions)

- (id)pop
{
    // nil if [self count] == 0
    id lastObject = [self lastObject];
    if (lastObject)
        [self removeLastObject];
    return lastObject;
}

- (void)push:(id)obj
{
    [self addObject: obj];
}

@end
