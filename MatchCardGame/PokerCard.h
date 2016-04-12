//
//  PokerCard.h
//  MatchCardGame
//
//  Created by Kean Ho Chew on 11/04/2016.
//  Copyright © 2016 Kean Ho Chew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PokerCard : NSObject

@property NSString *name;
@property BOOL opened;

- (PokerCard *)initWithString:(NSString *)name;

@end
