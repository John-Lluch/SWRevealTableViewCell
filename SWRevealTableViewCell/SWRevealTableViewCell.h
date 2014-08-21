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

 SWRevealTableViewCell is a UITableViewCell subclass to easily display left and right buttons based on user
 pan gestures or developer programmatic actions. Similar to the mail app and but with enhanced features.

 RELEASE NOTES
 
 Version 0.3.1 to 0.3.5 (current Version)
    - Bug fixes
 
 Version 0.3.0
    - Major upgrade and refactoring.
    - Support for extended items (similar to delete action of iOS8 mail)
    - Cell button item handler blocks can now specify a return value

 Version 0.2.1 (Current Version)
    - Bug fixes and some refactoring (on UIActionSheet category and layout)
 
 Version 0.2.0

    - Added UIActionSheet category extension
 
 Version 0.1.0
    - Added properties 'rightCascadeReversed', 'leftCascadeReversed', 'bounceBackOnRightOverdraw', 'bounceBackOnLeftOverdraw'
 
 Version 0.0.1
    - Initial Release
 
*/


#import <UIKit/UIKit.h>

#define SupportsVisualEffects false

@class SWRevealTableViewCell;
@class UIVisualEffect;
@class UIPopoverPresentationController;


#pragma mark - SWCellButtonItem

/* A cell button item SWCellButtonItem is a button specialized for revealing behind a SWRevealTableViewCell.
   It is conceptually similar to a UIBarButtonItem except that instances do not implement a target and a action,
   instead, a handler block must be provided to execute derived actions 
*/

@interface SWCellButtonItem : NSObject

// Cell Button Item initialization
// Return YES on the handler block if you want the item to be automatically dismissed immediatelly after user tap, NO otherwise
+ (instancetype)itemWithTitle:(NSString*)title handler:(BOOL(^)(SWCellButtonItem *item, SWRevealTableViewCell* cell))handler;
+ (instancetype)itemWithImage:(UIImage*)image handler:(BOOL(^)(SWCellButtonItem *item, SWRevealTableViewCell* cell))handler;

// Cell Button Item properties
@property(nonatomic) CGFloat width;              // default is 0.0
@property(nonatomic) UIImage *image;             // default is nil
@property(nonatomic) UIColor *backgroundColor;   // default is nil
@property(nonatomic) UIColor *tintColor;         // default is nil
@property(nonatomic) NSString *title;            // default is nil
@property(nonatomic) UIVisualEffect *visualEffect;

@end


#pragma mark - SWCellRevealPosition

/* Enum values for SWRevealTableViewCell's setRevealPosition:animated: and @property revealPosition 
*/

typedef NS_ENUM(NSInteger, SWCellRevealPosition)
{
    // Left position, cell is presented left-offseted with first right utility item fully expanded
    SWCellRevealPositionLeftExtended,

    // Left position, cell is presented left-offseted with utility items on the right
    SWCellRevealPositionLeft,

    // Center position
    SWCellRevealPositionCenter,
    
    // Right possition, cell is presented right-offseted with utility items on the left
    SWCellRevealPositionRight,
    
    // Right possition, cell is presented right-offseted with first left utility item fully expanded
    SWCellRevealPositionRightExtended,
};


/* Enum values for SWRevealTableViewCell's cellRevealMode property
*/

typedef NS_ENUM(NSInteger, SWCellRevealMode)
{
    // cascadeReversed is set to NO, bounceBackOnOverdraw is set to NO, actionOnOverdraw is set to NO
    SWCellRevealModeNormal,

    // cascadeReversed is set to NO, bounceBackOnOverdraw is set to YES, actionOnOverdraw is set to NO
    SWCellRevealModeNormalWithBounce,

    // cascadeReversed is set to YES, bounceBackOnOverdraw is set to NO, actionOnOverdraw is set to YES
    SWCellRevealModeReversedWithAction,
};


#pragma mark - UIActionSheetExtension

@interface UIActionSheet(SWCellButtonItem)
- (void)showFromCellButtonItem:(SWCellButtonItem *)item animated:(BOOL)animated;
@end

#pragma mark - UIViewPopoverPresentationController

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
@interface UIPopoverPresentationController(SWCellButtonItem)
@property(nonatomic) SWCellButtonItem *cellButtonItem;
@end
#endif

#pragma mark - SWRevealTableViewCell

/* A UITableViewCell subclass capable of presenting right and left utility views similar to the Mail app 
*/

@protocol SWRevealTableViewCellDelegate;
@protocol SWRevealTableViewCellDataSource;

@interface SWRevealTableViewCell : UITableViewCell
{
    // The SWRevealTableViewCell is meant to be overriden,
    // thus we allow protected access to the _delegate ivar, this also prevents redeclaration of the same
    id __weak _delegate;
}

// delegate, datasource
@property (nonatomic, weak) id <SWRevealTableViewCellDelegate> delegate;
@property (nonatomic, weak) id <SWRevealTableViewCellDataSource> dataSource;

// An array of custom cell button items (SWCellButtonItem) to display on the left side of the cell
@property (nonatomic, readonly) NSArray *leftCellButtonItems;

// An array of custom cell button items (SWCellButtonItem) to display on the right side of the cell
@property (nonatomic, readonly) NSArray *rightCellButtonItems;

// Front view position, use this to programmatically set a particular position to the cell
// If you call the animated version several times in a row animations will be chained and performed one after the other.
@property (nonatomic) SWCellRevealPosition revealPosition;
- (void)setRevealPosition:(SWCellRevealPosition)revealPosition animated:(BOOL)animated;

// Determines whether users can reveal items while the receiver is in editing mode
@property (nonatomic) BOOL allowsRevealInEditMode;

// Velocity required for the controller to toggle its reveal state based on a swipe movement, default is 150
// You can disable velocity triggered swipe by seting this to a very high number
@property (nonatomic) CGFloat quickFlickVelocity;

// Duration for the reveal animation, default is 0.25
@property (nonatomic) NSTimeInterval revealAnimationDuration;

// Conveninece method to set cascadeReversed, bounceOnOverdraw and actionOnOverdraw as a whole
// Note that reading this property may not always give an accurate value
@property (nonatomic) SWCellRevealMode cellRevealMode;

// Defines whether further items should appear below nearer ones (normal) or abobe them (reversed). Set to YES for reversed behavior (similar to iO8 mail)
@property (nonatomic) BOOL rightCascadeReversed;   // default is NO
@property (nonatomic) BOOL leftCascadeReversed;    // default is NO

// Determines whether the controller will bounce to the center position when dragging further than the total utility items width.
// Setting this to YES will override any returned values of item action handlers
@property (nonatomic) BOOL bounceBackOnRightOverdraw;   // default is NO
@property (nonatomic) BOOL bounceBackOnLeftOverdraw;    // default is NO

// Defines whether the handler block of the first item must invoked on user overdraw.
// When this is set to YES user pan action is acompained with an animation similar to the delete action of iOS8 mail.
// This property is only honored when XXCascadeReversed is also set to YES
@property (nonatomic) BOOL performsActionOnRightOverdraw;   // default is NO
@property (nonatomic) BOOL performsActionOnLeftOverdraw;    // default is NO

// Defines a width on the border of the cell contentView to the panGesturRecognizer where the gesture is allowed,
// default is 0 which means no restriction.
@property (nonatomic) CGFloat draggableBorderWidth;

@end


#pragma mark - SWRevealTableViewCellDataSource

// Implement the following required methods to provide left and right items.
// Return nil if no items must be presented

@protocol SWRevealTableViewCellDataSource <NSObject>
@optional
- (NSArray*)leftButtonItemsInRevealTableViewCell:(SWRevealTableViewCell *)revealTableViewCell;
- (NSArray*)rightButtonItemsInRevealTableViewCell:(SWRevealTableViewCell *)revealTableViewCell;

@end


#pragma mark - SWRevealTableViewCellDelegate

// Implement the following optional methods to be notified on changes and to provide custom behaviors

@protocol SWRevealTableViewCellDelegate <NSObject>
@optional

/* Cell position notification 
*/

// The following delegate methods will be called before and after the cell moves to a position
- (void)revealTableViewCell:(SWRevealTableViewCell *)revealTableViewCell willMoveToPosition:(SWCellRevealPosition)position;
- (void)revealTableViewCell:(SWRevealTableViewCell *)revealTableViewCell didMoveToPosition:(SWCellRevealPosition)position;

// This will be called inside the reveal animation, thus you can use it to place your own code that will be animated in sync
- (void)revealTableViewCell:(SWRevealTableViewCell *)revealTableViewCell animateToPosition:(SWCellRevealPosition)position;

/* Gesture based reveal 
*/

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

/* Reveal progress 
*/

// The following methods provide a means to track the evolution of the gesture recognizer.
// The 'location' parameter is the X origin coordinate of the front view as the user drags it
// The 'progress' parameter is a positive value from 0 to 1 indicating the front view location relative to the
// rearRevealWidth or rightRevealWidth. 1 is fully revealed, dragging ocurring in the overDraw region will result in values above 1.
- (void)revealTableViewCell:(SWRevealTableViewCell *)revealTableViewCell panGestureBeganFromLocation:(CGFloat)location progress:(CGFloat)progress;
- (void)revealTableViewCell:(SWRevealTableViewCell *)revealTableViewCell panGestureMovedToLocation:(CGFloat)location progress:(CGFloat)progress;
- (void)revealTableViewCell:(SWRevealTableViewCell *)revealTableViewCell panGestureEndedToLocation:(CGFloat)location progress:(CGFloat)progress;

@end

