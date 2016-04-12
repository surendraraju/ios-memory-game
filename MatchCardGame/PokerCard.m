//
//  PokerCard.m
//  MatchCardGame
//
//  Created by Kean Ho Chew on 11/04/2016.
//  Copyright © 2016 Kean Ho Chew. All rights reserved.
//

#import "PokerCard.h"

@implementation PokerCard

- (PokerCard *)initWithString:(NSString *)name
{
    self.name = name;
    self.opened = NO;
    return self;
}

@end
