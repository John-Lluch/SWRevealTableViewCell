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

#import <UIKit/UIGestureRecognizerSubclass.h>

#import "SWRevealTableViewCell.h"

#pragma mark - SWCellButton Item

@class SWUtilityContentView;

@interface SWCellButtonItem()
@property(nonatomic,strong) void (^handler)(SWCellButtonItem *, SWRevealTableViewCell*);
@property(nonatomic,assign) SWUtilityContentView *view;
@end

@implementation SWCellButtonItem

- (id)initWithImage:(UIImage *)image
{
    self = [super init];
    if ( self )
    {
        _image = image;
        _width = image.size.width;
    }
    return self;
}


- (id)initWithTitle:(NSString *)title
{
    self = [super init];
    if ( self )
    {
        _title = title;
    }
    return self;
}


//- (id)copyWithZone:(NSZone *)zone
//{
//    SWCellButtonItem *theCopy = [[self class] allocWithZone:zone];
//    theCopy.width = _width;
//    theCopy.image = _image;
//    theCopy.backgroundColor = _backgroundColor;
//    theCopy.tintColor = _tintColor;
//    theCopy.title = _title;
//    theCopy.visualEffect = _visualEffect;
//    theCopy.handler = _handler;
//    theCopy.view = _view;
//    return theCopy;
//}


- (instancetype)initWithTitle:(NSString *)title image:(UIImage*)image handler:(void(^)(SWCellButtonItem *, SWRevealTableViewCell* cell))handler;
{
    self = [super init];
    if ( self )
    {
        _title = title;
        _image = image;
        _handler = handler;
    }
    return self;
}


+ (instancetype)itemWithTitle:(NSString *)title handler:(void (^)(SWCellButtonItem *, SWRevealTableViewCell *))handler
{
    return [[SWCellButtonItem alloc] initWithTitle:title image:nil handler:handler];
}


+ (instancetype)itemWithImage:(UIImage*)image handler:(void(^)(SWCellButtonItem *item, SWRevealTableViewCell* cell))handler

{
    return [[SWCellButtonItem alloc] initWithTitle:nil image:image handler:handler];
}

// TO DO
//+ (instancetype)itemWithCustomView:(UIView*)view handler:(void(^)(SWCellButtonItem *item, SWRevealTableViewCell* cell))handler
//{
//}

@end


#pragma mark - SWUTilityButton

@interface SWUtilityButton : UIButton
@property (nonatomic) SWCellButtonItem *item;
@property (nonatomic) BOOL wantsCombinedLayout;
@end

@implementation SWUtilityButton

const CGFloat CombinedHeigh = 36;

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGRect frame = self.bounds;
    if ( _wantsCombinedLayout )
    {
        const CGFloat h = CombinedHeigh;
        const CGFloat gap = ceil((frame.size.height - h)/2);
        frame.origin.y = gap;
        frame.size.height = ceil(h*2/3);
    }

    return frame;
}


- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGRect frame = self.bounds;
    if ( _wantsCombinedLayout )
    {
        const CGFloat h = CombinedHeigh;
        const CGFloat gap = ceil((frame.size.height - h)/2);
        frame.origin.y = gap + floor(h*2/3);
        frame.size.height = ceil(h*1/3);
    }

    return frame;
}

@end


#pragma mark - SWUtilityView

@interface SWUtilityView: UIView
@property ( nonatomic) UIColor *customBackgroundColor;
@end


@implementation SWUtilityView

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    // do not call super, we want to prevent Apple's UITableViewCell implementation to set this
}


- (void)setCustomBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
}


- (UIColor*)customBackgroundColor
{
    return [super backgroundColor];
}

@end


#pragma mark - SWRevealTableViewCell(Internal)

@interface SWRevealTableViewCell(Internal)
- (void)_getAdjustedRevealPosition:(SWCellRevealPosition*)revealPosition forSymmetry:(int)symmetry;
- (NSArray*)_getLeftButtonItems;
- (NSArray*)_getRightButtonItems;
- (void)_didTapButtonAtIndex:(NSInteger)indx position:(SWCellRevealPosition)position;
@end


#pragma mark - SWUtilityContentView

@interface SWUtilityContentView: SWUtilityView
{
    __weak SWRevealTableViewCell *_c;
}

@property (nonatomic,readonly) NSArray *leftButtonItems;
@property (nonatomic,readonly) NSArray *rightButtonItems;
@property (nonatomic,readonly) NSMutableArray *leftViews;
@property (nonatomic,readonly) NSMutableArray *rightViews;

@end


static UIImage* _imageWithColor_size(UIColor* color, CGSize size)
{
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGRect rect = CGRectMake(0.0f, 0.0f, scale*size.width, scale*size.height);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, rect.size.width, rect.size.height, 8, 0, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    
    if (context == NULL)
        return nil;
    
    CGContextSetFillColorWithColor(context, [color CGColor]); // <-- Color to fill
    CGContextFillRect(context, rect);
    
    CGImageRef bitmapContext = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    UIImage *theImage = [UIImage imageWithCGImage:bitmapContext scale:scale orientation:UIImageOrientationUp];
    CGImageRelease(bitmapContext);
    
    return theImage;
}


@implementation SWUtilityContentView

- (id)initWithRevealTableViewCell:(SWRevealTableViewCell *)revealTableViewCell frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self )
    {
        [self setAutoresizesSubviews:NO];
        _c = revealTableViewCell;
    }
    return self;
}


- (NSInteger)leftCount
{

    [self _prepareLeftButtonItems];
    return _leftButtonItems.count;
}


- (NSInteger)rightCount
{
    [self _prepareRightButtonItems];
    return _rightButtonItems.count;
}


- (CGFloat)leftRevealWidth
{
    CGFloat width = 0;
    for ( SWCellButtonItem *item in _leftButtonItems )
    {
        width += item.width;
    }
    return width;
}


- (CGFloat)rightRevealWidth
{
    CGFloat width = 0;
    for ( SWCellButtonItem *item in _rightButtonItems )
    {
        width += item.width;
    }
    return width;
}


- (CGRect)referenceFrameForCellButtonItem:(SWCellButtonItem*)targetItem
{
    SWCellButtonItem *item = nil;
    CGRect bounds = self.bounds;
    
    CGFloat location = 0;
    
    if ( item != targetItem)
    {
        location = bounds.size.width;
        for ( item in _rightButtonItems )
        {
            location = location - item.width;
            if ( item == targetItem ) break;
        }
    }
    
    if ( item != targetItem)
    {
        location = bounds.origin.x;
        for ( item in _leftButtonItems )
        {
            if ( item == targetItem ) break;
            location = location + item.width;
        }
    }

    CGRect referenceFrame = bounds;
    referenceFrame.origin.x = location;
    referenceFrame.size.width = item.width;

    return referenceFrame;
}


- (void)deployRightItems
{
    [self _deployItemsForNewPosition:SWCellRevealPositionRight];
}


- (void)undeployRightItems
{
    [self _undeployItemsForNewPosition:SWCellRevealPositionRight];
}


- (void)deployLeftItems
{
    [self _deployItemsForNewPosition:SWCellRevealPositionLeft];
}


- (void)undeployLeftItems
{
    [self _undeployItemsForNewPosition:SWCellRevealPositionLeft];
}


- (CGFloat)frontLocationForPosition:(SWCellRevealPosition)revealPosition
{
    int symmetry = revealPosition<SWCellRevealPositionCenter? -1 : 1;
    
    CGFloat location = 0.0f;
    CGFloat itemsWidth = revealPosition<SWCellRevealPositionCenter? [self rightRevealWidth] : [self leftRevealWidth];
    
    [_c _getAdjustedRevealPosition:&revealPosition forSymmetry:symmetry];
    
    if ( revealPosition == SWCellRevealPositionRight )
        location = itemsWidth;
    
    else if ( revealPosition > SWCellRevealPositionRight )
        location = itemsWidth;

    return location*symmetry;
}


- (void)layoutForLocation:(CGFloat)xLocation
{
    if ( xLocation <= 0 )
    {
        [self _layoutViewsForNewPosition:SWCellRevealPositionRight location:xLocation];
    }
    
    if ( xLocation >= 0 )
    {
        [self _layoutViewsForNewPosition:SWCellRevealPositionLeft location:xLocation];
    }
}


- (void)resetButtonItems
{
    _leftButtonItems = nil;
    _rightButtonItems = nil;
}


- (void)_prepareLeftButtonItems
{
    if ( _leftButtonItems == nil )
        _leftButtonItems = [_c _getLeftButtonItems];
}


- (void)_prepareRightButtonItems
{
    if ( _rightButtonItems == nil )
        _rightButtonItems = [_c _getRightButtonItems];
}


- (void)_deployItemsForNewPosition:(SWCellRevealPosition)newPosition
{
    NSArray *items = newPosition<SWCellRevealPositionCenter ? _leftButtonItems : _rightButtonItems;
    NSMutableArray * __strong* views =  newPosition<SWCellRevealPositionCenter ? &_leftViews : &_rightViews;
    BOOL reversedCascade = newPosition<SWCellRevealPositionCenter ? _c.leftCascadeReversed : _c.rightCascadeReversed;
    UIViewAutoresizing mask = UIViewAutoresizingFlexibleHeight |
        (!!reversedCascade == newPosition<SWCellRevealPositionCenter ? UIViewAutoresizingFlexibleLeftMargin: UIViewAutoresizingFlexibleRightMargin);

    if ( items.count == 0 )
        return;
    
    *views = [NSMutableArray array];
    
    for ( SWCellButtonItem *item in items )
    {
        // get the button item
        NSAssert( [item isKindOfClass:[SWCellButtonItem class]], @"Cell button items must be of class SWCellButtonItem" );
        
        // get button item properties
        UIColor *color = item.backgroundColor;
        UIColor *tintColor = item.tintColor;
        UIImage *image = item.image;
        NSString *title = item.title;
    
        // create a utility view for the item
        SWUtilityView *utilityView = [[SWUtilityView alloc] initWithFrame:CGRectMake(0, 0, item.width, 20)];
        [utilityView setClipsToBounds:YES];
        
#if SupportsVisualEffects
        // add a visual effect
        UIVisualEffect *effect = item.visualEffect;
        if ( effect )
        {
            UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
            effectView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
            effectView.frame = utilityView.bounds;
            [utilityView addSubview:effectView];
        }
#endif
        
        // add a button
        SWUtilityButton *button = [SWUtilityButton buttonWithType:UIButtonTypeSystem];
        [button addTarget:self action:@selector(_buttonTouchUpAction:) forControlEvents:UIControlEventTouchUpInside];
        button.autoresizingMask = mask;
        
        button.frame = utilityView.bounds;
        button.titleLabel.numberOfLines = 0;
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.item = item;
        
        // Depending on which item properties the developer has set, we chose configure the button to make the best of it
        
        if ( image )
        {
            // we do not want to scale user provided images
            [button.imageView setContentMode:UIViewContentModeCenter];
        }
        
        if ( image && title.length>0 )
        {
            [button.titleLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleFootnote]];
            [button setWantsCombinedLayout:YES];
        }
        
        if ( image && color )
        {
            [utilityView setCustomBackgroundColor:color];
        }
        
        if ( image==nil && color )
        {
            image = _imageWithColor_size(color, CGSizeMake(1,1));
            image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            [button.imageView setContentMode:UIViewContentModeScaleToFill];
        }
        
        [button setTintColor:tintColor];
        [button setTitle:title forState:UIControlStateNormal];
        [button setImage:image forState:UIControlStateNormal];
        
        [utilityView addSubview:button];
        [*views addObject:utilityView];
        
        if ( reversedCascade ) [self insertSubview:utilityView atIndex:0];
        else [self addSubview:utilityView];
    }
    
    CGFloat xLocation = [self frontLocationForPosition:SWCellRevealPositionCenter];
    [self layoutForLocation:xLocation];
}


- (void)_undeployItemsForNewPosition:(SWCellRevealPosition)newPosition
{
    NSMutableArray * __strong* views = newPosition<SWCellRevealPositionCenter ? &_leftViews : &_rightViews;
    
    for ( SWUtilityView *utilityView in *views )
    {
        [utilityView removeFromSuperview];
    }
    
    *views = nil;
}


- (void)_layoutViewsForNewPosition:(SWCellRevealPosition)newPosition location:(CGFloat)xLocation //symmetry:(NSInteger)symmetry
{
    NSArray *views = newPosition<SWCellRevealPositionCenter? _leftViews : _rightViews;
    NSArray *items = newPosition<SWCellRevealPositionCenter ? _leftButtonItems : _rightButtonItems;
    CGFloat maxLocation = newPosition<SWCellRevealPositionCenter ? [self leftRevealWidth] : -[self rightRevealWidth] ;
    CGFloat symmetry = newPosition<SWCellRevealPositionCenter ? 1 : -1;
    
    if ( abs(xLocation) > abs(maxLocation) ) xLocation = maxLocation;
    
    NSInteger count = views.count;
    CGSize size = self.bounds.size;
    
    CGFloat endLocation = 0;
    for ( NSInteger i=0 ; i<count ; i++ )
    {
        SWCellButtonItem *item = [items objectAtIndex:i];
        
        CGFloat width = item.width;
        endLocation += width*symmetry;
        
        CGFloat lWidth = width*xLocation/maxLocation;
        CGFloat location =  xLocation*(endLocation/maxLocation);
        
        CGFloat xReference = symmetry<0 ? size.width+0 : 0-lWidth;

// This works better on iOS8
//        CGFloat x = 0.5*floor(2*(xReference+location));
//        CGFloat w = 0.5*ceil(2*lWidth);
        
// This works better on iOS7
        CGFloat x = floor(xReference+location);
        CGFloat w = ceil(lWidth);
        
        CGRect frame = CGRectMake(x, 0, w, size.height);
        
        SWUtilityView *utilityView = [views objectAtIndex:i];
        [utilityView setFrame:frame];
    }
}


- (void)_buttonTouchUpAction:(SWUtilityButton*)button
{
    SWCellButtonItem *item = button.item;
    void (^handler)(SWCellButtonItem*,SWRevealTableViewCell*) = item.handler;
    
    if ( handler )
        handler( item, _c );
}

@end


#pragma mark - UIActionSheetExtension

@implementation UIActionSheet(SWCellButtonItem)

- (void)showFromCellButtonItem:(SWCellButtonItem *)item animated:(BOOL)animated
{
    SWUtilityContentView *utilityView = item.view;
    CGRect frame = [utilityView referenceFrameForCellButtonItem:item];
    
    [self showFromRect:frame inView:utilityView animated:animated];
}

@end


#pragma mark - SWDirectionPanGestureRecognizer

@interface SWRevealTableViewCellPanGestureRecognizer : UIPanGestureRecognizer
@end


@implementation SWRevealTableViewCellPanGestureRecognizer
{
    BOOL _dragging;
    CGPoint _beginPoint;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
   
    UITouch *touch = [touches anyObject];
    _beginPoint = [touch locationInView:self.view];
    _dragging = NO;
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    if ( _dragging || self.state == UIGestureRecognizerStateFailed)
        return;
    
    const int kDirectionPanThreshold = 5;
    
    UITouch *touch = [touches anyObject];
    CGPoint nowPoint = [touch locationInView:self.view];
    
    if (abs(nowPoint.x - _beginPoint.x) > kDirectionPanThreshold) _dragging = YES;
    else if (abs(nowPoint.y - _beginPoint.y) > kDirectionPanThreshold) self.state = UIGestureRecognizerStateFailed;
}

@end


#pragma mark - SWrevealTableViewCell

@interface SWRevealTableViewCell ()<UIGestureRecognizerDelegate>
{
    UIPanGestureRecognizer *_panGestureRecognizer;
    SWUtilityContentView *_utilityContentView;
    SWCellRevealPosition _frontViewPosition;
    SWCellRevealPosition _leftViewPosition;
    SWCellRevealPosition _rightViewPosition;
    SWCellRevealPosition _panInitialFrontPosition;
}

@end


@implementation SWRevealTableViewCell
{
    NSMutableArray *_animationQueue;
    CGFloat _revealLocation;
    __weak UIView *_revealLayoutView;
}

const NSInteger SWCellRevealPositionNone = 0xff;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self _customInit];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self _customInit];
    }
    return self;
}


- (void)_customInit
{
    [self _initProperties];
    [self _initSubViews];
}


- (void)_initProperties
{
    _frontViewPosition = SWCellRevealPositionCenter;
    _leftViewPosition = SWCellRevealPositionCenter;
    _rightViewPosition = SWCellRevealPositionCenter;
    _quickFlickVelocity = 150.0f;
    _revealAnimationDuration = 0.5;
    _bounceBackOnRightOverdraw = YES;
    _bounceBackOnLeftOverdraw = YES;
    _rightCascadeReversed = NO;
    _leftCascadeReversed = NO;
    _animationQueue = [NSMutableArray array];
}


- (void)_initSubViews
{
    _panGestureRecognizer = [[SWRevealTableViewCellPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handleRevealGesture:)];
    _panGestureRecognizer.delegate = self;
    
    UIView *contentView = self.contentView;
    [contentView addGestureRecognizer:_panGestureRecognizer];
}


#pragma mark - Overrides

-(void)prepareForReuse
{
    [super prepareForReuse];
    
    // By default we disable rear buttons when the cell is reused.
    // Developers can reverse this by explicitly setting position in their cellForRowAtIndexPath or willDisplay methods
    [self resetCellAnimated:NO];
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    if ( !_allowsRevealInEditMode && editing )
        [self resetCellAnimated:animated];
}


#pragma mark - Life cycle

- (void)didMoveToWindow
{
    [super didMoveToWindow];

    if ( self.window )
    {
        // We pick the cell contentView's superview to perform our layout magic.
        // On iOS7 this used to be a UIScrollView, which was handy, but it is no longer the case on iOS8.
        // In case the contentOffset methods on the revealScrollView are not available we will perform our layout manualy.
        // See _setRevealLocation: implementation
        _revealLayoutView = (id)[self.contentView superview];
        
        // Create a view to hold our custom utility views and insert it into the cell hierarchy
        _utilityContentView = [[SWUtilityContentView alloc] initWithRevealTableViewCell:self frame:self.bounds];
        [_utilityContentView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [_revealLayoutView insertSubview:_utilityContentView atIndex:0];
    
        // Force the initial reveal position to the developer provided value
        SWCellRevealPosition initialPosition = _frontViewPosition;
        _frontViewPosition = SWCellRevealPositionNone;
        _leftViewPosition = SWCellRevealPositionNone;
        _rightViewPosition = SWCellRevealPositionNone;
        
        // Finally, set the actual position
        [self _setRevealPosition:initialPosition withDuration:0.0];
    }
    else
    {
        [_utilityContentView resetButtonItems];  // this will prevent retain cycles
    }
}


#pragma mark - Properties

- (NSArray *)rightCellButtonItems
{
    return _utilityContentView.rightButtonItems;
}


- (NSArray *)leftCellButtonItems
{
    return _utilityContentView.leftButtonItems;
}


- (void)setRevealPosition:(SWCellRevealPosition)revealPosition
{
    [self setRevealPosition:revealPosition animated:NO];
}


- (void)setRevealPosition:(SWCellRevealPosition)revealPosition animated:(BOOL)animated
{
    if ( ![self window] )
    {
        _frontViewPosition = revealPosition;
        _leftViewPosition = revealPosition;
        _rightViewPosition = revealPosition;
        return;
    }
    
    [self _dispatchSetRevealPosition:revealPosition animated:animated];
}


- (void)resetCellAnimated:(BOOL)animated
{
    [self setRevealPosition:SWCellRevealPositionCenter animated:animated];
}


- (void)setAllowsRevealInEditMode:(BOOL)allowsRevealInEditMode
{
    _allowsRevealInEditMode = allowsRevealInEditMode;
    if ( !_allowsRevealInEditMode && self.editing )
        [self resetCellAnimated:NO];
}


#pragma mark - Reveal Location

- (void)_setRevealLocation:(CGFloat)xLocation
{
    // set the new reveal location
    _revealLocation = xLocation;
    
    // compensate our utilityContentView for cell layout comming next.
    CGRect utilityFrame = self.bounds;
    utilityFrame.size.height -= 0.5;
    utilityFrame.origin.x = -xLocation;
    [_utilityContentView setFrame:utilityFrame];
    
    if ( [_revealLayoutView respondsToSelector:@selector(setContentOffset:)] )
    {
        // We have an underlying UIScrollView supporting our views (iOS7). We just set its contentOfset,
        // Apple implementation takes care of all the required layout code.
        [(UIScrollView*)_revealLayoutView setContentOffset:CGPointMake(-xLocation,0)];
    }

    else
    {
        // Ok, so no underlying scrollView for our layout needs :-( (iOS8).
        // We must explicitly offset the cell contentView and its siblings to create our custom layout.
        // We first call super layoutSubviews to get base cell subview frames from Apple implementation.
        [super layoutSubviews];
        
        // Now we apply our custom layout offset
        for ( UIView *view in _revealLayoutView.subviews )
        {
            // One of the siblings of the cell contentView is the cell's separatorView.
            // We do not want to apply our custom layout offseting to that particular view, so we skip that view based on its class name.
            // This is of course hacky and may break in the future. However since we choose to apply our layout directly to the cell, as oposed to
            // the cell's contentView we do not have other choice than filtering this here.
            // If this code breaks on a future iOS release it will be very easy to fix anyway.
            {
                if ( [NSStringFromClass([view class]) rangeOfString:@"Separator"].length > 0 )
                    continue;
            }
            
            view.frame = CGRectOffset(view.frame, xLocation, 0 );
        }
    }
}


#pragma mark - Button Items

- (NSArray*)_getLeftButtonItems
{
    NSArray *leftItems = nil;
    
    if ( _dataSource )
        leftItems = [self _preparedItems:[_dataSource leftButtonItemsInRevealTableViewCell:self]];
        
    // we will return nil if dataSource has not been set yet, some array (maybe empty) otherwise
    // once we got an array the data source is never asked again
    return leftItems;
}


- (NSArray*)_getRightButtonItems
{
    NSArray *rightItems = nil;
    
    if ( _dataSource )
        rightItems = [self _preparedItems:[_dataSource rightButtonItemsInRevealTableViewCell:self]];

    // we will return nil if dataSource has not been set yet, some array (maybe empty) otherwise
    // once we got an array the data source is never asked again
    return rightItems;
}


- (NSArray*)_preparedItems:(NSArray*)itemsArray
{
    for ( SWCellButtonItem *item in itemsArray )
        item.view = _utilityContentView;
    
    return [itemsArray copy];
}


#pragma mark - Symmetry

- (void)_getAdjustedRevealPosition:(SWCellRevealPosition*)revealPosition forSymmetry:(int)symmetry
{
    if ( symmetry < 0 )
        *revealPosition = SWCellRevealPositionCenter + symmetry*(*revealPosition-SWCellRevealPositionCenter);
}


- (void)_getDragLocation:(CGFloat*)xLocation progress:(CGFloat*)progress
{
    *xLocation = _revealLocation;
    int symmetry = *xLocation<0 ? -1 : 1;
    CGFloat xWidth = symmetry < 0 ? [_utilityContentView rightRevealWidth] : [_utilityContentView leftRevealWidth];
    *progress = *xLocation/xWidth * symmetry;
}


#pragma mark - PanGesture progress notification

- (void)_notifyPanGestureBegan
{
    if ( [_delegate respondsToSelector:@selector(revealTableViewCellPanGestureBegan:)] )
        [_delegate revealTableViewCellPanGestureBegan:self];
    
    CGFloat xLocation, dragProgress;
    [self _getDragLocation:&xLocation progress:&dragProgress];

    if ( [_delegate respondsToSelector:@selector(revealTableViewCell:panGestureBeganFromLocation:progress:)] )
        [_delegate revealTableViewCell:self panGestureBeganFromLocation:xLocation progress:dragProgress];
}


- (void)_notifyPanGestureMoved
{
    CGFloat xLocation, dragProgress;
    [self _getDragLocation:&xLocation progress:&dragProgress];
    
    if ( [_delegate respondsToSelector:@selector(revealTableViewCell:panGestureMovedToLocation:progress:)] )
        [_delegate revealTableViewCell:self panGestureMovedToLocation:xLocation progress:dragProgress];
}


- (void)_notifyPanGestureEnded
{
    CGFloat xLocation, dragProgress;
    [self _getDragLocation:&xLocation progress:&dragProgress];
    
    if ( [_delegate respondsToSelector:@selector(revealTableViewCell:panGestureEndedToLocation:progress:)] )
        [_delegate revealTableViewCell:self panGestureEndedToLocation:xLocation progress:dragProgress];
    
    if ( [_delegate respondsToSelector:@selector(revealTableViewCellPanGestureEnded:)] )
        [_delegate revealTableViewCellPanGestureEnded:self];
}


#pragma mark - Deferred block execution queue

// Define a convenience macro to enqueue single statements
#define _enqueue(code) [self _enqueueBlock:^{code;}];

// Defers the execution of the passed in block until a paired _dequeue call is received,
// or executes the block right away if no pending requests are present.
- (void)_enqueueBlock:(void (^)(void))block
{
    [_animationQueue insertObject:block atIndex:0];
    if ( _animationQueue.count == 1)
    {
        block();
    }
}

// Removes the top most block in the queue and executes the following one if any.
// Calls to this method must be paired with calls to _enqueueBlock, particularly it may be called
// from within a block passed to _enqueueBlock to remove itself when done with animations.  
- (void)_dequeue
{
    [_animationQueue removeLastObject];

    if ( _animationQueue.count > 0 )
    {
        void (^block)(void) = [_animationQueue lastObject];
        block();
    }
}


#pragma mark - Enqueued position and controller setup

- (void)_dispatchSetRevealPosition:(SWCellRevealPosition)revealPosition animated:(BOOL)animated
{
    NSTimeInterval duration = animated ? _revealAnimationDuration : 0.0;
    __weak SWRevealTableViewCell *theSelf = self;
    _enqueue( [theSelf _setRevealPosition:revealPosition withDuration:duration] );
}


#pragma mark - Utility views deployment and layout

// Primitive method for view controller deployment and animated layout to the given position.
- (void)_setRevealPosition:(SWCellRevealPosition)newPosition withDuration:(NSTimeInterval)duration
{
    void (^frontDeploymentCompletion)() = [self _frontDeploymentForNewRevealPosition:newPosition];
    void (^leftDeploymentCompletion)() = [self _leftDeploymentForNewRevealPosition:newPosition];
    void (^rightDeploymentCompletion)() = [self _rightDeploymentForNewRevealPosition:newPosition];
    
    void (^animations)() = ^()
    {
        // We layout the views and call the delegate, which will
        // occur inside of an animation block if any animated transition is being performed
        
        CGFloat xLocation = [_utilityContentView frontLocationForPosition:_frontViewPosition];
        [self layoutForLocation:xLocation];
    
        if ([_delegate respondsToSelector:@selector(revealTableViewCell:animateToPosition:)])
            [_delegate revealTableViewCell:self animateToPosition:_frontViewPosition];
    };
    
    void (^completion)(BOOL) = ^(BOOL finished)
    {
        leftDeploymentCompletion();
        rightDeploymentCompletion();
        frontDeploymentCompletion();
        
        // next time we want to get items from the datasource, so we may reset current items now
        if ( newPosition == SWCellRevealPositionCenter )
            [_utilityContentView resetButtonItems];
        
        [self _dequeue];
    };
    
    if ( duration > 0.0f )
    {
//        [UIView animateWithDuration:duration delay:0.0
//        options:UIViewAnimationOptionCurveEaseOut animations:animations completion:completion];
        
        [UIView animateWithDuration:_revealAnimationDuration delay:0 usingSpringWithDamping:1 initialSpringVelocity:1/duration
        options:0 animations:animations completion:completion];
    }
    else
    {
        animations();
        completion(YES);
    }
}

// Deploy/Undeploy of the front view controller following the containment principles. Returns a block
// that must be invoked on animation completion in order to finish deployment
- (void (^)(void))_frontDeploymentForNewRevealPosition:(SWCellRevealPosition)newPosition
{
    if ( ( newPosition < SWCellRevealPositionCenter && _utilityContentView.rightCount==0 ) ||
         ( newPosition > SWCellRevealPositionCenter && _utilityContentView.leftCount==0) )
        newPosition = SWCellRevealPositionCenter;
    
    if ( !_allowsRevealInEditMode && self.editing )
        newPosition = SWCellRevealPositionCenter;
    
    BOOL positionIsChanging = (_frontViewPosition != newPosition);
    
    if ( positionIsChanging )
    {
        if ( [_delegate respondsToSelector:@selector(revealTableViewCell:willMoveToPosition:)] )
            [_delegate revealTableViewCell:self willMoveToPosition:newPosition];
    }
    
    _frontViewPosition = newPosition;
    
    void (^completion)() = ^()
    {
        if ( positionIsChanging )
        {
            if ( [_delegate respondsToSelector:@selector(revealTableViewCell:didMoveToPosition:)] )
                [_delegate revealTableViewCell:self didMoveToPosition:newPosition];
        }
    };

    return completion;
}

// Deploy/Undeploy of the left view controller following the containment principles. Returns a block
// that must be invoked on animation completion in order to finish deployment
- (void (^)(void))_leftDeploymentForNewRevealPosition:(SWCellRevealPosition)newPosition
{

    if ( newPosition > SWCellRevealPositionCenter && _utilityContentView.leftCount==0 )
        newPosition = SWCellRevealPositionCenter;
    
    if ( !_allowsRevealInEditMode && self.editing )
        newPosition = SWCellRevealPositionCenter;

    BOOL appear = (_leftViewPosition <= SWCellRevealPositionCenter || _leftViewPosition == SWCellRevealPositionNone) && newPosition > SWCellRevealPositionCenter;
    BOOL disappear = (newPosition <= SWCellRevealPositionCenter || newPosition == SWCellRevealPositionNone) && _leftViewPosition > SWCellRevealPositionCenter;
    
    if ( appear )
        [_revealLayoutView insertSubview:_utilityContentView atIndex:0];
    
    _leftViewPosition = newPosition;
    
    return [self _deploymentForLeftItemsWithAppear:appear disappear:disappear];
}

// Deploy/Undeploy of the right view controller following the containment principles. Returns a block
// that must be invoked on animation completion in order to finish deployment
- (void (^)(void))_rightDeploymentForNewRevealPosition:(SWCellRevealPosition)newPosition
{
    if ( newPosition < SWCellRevealPositionCenter && _utilityContentView.rightCount==0)
        newPosition = SWCellRevealPositionCenter;
    
    if ( !_allowsRevealInEditMode && self.editing )
        newPosition = SWCellRevealPositionCenter;

    BOOL appear = _rightViewPosition >= SWCellRevealPositionCenter && newPosition < SWCellRevealPositionCenter ;
    BOOL disappear = newPosition >= SWCellRevealPositionCenter && _rightViewPosition < SWCellRevealPositionCenter;
    
    if ( appear )
        [_revealLayoutView insertSubview:_utilityContentView atIndex:0];
    
    _rightViewPosition = newPosition;
    
    return [self _deploymentForRightItemsWithAppear:appear disappear:disappear];
}


- (void (^)(void))_deploymentForRightItemsWithAppear:(BOOL)appear disappear:(BOOL)disappear
{
    if ( appear ) [_utilityContentView deployRightItems];
    if ( disappear ) return ^{ [_utilityContentView undeployRightItems]; };
    return ^{};
}


- (void (^)(void))_deploymentForLeftItemsWithAppear:(BOOL)appear disappear:(BOOL)disappear
{
    if ( appear ) [_utilityContentView deployLeftItems];
    if ( disappear ) return ^{ [_utilityContentView undeployLeftItems]; };
    return ^{};
}


#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutForLocation:_revealLocation];
}


- (void)layoutForLocation:(CGFloat)xLocation
{
    // layout utilityContentView now
    [_utilityContentView layoutForLocation:xLocation];

    // compute offset damper
    CGFloat maxLocation = xLocation<0 ? -[_utilityContentView rightRevealWidth] : [_utilityContentView leftRevealWidth];
    if ( abs(xLocation) > abs(maxLocation) )
    {
        CGFloat damperWidth = xLocation<0 ? -80 : 80;
        CGFloat overdraw = xLocation-maxLocation;
        xLocation = maxLocation + (overdraw*damperWidth)/(overdraw+damperWidth) ;
        xLocation = 0.5*round(2*xLocation);  // round to nearest halph point, good for retina
    }
    
//    // before setting our custom layout we call super layoutSubviews to get cell subview frames to the system values
//    [super layoutSubviews];
    
    // now we update frames according to our required offset
    [self _setRevealLocation:xLocation];
}


#pragma mark - Gesture recognizer delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)recognizer
{
    // only allow gesture if no previous programmatic request is in process
    if ( _animationQueue.count == 0 )
    {
        if ( recognizer == _panGestureRecognizer )
            return [self _panGestureShouldBegin];
    }

    return NO;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ( gestureRecognizer == _panGestureRecognizer )
    {
        if ( [_delegate respondsToSelector:@selector(revealTableViewCell:panGestureRecognizerShouldRecognizeSimultaneouslyWithGestureRecognizer:)] )
            if ( [_delegate revealTableViewCell:self panGestureRecognizerShouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer] == YES )
                return YES;
    }
    
    return NO;
}


- (BOOL)_panGestureShouldBegin
{
    // forbid gesture in edit mode if requested
    if ( !_allowsRevealInEditMode && self.editing )
        return NO;
    
    // forbid gesture if the initial translation is not horizontal
    UIView *recognizerView = _panGestureRecognizer.view;
//    CGPoint translation = [_panGestureRecognizer translationInView:recognizerView];
//    NSLog( @"translation:%@", NSStringFromCGPoint(translation) );
//    if ( fabs(translation.y/translation.x) > 1 )
//        return NO;
    
    // forbid gesture if the following delegate is implemented and returns NO
    if ( [_delegate respondsToSelector:@selector(revealTableViewCellPanGestureShouldBegin:)] )
        if ( [_delegate revealTableViewCellPanGestureShouldBegin:self] == NO )
            return NO;

    CGFloat xLocation = [_panGestureRecognizer locationInView:recognizerView].x;
    CGFloat width = recognizerView.bounds.size.width;
    
    BOOL draggableBorderAllowing = (
         _frontViewPosition != SWCellRevealPositionCenter || _draggableBorderWidth == 0.0f ||
         (xLocation <= _draggableBorderWidth && _utilityContentView.leftCount>0) ||
         (xLocation >= (width - _draggableBorderWidth) && _utilityContentView.rightCount>0) );
    
    // allow gesture only within the bounds defined by the draggableBorderWidth property
    return draggableBorderAllowing ;
}


#pragma mark - Gesture Based Reveal

- (void)_handleRevealGesture:(UIPanGestureRecognizer *)recognizer
{
    switch ( recognizer.state )
    {
        case UIGestureRecognizerStateBegan:
            [self _handleRevealGestureStateBeganWithRecognizer:recognizer];
            break;
            
        case UIGestureRecognizerStateChanged:
            [self _handleRevealGestureStateChangedWithRecognizer:recognizer];
            break;
            
        case UIGestureRecognizerStateEnded:
            [self _handleRevealGestureStateEndedWithRecognizer:recognizer];
            break;
            
        case UIGestureRecognizerStateCancelled:
        //case UIGestureRecognizerStateFailed:
            [self _handleRevealGestureStateCancelledWithRecognizer:recognizer];
            break;
            
        default:
            break;
    }
}


- (void)_handleRevealGestureStateBeganWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    // we know that we will not get here unless the animationQueue is empty because the recognizer
    // delegate prevents it, however we do not want any forthcoming programatic actions to disturb
    // the gesture, so we just enqueue a dummy block to ensure any simultaneous programatic actions will be
    // scheduled after the gesture is completed
    [self _enqueueBlock:^{}]; // <-- dummy block

    // we store the initial position and initialize a target position
    _panInitialFrontPosition = _frontViewPosition;

    // notify delegate
    [self _notifyPanGestureBegan];
}


- (void)_handleRevealGestureStateChangedWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    CGFloat translation = [recognizer translationInView:self].x;
    
    CGFloat baseLocation = [_utilityContentView frontLocationForPosition:_panInitialFrontPosition];
    CGFloat xLocation = baseLocation + translation;
    
    if ( xLocation < 0 )
    {
        if ( _utilityContentView.rightCount == 0 ) xLocation = 0;
        //[self _frontDeploymentForNewRevealPosition:SWCellRevealPositionLeft]();
        [self _leftDeploymentForNewRevealPosition:SWCellRevealPositionLeft]();
        [self _rightDeploymentForNewRevealPosition:SWCellRevealPositionLeft]();
    }
    
    if ( xLocation > 0 )
    {
        if ( _utilityContentView.leftCount == 0 ) xLocation = 0;
        //[self _frontDeploymentForNewRevealPosition:SWCellRevealPositionRight]();
        [self _rightDeploymentForNewRevealPosition:SWCellRevealPositionRight]();
        [self _leftDeploymentForNewRevealPosition:SWCellRevealPositionRight]();
    }
    
    [self layoutForLocation:xLocation];
    [self _notifyPanGestureMoved];
}


- (void)_handleRevealGestureStateEndedWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    CGFloat xLocation = _revealLocation;
    CGFloat velocity = [recognizer velocityInView:self].x;
    //NSLog( @"Velocity:%1.4f", velocity);
    
    // depending on position we compute a simetric replacement of widths and positions
    int symmetry = xLocation<0 ? -1 : 1;
    
    // symmetric computing of widths
    CGFloat revealWidth = symmetry<0 ? [_utilityContentView rightRevealWidth] : [_utilityContentView leftRevealWidth];
    BOOL bounceBack = symmetry<0 ? _bounceBackOnRightOverdraw : _bounceBackOnLeftOverdraw;
  
    // symmetric replacement of location
    xLocation = xLocation * symmetry;
    
    // initially we assume drag to left and default duration
    SWCellRevealPosition revealPosition = SWCellRevealPositionCenter;
    NSTimeInterval duration = _revealAnimationDuration;

    // Velocity driven change:
    if (fabsf(velocity) > _quickFlickVelocity)
    {
        // we may need to set the drag position and to adjust the animation duration
        CGFloat journey = xLocation;
        if (velocity*symmetry > 0.0f)
        {
            revealPosition = SWCellRevealPositionRight;
            journey = revealWidth - xLocation;
            if (xLocation > revealWidth)
            {
                if (!bounceBack )
                {
                    revealPosition = SWCellRevealPositionRight;
                    journey = revealWidth - xLocation;
                }
            }
        }
        
        duration = fabsf(journey/velocity);
    }
    
    // Position driven change:
    else
    {    
        // we may need to set the drag position        
        if (xLocation > revealWidth*0.5f)
        {
            revealPosition = SWCellRevealPositionRight;
            if (xLocation > revealWidth)
            {
                if (bounceBack)
                    revealPosition = SWCellRevealPositionCenter;
            }
        }
    }

    // symetric replacement of frontViewPosition
    [self _getAdjustedRevealPosition:&revealPosition forSymmetry:symmetry];
    
    // Animate to the final position
    [self _notifyPanGestureEnded];
    [self _setRevealPosition:revealPosition withDuration:duration];
}


- (void)_handleRevealGestureStateCancelledWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    [self _notifyPanGestureEnded];
    [self _dequeue];
}

@end


//@interface UIView(subvistes)
//@end
//
//@implementation UIView(subvistes)
//
//- (void)lesSubvistesAmbNivell:(int)nivell
//{
//    NSMutableString *espai = [NSMutableString string];
//    for ( int i=0 ; i<nivell ; i++ ) [espai appendString:@"--"];
//    NSLog( @"%@%03d %@ <%0lx>", espai, nivell, NSStringFromClass([self class]), (unsigned long)self );
//    for ( UIView *subvista in self.subviews )
//    {
//        [subvista lesSubvistesAmbNivell:nivell+1];
//    }
//}
//
//@end