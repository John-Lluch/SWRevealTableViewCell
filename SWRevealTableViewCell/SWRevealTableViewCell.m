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

#import "SWRevealTableViewCell.h"

#pragma mark - SWCellButton Item

@interface SWCellButtonItem()
@property(nonatomic,strong) void (^handler)(SWCellButtonItem *, SWRevealTableViewCell*);
@end

@implementation SWCellButtonItem
@synthesize image = _image;
@synthesize title = _title;

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
@property (nonatomic) SWCellRevealPosition position;
@property (nonatomic) NSInteger index;
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
    NSMutableArray *_rightViews;
    NSMutableArray *_leftViews;
    __weak SWRevealTableViewCell *_c;
}

@property (nonatomic) NSArray *leftButtonItems;
@property (nonatomic) NSArray *rightButtonItems;

- (CGFloat)leftRevealWidth;
- (CGFloat)rightRevealWidth;
- (NSInteger)leftCount;
- (NSInteger)rightCount;

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
    [self prepareRightButtonItems];
    return _leftButtonItems.count;
}


- (NSInteger)rightCount
{
    [self prepareLeftButtonItems];
    return _rightButtonItems.count;
}


- (void)prepareLeftButtonItems
{
    if ( _leftButtonItems == nil )
        _leftButtonItems = [_c _getLeftButtonItems];
}


- (void)prepareRightButtonItems
{
    if ( _rightButtonItems == nil )
        _rightButtonItems = [_c _getRightButtonItems];
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


- (void)_deployItemsForNewPosition:(SWCellRevealPosition)newPosition
{
    NSArray *items = newPosition<SWCellRevealPositionCenter ? _leftButtonItems : _rightButtonItems;
    NSMutableArray * __strong* views =  newPosition<SWCellRevealPositionCenter ? &_leftViews : &_rightViews;
    UIViewAutoresizing mask = UIViewAutoresizingFlexibleHeight |
        (newPosition<SWCellRevealPositionCenter ? UIViewAutoresizingFlexibleRightMargin: UIViewAutoresizingFlexibleLeftMargin);

    if ( items.count == 0 )
        return;
    
    *views = [NSMutableArray array];
    
    NSInteger count = items.count;
    for ( NSInteger i=0 ; i<count ; i++ )
    {
        // get the button item
        SWCellButtonItem *item = [items objectAtIndex:i];
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
        button.position = newPosition;
        button.index = i;
        
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
            //[button setBackgroundColor:color];
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
        
        [self insertSubview:utilityView atIndex:0];
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
        SWUtilityView *utilityView = [views objectAtIndex:i];
        SWCellButtonItem *item = [items objectAtIndex:i];
        
        CGFloat width = item.width;
        endLocation += width*symmetry;
        
        CGFloat lWidth = width*xLocation/maxLocation;
        CGFloat location =  xLocation*(endLocation/maxLocation);
        
        CGFloat xReference = symmetry<0 ? size.width+0 : 0-lWidth;

// This works better on iOS8
//        CGFloat x = 0.5*floor(2*(xReference+location));
//        CGFloat w = 0.5*ceil(2*lWidth);
        
        CGFloat x = floor(xReference+location);
        CGFloat w = ceil(lWidth);
        
        CGRect frame = CGRectMake(x, 0, w, size.height);
        [utilityView setFrame:frame];
    }
}


- (void)_buttonTouchUpAction:(SWUtilityButton*)button
{
    NSArray *items = button.position<SWCellRevealPositionCenter ? _leftButtonItems : _rightButtonItems;
    SWCellButtonItem *item = [items objectAtIndex:button.index];
    
    void (^handler)(SWCellButtonItem *, SWRevealTableViewCell*) = item.handler;
    if ( handler )
        handler( item, _c );
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
    __weak UIView *_revealScrollView;
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
    _revealAnimationDuration = 0.25;
    _animationQueue = [NSMutableArray array];
}


- (void)_initSubViews
{
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handleRevealGesture:)];
    _panGestureRecognizer.delegate = self;
    
    UIView *contentView = self.contentView;
    [contentView addGestureRecognizer:_panGestureRecognizer];
}


-(void)prepareForReuse
{
    [super prepareForReuse];
    
    // By default we disable rear buttons when the cell is reused.
    // Developers can reverse this by explicitly setting position in their cellForRowAtIndexPath or willDisplay methods
    [self setRevealPosition:SWCellRevealPositionCenter];
    [_utilityContentView setRightButtonItems:nil];
    [_utilityContentView setLeftButtonItems:nil];
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
        _revealScrollView = (id)[self.contentView superview];
        
        // Create a view to hold our custom utility views and insert it into the cell hierarchy
        _utilityContentView = [[SWUtilityContentView alloc] initWithRevealTableViewCell:self frame:self.bounds];
        [_utilityContentView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [_revealScrollView insertSubview:_utilityContentView atIndex:0];
    
        // Force the initial reveal position to the developer provided value
        SWCellRevealPosition initialPosition = _frontViewPosition;
        _frontViewPosition = SWCellRevealPositionNone;
        _leftViewPosition = SWCellRevealPositionNone;
        _rightViewPosition = SWCellRevealPositionNone;
        
        // Finally, set the actual position
        [self _setRevealPosition:initialPosition withDuration:0.0];
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
    
    if ( [_revealScrollView respondsToSelector:@selector(setContentOffset:)] )
    {
        // Ok, so we have an underlying UIScrollView supporting our views (iOS7). We just set its contentOfset,
        // Apple implementation takes care of all the required layout code.
        [(UIScrollView*)_revealScrollView setContentOffset:CGPointMake(-xLocation,0)];
    }

    else
    {
        // No underlying scrollView for our layout needs (iOS8).
        // So we must explicitly offset the cell contentView and its siblings to create our custom layout.
        for ( UIView *view in _revealScrollView.subviews )
        {
            // One of the siblings of the cell contentView is the cell's separatorView.
            // We do not want to apply our custom offseting layout on that particular view, so we skip that view based on its class name.
            // This of course a hack that may break in the future, but we decided to lay all the cell views instead of implementing our thing only
            // on top of the cell contentView view, which would not support cells with accessory views.
            // If this code breaks on a future iOS release it should be very easy to fix anyway.
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
    {
        leftItems = [_dataSource leftButtonItemsInRevealTableViewCell:self];
        if ( leftItems == nil ) leftItems = @[];
    }

    // will return nil if dataSource has not been set yet, some array otherwise
    // once we got an array the data source is never asked again
    return leftItems;
}


- (NSArray*)_getRightButtonItems
{
    NSArray *rightItems = nil;
    
    if ( _dataSource )
    {
        rightItems = [_dataSource rightButtonItemsInRevealTableViewCell:self];
        if ( rightItems == nil ) rightItems = @[];
    }

    // will return nil if dataSource has not been set yet, some array otherwise
    // once we got an array the data source is never asked again
    return rightItems;
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
        [self _dequeue];
    };
    
    if ( duration > 0.0f )
    {
//        [UIView animateWithDuration:duration delay:0.0
//        options:UIViewAnimationOptionCurveEaseOut animations:animations completion:completion];
        
        [UIView animateWithDuration:_revealAnimationDuration delay:0 usingSpringWithDamping:0.65 initialSpringVelocity:1/duration
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
    if ( (_utilityContentView.rightCount==0  && newPosition < SWCellRevealPositionCenter) ||
         (_utilityContentView.leftCount==0 && newPosition > SWCellRevealPositionCenter) )
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

    if ( _utilityContentView.leftCount==0 && newPosition > SWCellRevealPositionCenter )
        newPosition = SWCellRevealPositionCenter;

    BOOL appear = (_leftViewPosition <= SWCellRevealPositionCenter || _leftViewPosition == SWCellRevealPositionNone) && newPosition > SWCellRevealPositionCenter;
    BOOL disappear = (newPosition <= SWCellRevealPositionCenter || newPosition == SWCellRevealPositionNone) && _leftViewPosition > SWCellRevealPositionCenter;
    
    if ( appear )
    {
        [_utilityContentView prepareLeftButtonItems];
        [_revealScrollView insertSubview:_utilityContentView atIndex:0];
    }
    
    _leftViewPosition = newPosition;
    
    return [self _deploymentForLeftItemsWithAppear:appear disappear:disappear];
}

// Deploy/Undeploy of the right view controller following the containment principles. Returns a block
// that must be invoked on animation completion in order to finish deployment
- (void (^)(void))_rightDeploymentForNewRevealPosition:(SWCellRevealPosition)newPosition
{
    if ( _utilityContentView.rightCount==0 && newPosition < SWCellRevealPositionCenter )
        newPosition = SWCellRevealPositionCenter;

    BOOL appear = _rightViewPosition >= SWCellRevealPositionCenter && newPosition < SWCellRevealPositionCenter ;
    BOOL disappear = newPosition >= SWCellRevealPositionCenter && _rightViewPosition < SWCellRevealPositionCenter;
    
    if ( appear )
    {
        [_utilityContentView prepareRightButtonItems];
        [_revealScrollView insertSubview:_utilityContentView atIndex:0];
    }
    
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
    [self layoutForLocation:_revealLocation];  // <-- will call super layoutSubviews
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
    
    // before setting our custom layout we call super layoutSubviews to get cell subview frames to the system values
    [super layoutSubviews];
    
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
    // forbid gesture if the initial translation is not horizontal
    UIView *recognizerView = _panGestureRecognizer.view;
    CGPoint translation = [_panGestureRecognizer translationInView:recognizerView];
    if ( fabs(translation.y/translation.x) > 1 )
        return NO;
    
    // forbid gesture if the following delegate is implemented and returns NO
    if ( [_delegate respondsToSelector:@selector(revealTableViewCellPanGestureShouldBegin:)] )
        if ( [_delegate revealTableViewCellPanGestureShouldBegin:self] == NO )
            return NO;

    CGFloat xLocation = [_panGestureRecognizer locationInView:recognizerView].x;
    CGFloat width = recognizerView.bounds.size.width;
    
    BOOL draggableBorderAllowing = (
         _frontViewPosition != SWCellRevealPositionCenter || _draggableBorderWidth == 0.0f ||
         (_utilityContentView.leftCount>0 && xLocation <= _draggableBorderWidth) ||
         (_utilityContentView.rightCount>0 && xLocation >= (width - _draggableBorderWidth)) );

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
        [self _frontDeploymentForNewRevealPosition:SWCellRevealPositionLeft]();
        [self _leftDeploymentForNewRevealPosition:SWCellRevealPositionLeft]();
        [self _rightDeploymentForNewRevealPosition:SWCellRevealPositionLeft]();
    }
    
    if ( xLocation > 0 )
    {
        if ( _utilityContentView.leftCount == 0 ) xLocation = 0;
        [self _frontDeploymentForNewRevealPosition:SWCellRevealPositionRight]();
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
    BOOL bounceBack = symmetry<0 ? _bounceBackOnOverdraw : _bounceBackOnLeftOverdraw;
  
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


//@interface UIView(subi)
//@end
//
//@implementation UIView(subi)
//
//- (void)lesSubvistesAmbNivell:(int)nivell
//{
//    NSMutableString *espai = [NSMutableString string];
//    for ( int i=0 ; i<nivell ; i++ ) [espai appendString:@"--"];
//    NSLog( @"%@%03d %@ <%0lx>", espai, nivell, NSStringFromClass([self class]), (unsigned long)self );
//    for ( UIView *sub in self.subviews )
//    {
//        [sub lesSubvistesAmbNivell:nivell+1];
//    }
//}
//
//@end