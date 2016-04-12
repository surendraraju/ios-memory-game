//
//  ViewController.m
//  MatchCardGame
//
//  Created by Kean Ho Chew on 11/04/2016.
//  Copyright © 2016 Kean Ho Chew. All rights reserved.
//

#import "ViewController.h"

static int TOTAL_CARDS_NUMBER_TYPES = 13;
static int TOTAL_CARDS_SHAPE_TYPES = 4;
static NSString *cardId[13] = { @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"J", @"Q", @"K", @"A" };
static NSString *cardShape[4] = { @"club", @"diamond", @"heart", @"spade" };
static NSString *cardCover = @"card_cover";

enum cardId {
    CARD_2 = 0,
    CARD_3,
    CARD_4,
    CARD_5,
    CARD_6,
    CARD_7,
    CARD_8,
    CARD_9,
    CARD_10,
    CARD_J,
    CARD_Q,
    CARD_K,
    CARD_A
};

enum cardShape {
    CLUB = 0,
    DIAMOND,
    HEART,
    SPADE
};

@interface ViewController ()

@property NSInteger row;
@property NSInteger column;
@property NSMutableArray *cardDeck;
@property (weak, nonatomic) IBOutlet UIStackView *rowStackView;

@end

@implementation ViewController
{
    NSMutableArray *deck;
}

- (void)initialize
{
    self.cardDeck = [[NSMutableArray alloc] init];
}

- (void)viewDidLoad
{
    [self initialize];
    [super viewDidLoad];
    [self setupNewGame];
    
}

- (void)setupNewGame
{
    int i, j, k;
    BOOL still_drawing = true;
    NSInteger totalCards, totalDraws;
    NSMutableString *cardName;

    // hard code to 4x4
    self.row = 4;
    self.column = 4;
    
    // calculate total draw card
    totalCards = self.row * self.column;
    totalDraws = totalCards / 2;
    
    // draw random numbers for card type
    while(still_drawing) {
        if (self.cardDeck.count >= totalDraws)
            break;
        
        cardName = [[NSMutableString alloc] initWithFormat:@"%@_%@",
                    cardShape[arc4random_uniform(TOTAL_CARDS_SHAPE_TYPES)],
                    cardId[arc4random_uniform(TOTAL_CARDS_NUMBER_TYPES)]];
        
        if (![self.cardDeck containsObject:cardName])
            [self.cardDeck addObject:cardName];
        
    }
    
    // extract card and insert to array
    for(i=0; i < totalDraws; i++) {
        NSMutableString *duplicates = [[NSMutableString alloc] initWithString:self.cardDeck[i]];
        [self.cardDeck addObject:duplicates];
    }
    
    // Shuffle the card deck
    [self shuffleDeck];
    
    // Loop over and create the buttons
    k = 0;
    self.rowStackView.axis = UILayoutConstraintAxisVertical;
    self.rowStackView.distribution = UIStackViewDistributionFillEqually;
    self.rowStackView.alignment = UIStackViewAlignmentCenter;
    
    for (i=0; i<self.row; i++) {
        
        UIStackView *verticalStackView = [[UIStackView alloc] init];
        verticalStackView.axis = UILayoutConstraintAxisHorizontal;
        verticalStackView.distribution = UIStackViewDistributionFillEqually;
        verticalStackView.alignment = UIStackViewAlignmentCenter;
        
        
        for (j=0; j<self.column; j++) {
            UIImage *image = [UIImage imageNamed:self.cardDeck[k]];
            
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.accessibilityIdentifier = self.cardDeck[k];
            [verticalStackView addArrangedSubview:imageView];
            k++;
            
            UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didPressedImage:)];
            gesture.numberOfTapsRequired = 1;
            gesture.cancelsTouchesInView = YES;
            imageView.userInteractionEnabled = YES;
            [imageView addGestureRecognizer:gesture];
        }
        [self.rowStackView addArrangedSubview:verticalStackView];
    }
}

- (void)shuffleDeck
{
    int i, j;
    
    for(i=0; i<self.cardDeck.count; i++) {
        j = arc4random_uniform((u_int32_t)self.cardDeck.count);
        [self.cardDeck exchangeObjectAtIndex:i withObjectAtIndex:j];
    }
}

- (IBAction)didPressedImage:(id)sender
{
    UITapGestureRecognizer *gesture = sender;
    UIImageView *imageView = (UIImageView *) gesture.view;
    
    NSLog(@"ImageName = %@", imageView.accessibilityIdentifier);
    NSLog(@"Activated!");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
