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
static NSString *highScoreString = @"highScore";

@interface ViewController ()

@property NSInteger row;
@property NSInteger column;
@property NSMutableArray *cardDeck;
@property UIImageView *selectedCard;
@property UIImage *cardCover;
@property (weak, nonatomic) IBOutlet UIStackView *rowStackView;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftBarItem;
@property NSTimer *timer;
@property NSInteger timerTick;
@property NSInteger solvedCounter;

@end

@implementation ViewController

- (void)initialize
{
    self.cardDeck = [[NSMutableArray alloc] init];
    self.cardCover = [UIImage imageNamed:cardCover];
    self.rightBarItem.enabled = NO;
    [self.rightBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}
                                     forState:UIControlStateNormal];
    self.leftBarItem.enabled = NO;
    [self.leftBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}
                                     forState:UIControlStateNormal];
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
    
    // reset everything to 0
    [self resetStatusBar];
    
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

- (void)resetStatusBar
{
    self.solvedCounter = 0;
    self.navigationBar.title = [[NSString alloc] initWithFormat:@"Solved: %d", (int)self.solvedCounter];
    [self.cardDeck removeAllObjects];
    for (UIView *subView in self.rowStackView.arrangedSubviews) {
        [subView removeFromSuperview];
    }
    self.timerTick = 0;
    self.leftBarItem.title = @"00:00";
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(timerTick:)
                                                userInfo:nil
                                                 repeats:YES];
    
    NSUserDefaults *info = [NSUserDefaults standardUserDefaults];
    NSInteger highScore = [info integerForKey:highScoreString];
    [self.rightBarItem setTitle:[NSString stringWithFormat:@"Top Score: %02d:%02d", (int)highScore / 60, (int)highScore % 60]];
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
    
    if (card.opened || card.guessed)
        return;
    
    if (self.selectedCard == nil) {
        [self openCard:imageView card:card];
        self.selectedCard = imageView;
        card.guessed = YES;
        return;
    }
    
    PokerCard *selectedCard = self.cardDeck[self.selectedCard.tag - 2000];
    [self openCard:imageView card:card];
    if (![card.name isEqualToString:selectedCard.name]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self closeCard:self.selectedCard];
            [self closeCard:imageView];
            self.selectedCard = nil;
            selectedCard.guessed = NO;
        });
        return;
    }

    [self openCard:imageView card:card];
    selectedCard.opened = YES;
    card.opened = YES;
    self.selectedCard = nil;

    // Increase Counter
    self.solvedCounter += 1;
    self.navigationBar.title = [NSString stringWithFormat:@"Solved: %d", (int) self.solvedCounter];

    
    // Check for end game
        // if all card is opened
    if (self.solvedCounter >= self.cardDeck.count / 2) {
        [self.timer invalidate];
        self.timer = nil;
        
        NSUserDefaults *info = [NSUserDefaults standardUserDefaults];
        NSInteger highScore = [info integerForKey:highScoreString];
        
        if (self.timerTick < highScore || highScore <= 0) {
            [info setInteger:self.timerTick forKey:highScoreString];
        }
        
        
        NSString *message = [[NSString alloc] initWithFormat:@"You've solved it in %02d:%02d!", (int)self.timerTick / 60,
                             (int)self.timerTick % 60];
        UIAlertController *endGameAlert = [UIAlertController alertControllerWithTitle:@"Congrats!"
                                                                              message:message
                                                                       preferredStyle:UIAlertControllerStyleAlert];
        [endGameAlert addAction:[UIAlertAction actionWithTitle:@"Restart"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *handler){
                                                           [self setupNewGame];
                                                       }]
         ];
        [self presentViewController:endGameAlert animated:YES completion:nil];
    }
}

- (IBAction)timerTick:(id)sender
{
    self.timerTick += 1;
    [self.leftBarItem setTitle:[NSString stringWithFormat:@"%02d:%02d", (int)self.timerTick / 60, (int)self.timerTick % 60]];
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
