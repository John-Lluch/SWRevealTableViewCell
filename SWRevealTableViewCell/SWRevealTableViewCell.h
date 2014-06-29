/*

 Copyright (c) 2014 Joan Lluch <joan.lluch@sweetwilliamsl.com>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is furnished
 to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
*/


/*

 DESCRIPTION

 SWRevealTableViewCell is UITableViewCell subclass to easily display left and right buttons based on user
 pan gestures. Similar to the mail app and but with enhanced features.

 RELEASE NOTES
 
 Version 0.0.1 (Current Version)
    - Initial Release
 
*/


#import <UIKit/UIKit.h>

#define SupportsVisualEffects false

@class SWRevealTableViewCell;
@class UIVisualEffect;

#pragma mark - SWCellButtonItem

/* A cell button item SWCellButtonItem is a button specialized for revealing behind a SWRevealTableViewCell.
   It is conceptually similar to a UIBarButtonItem except that instances do not implement a target and a action,
   instead, a handler block must be provided to execute derived actions */

@interface SWCellButtonItem : NSObject

+ (instancetype)itemWithTitle:(NSString*)title handler:(void(^)(SWCellButtonItem *item, SWRevealTableViewCell* cell))handler;
+ (instancetype)itemWithImage:(UIImage*)image handler:(void(^)(SWCellButtonItem *item, SWRevealTableViewCell* cell))handler;

@property(nonatomic) CGFloat width;              // default is 0.0
@property(nonatomic) UIImage *image;             // default is nil
@property(nonatomic) UIColor *backgroundColor;   // default is nil
@property(nonatomic) UIColor *tintColor;         // default is nil
@property(nonatomic, copy) NSString *title;      // default is nil
@property(nonatomic) UIVisualEffect *visualEffect;

@end


#pragma mark - SWCellRevealPosition

/* Enum values for SWRevealTableViewCell's setRevealPosition:animated: and @property revealPosition */

typedef NS_ENUM(NSUInteger, SWCellRevealPosition)
{
    // Left position, cell is presented left-offseted with utility items on the right
    SWCellRevealPositionLeft,

    // Center position
	SWCellRevealPositionCenter,
    
    // Right possition, cell is presented right-offseted with utility items on the left
	SWCellRevealPositionRight,
};


#pragma mark - SWRevealTableViewCell

/* A UITableViewCell subclass capable of presenting right and left utility views similar to the Mail app */

@protocol SWRevealTableViewCellDelegate;
@protocol SWRevealTableViewCellDataSource;

@interface SWRevealTableViewCell : UITableViewCell

// delegate
@property (nonatomic, assign) id <SWRevealTableViewCellDelegate> delegate;
@property (nonatomic, assign) id <SWRevealTableViewCellDataSource> dataSource;

// An array of custom cell button items (SWCellButtonItem) to display on the left side of the cell
@property (nonatomic, readonly) NSArray *leftCellButtonItems;

// An array of custom cell button items (SWCellButtonItem) to display on the right side of the cell
@property (nonatomic, readonly) NSArray *rightCellButtonItems;

// Front view position, use this to set a particular position state on the cell
// On initialization it is set to RevealPositionCenter
@property (nonatomic, assign) SWCellRevealPosition revealPosition;

// Chained animation of the cell reveal position. You can call it several times in a row to achieve
// any set of animations you wish. Animations will be chained and performed one after the other.
- (void)setRevealPosition:(SWCellRevealPosition)revealPosition animated:(BOOL)animated;

// Velocity required for the controller to toggle its reveal state based on a swipe movement, default is 150
// You can disable velocity triggered swipe by seting this to a very high number
@property (nonatomic, assign) CGFloat quickFlickVelocity;

// Duration for the reveal animation, default is 0.25
@property (nonatomic, assign) NSTimeInterval revealAnimationDuration;

// If YES (the default) the controller will bounce to the center position when dragging further than the total utility items width
@property (nonatomic, assign) BOOL bounceBackOnOverdraw;
@property (nonatomic, assign) BOOL bounceBackOnLeftOverdraw;

// Defines a width on the border of the cell contentView to the panGesturRecognizer where the gesture is allowed,
// default is 0 which means no restriction.
@property (nonatomic, assign) CGFloat draggableBorderWidth;

@end


#pragma mark - SWRevealTableViewCellDataSource

// Implement the following required methods to provide left and right items.
// Return nil if no items must be presented

@protocol SWRevealTableViewCellDataSource <NSObject>
@required
- (NSArray*)leftButtonItemsInRevealTableViewCell:(SWRevealTableViewCell *)revealTableViewCell;
- (NSArray*)rightButtonItemsInRevealTableViewCell:(SWRevealTableViewCell *)revealTableViewCell;

@end


#pragma mark - SWRevealTableViewCellDelegate

// Implement the following optional methods to be notified on changes and to provide custom behaviors

@protocol SWRevealTableViewCellDelegate <NSObject>
@optional

/* Cell position notification */

// The following delegate methods will be called before and after the cell moves to a position
- (void)revealTableViewCell:(SWRevealTableViewCell *)revealTableViewCell willMoveToPosition:(SWCellRevealPosition)position;
- (void)revealTableViewCell:(SWRevealTableViewCell *)revealTableViewCell didMoveToPosition:(SWCellRevealPosition)position;

// This will be called inside the reveal animation, thus you can use it to place your own code that will be animated in sync
- (void)revealTableViewCell:(SWRevealTableViewCell *)revealTableViewCell animateToPosition:(SWCellRevealPosition)position;

/* Gesture based reveal */

// Implement this to return NO when you want the pan gesture recognizer to be ignored
- (BOOL)revealTableViewCellPanGestureShouldBegin:(SWRevealTableViewCell *)revealTableViewCell;

// Implement this to return NO when you want the tap gesture recognizer to be ignored
- (BOOL)revealTableViewCellTapGestureShouldBegin:(SWRevealTableViewCell *)revealTableViewCell;

// Implement this to return YES if you want this gesture recognizer to share touch events with the pan gesture
- (BOOL)revealTableViewCell:(SWRevealTableViewCell *)revealTableViewCell
    panGestureRecognizerShouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;

// Called when the gestureRecognizer began and ended
- (void)revealTableViewCellPanGestureBegan:(SWRevealTableViewCell *)revealTableViewCell;
- (void)revealTableViewCellPanGestureEnded:(SWRevealTableViewCell *)revealTableViewCell;

/* Reveal progress */

// The following methods provide a means to track the evolution of the gesture recognizer.
// The 'location' parameter is the X origin coordinate of the front view as the user drags it
// The 'progress' parameter is a positive value from 0 to 1 indicating the front view location relative to the
// rearRevealWidth or rightRevealWidth. 1 is fully revealed, dragging ocurring in the overDraw region will result in values above 1.
- (void)revealTableViewCell:(SWRevealTableViewCell *)revealTableViewCell panGestureBeganFromLocation:(CGFloat)location progress:(CGFloat)progress;
- (void)revealTableViewCell:(SWRevealTableViewCell *)revealTableViewCell panGestureMovedToLocation:(CGFloat)location progress:(CGFloat)progress;
- (void)revealTableViewCell:(SWRevealTableViewCell *)revealTableViewCell panGestureEndedToLocation:(CGFloat)location progress:(CGFloat)progress;

@end

