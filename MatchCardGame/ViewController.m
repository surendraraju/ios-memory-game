//
//  ViewController.m
//  MatchCardGame
//
//  Created by Kean Ho Chew on 11/04/2016.
//  Copyright © 2016 Kean Ho Chew. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"
#import "PokerCard.h"

static int TOTAL_CARDS_NUMBER_TYPES = 13;
static int TOTAL_CARDS_SHAPE_TYPES = 4;
static NSString *cardId[13] = { @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"J", @"Q", @"K", @"A" };
static NSString *cardShape[4] = { @"club", @"diamond", @"heart", @"spade" };
static NSString *cardCover = @"card_cover";

@interface ViewController ()

@property NSInteger row;
@property NSInteger column;
@property NSMutableArray *cardDeck;
@property UIImageView *selectedCard;
@property UIImage *cardCover;
@property (weak, nonatomic) IBOutlet UIStackView *rowStackView;

@end

@implementation ViewController

- (void)initialize
{
    self.cardDeck = [[NSMutableArray alloc] init];
    self.cardCover = [UIImage imageNamed:cardCover];
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
    PokerCard *card;
    
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
        
        if (![self.cardDeck containsObject:cardName]) {
            card = [[PokerCard alloc] init];
            card.name = cardName;
            card.opened = NO;
            [self.cardDeck addObject:card];
        }
        
    }
    
    // extract card and insert to array
    for(i=0; i < totalDraws; i++) {
        card = self.cardDeck[i];
        PokerCard *duplicates = [[PokerCard alloc] initWithString:card.name];
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
        verticalStackView.spacing = 5;
        
        
        for (j=0; j<self.column; j++) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:self.cardCover];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            card = self.cardDeck[k];
            imageView.tag = 2000 + k;
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
    PokerCard *card = self.cardDeck[imageView.tag - 2000];
    
    if (card.opened)
        return;
    
    
    if (self.selectedCard == nil) {
        [self openCard:imageView card:card];
        self.selectedCard = imageView;
        return;
    }
    
    PokerCard *selectedCard = self.cardDeck[self.selectedCard.tag - 2000];
    [self openCard:imageView card:card];
    if (![card.name isEqualToString:selectedCard.name]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self closeCard:self.selectedCard];
            [self closeCard:imageView];
            self.selectedCard = nil;
        });
        return;
    }

    [self openCard:imageView card:card];
    selectedCard.opened = YES;
    card.opened = YES;
    self.selectedCard = nil;

    // Increase Counter

    
    // Check for end game
        // if all card is opened
        // prompt alert
    NSLog(@"Card Opened: %@", card.name);
    
}

- (void)openCard:(UIImageView *)imageView card:(PokerCard *)card
{
    UIImage *image = [UIImage imageNamed:card.name];
    
    [UIView transitionWithView:imageView duration:0.4
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^(void) {
                        imageView.image = image;
                    }
                    completion:nil
     ];
}

- (void)closeCard:(UIImageView *)imageView
{
    [UIView transitionWithView:imageView duration:0.8
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^(void) {
                        imageView.image = self.cardCover;
                    }
                    completion:nil
     ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
