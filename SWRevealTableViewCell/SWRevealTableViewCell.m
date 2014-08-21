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


#pragma mark - Helper functions

static CGFloat Scale(void)
{
    static CGFloat scale = 0;
    static dispatch_once_t onceToken;
    dispatch_once( &onceToken, ^
    {
        scale = [[UIScreen mainScreen] scale];
    });
    
    return scale;
}


static UIImage* _imageWithColor_size(UIColor* color, CGSize size)
{
    CGFloat scale = Scale();
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


#pragma mark - SWRevealTableViewCell(Internal)

@interface SWRevealTableViewCell(Internal)
- (void)_getAdjustedRevealPosition:(SWCellRevealPosition*)revealPosition forSymmetry:(CGFloat)symmetry;
- (NSArray*)_getLeftButtonItems;
- (NSArray*)_getRightButtonItems;
- (void)_didTapButtonAtIndex:(NSInteger)indx position:(SWCellRevealPosition)position;
@end


#pragma mark - SWCellButton Item

@class SWUtilityContentView;

@interface SWCellButtonItem()
@property(nonatomic,strong) BOOL (^handler)(SWCellButtonItem *, SWRevealTableViewCell*);
@property(nonatomic,assign) SWUtilityContentView *view;  // Note that we do not retain this
@property(nonatomic,readonly) BOOL isOpaque;
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


- (instancetype)initWithTitle:(NSString *)title image:(UIImage*)image handler:(BOOL(^)(SWCellButtonItem *, SWRevealTableViewCell* cell))handler;
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


- (void)setBackgroundColor:(UIColor *)color
{
    CGFloat c1,c2,c3;
    CGFloat alpha = 0;
    BOOL ok = [color getRed:&c1 green:&c2 blue:&c3 alpha:&alpha];
    ok = ok || [color getHue:&c1 saturation:&c2 brightness:&c3 alpha:&alpha];
    ok = ok || [color getWhite:&c1 alpha:&alpha];
    _isOpaque = alpha > 0.98;
    _backgroundColor = color;
}


+ (instancetype)itemWithTitle:(NSString *)title handler:(BOOL(^)(SWCellButtonItem *, SWRevealTableViewCell *))handler
{
    return [[SWCellButtonItem alloc] initWithTitle:title image:nil handler:handler];
}


+ (instancetype)itemWithImage:(UIImage*)image handler:(BOOL(^)(SWCellButtonItem *item, SWRevealTableViewCell* cell))handler

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


#pragma mark - SWUtilityButtonView

@interface SWUtilityButtonView: SWUtilityView
@end

@implementation SWUtilityButtonView

- (void)layoutForPosition:(SWCellRevealPosition)position reversed:(BOOL)reversed
{
    CGRect bounds = self.bounds;
    
    UIView *button = [self.subviews firstObject];
    
    CGRect frame = button.frame;
    frame.origin.x = (!!reversed == position<SWCellRevealPositionCenter ? bounds.size.width-frame.size.width: 0);
    frame.origin.y = 0;
    frame.size.height = bounds.size.height;

    [button setFrame:frame];
}

@end


#pragma mark - SWUtilityContentView

//static const CGFloat DampeningWidth = 40;
static const CGFloat BrakeFactor = 0.1667;
static const CGFloat OverDrawWidth = 60;

@interface SWUtilityContentView: SWUtilityView
{
    __weak SWRevealTableViewCell *_c;
    BOOL _isRightExtended, _isLeftExtended;
}

@property (nonatomic,readonly) NSArray *leftButtonItems;
@property (nonatomic,readonly) NSArray *rightButtonItems;
@property (nonatomic,readonly) NSMutableArray *leftViews;
@property (nonatomic,readonly) NSMutableArray *rightViews;

@end


@implementation SWUtilityContentView

- (id)initWithRevealTableViewCell:(SWRevealTableViewCell *)revealTableViewCell frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self )
    {
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
    CGFloat location = 0.0f;
    
    CGFloat symmetry = revealPosition<SWCellRevealPositionCenter? -1 : 1;
    CGFloat revealWidth = revealPosition<SWCellRevealPositionCenter? [self rightRevealWidth] : [self leftRevealWidth];
    
    [_c _getAdjustedRevealPosition:&revealPosition forSymmetry:symmetry];
    
    if ( revealPosition == SWCellRevealPositionRight )
        location = revealWidth;
    
    else if ( revealPosition > SWCellRevealPositionRight )
        location = revealWidth+OverDrawWidth;

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


- (BOOL)performExtendedActionIfNeeded
{
    BOOL dismiss = NO;
    if ( _isLeftExtended )
        dismiss = [self _performActionForItem:[_leftButtonItems firstObject]];

    if ( _isRightExtended )
        dismiss = [self _performActionForItem:[_rightButtonItems firstObject]];
    
    return dismiss;
}


- (BOOL)_performActionForItem:(SWCellButtonItem*)item
{
    BOOL (^handler)(SWCellButtonItem*,SWRevealTableViewCell*) = item.handler;
    
    BOOL dismiss = NO;
    if ( handler )
        dismiss = handler( item, _c );
    
    return dismiss;
}


- (void)_buttonTouchUpAction:(SWUtilityButton*)button
{
    SWCellButtonItem *item = button.item;
    if ( [self _performActionForItem:item] )
        [_c setRevealPosition:SWCellRevealPositionCenter animated:YES];
}


- (void)_prepareLeftButtonItems
{
    if ( _leftButtonItems == nil )
        _leftButtonItems = [self _preparedItems:[_c _getLeftButtonItems]];
}


- (void)_prepareRightButtonItems
{
    if ( _rightButtonItems == nil )
        _rightButtonItems = [self _preparedItems:[_c _getRightButtonItems]];
}


- (NSArray*)_preparedItems:(NSArray*)itemsArray
{
    for ( SWCellButtonItem *item in itemsArray )
        item.view = self;
    
    return [itemsArray copy];
}


- (void)_deployItemsForNewPosition:(SWCellRevealPosition)newPosition
{
    NSArray *items = newPosition<SWCellRevealPositionCenter ? _leftButtonItems : _rightButtonItems;
    
    if ( items.count == 0 )
        return;
    
    NSMutableArray * __strong* views =  newPosition<SWCellRevealPositionCenter ? &_leftViews : &_rightViews;
    BOOL reversed = newPosition<SWCellRevealPositionCenter ? _c.leftCascadeReversed : _c.rightCascadeReversed;
    
    *views = [NSMutableArray array];
    *(newPosition<SWCellRevealPositionCenter ? &_isLeftExtended : &_isRightExtended) = NO;
    
    
    for ( SWCellButtonItem *item in items )
    {
        // get the button item
        NSAssert( [item isKindOfClass:[SWCellButtonItem class]], @"Cell button items must be of class SWCellButtonItem" );
        
        // get button item properties
        UIColor *backColor = item.backgroundColor;
        UIColor *tintColor = item.tintColor;
        UIImage *image = item.image;
        NSString *title = item.title;
    
        // create a utility view for the item
        SWUtilityButtonView *utilityButtonView = [[SWUtilityButtonView alloc] initWithFrame:CGRectMake(0, 0, item.width, 20)];
        [utilityButtonView setAutoresizesSubviews:NO];
        [utilityButtonView setClipsToBounds:YES];
        [utilityButtonView setCustomBackgroundColor:backColor];
        
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
        
        button.frame = utilityButtonView.bounds;
        button.titleLabel.numberOfLines = 0;
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.item = item;
        
        // Depending on actual item properties, we configure the button to make the best of it
        if ( image )
        {
            // we do not want to scale user provided images
            [button.imageView setContentMode:UIViewContentModeCenter];
            if ( title.length>0 )
            {
                // set a custom combined layout if both image and title are given
                [button.titleLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleFootnote]];
                [button setWantsCombinedLayout:YES];
            }
        }
        else
        {
            // set a white transparent higlited state if no image is given
            UIImage *highImage = _imageWithColor_size([UIColor colorWithWhite:1 alpha:0.333], CGSizeMake(1,1));
            highImage = [highImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            [button setImage:highImage forState:UIControlStateHighlighted];
            [button.imageView setContentMode:UIViewContentModeScaleToFill];
        }
        
        // set common button properties
        [button setTintColor:tintColor];
        [button setTitle:title forState:UIControlStateNormal];
        [button setImage:image forState:UIControlStateNormal];
        
        // add button to its utiliyButtonView
        [utilityButtonView addSubview:button];
        [*views addObject:utilityButtonView];
        
        // add utilityButtonView
        if ( reversed ) [self insertSubview:utilityButtonView atIndex:0];
        else [self addSubview:utilityButtonView];
    }
    
    // layout everything to the default position
    CGFloat xLocation = [self frontLocationForPosition:SWCellRevealPositionCenter];
    [self layoutForLocation:xLocation];
}


- (void)_undeployItemsForNewPosition:(SWCellRevealPosition)newPosition
{
    NSMutableArray * __strong* views = newPosition<SWCellRevealPositionCenter ? &_leftViews : &_rightViews;
    *(newPosition<SWCellRevealPositionCenter ? &_isLeftExtended : &_isRightExtended) = NO;
    
    for ( SWUtilityView *utilityView in *views )
    {
        [utilityView removeFromSuperview];
    }
    
    *views = nil;
}


- (void)_layoutViewsForNewPosition:(SWCellRevealPosition)newPosition location:(CGFloat)xLocation
{
    NSArray *views = newPosition<SWCellRevealPositionCenter? _leftViews : _rightViews;
    NSArray *items = newPosition<SWCellRevealPositionCenter ? _leftButtonItems : _rightButtonItems;
    CGFloat maxLocation = newPosition<SWCellRevealPositionCenter ? [self leftRevealWidth] : -[self rightRevealWidth];
    BOOL reversed = newPosition<SWCellRevealPositionCenter ? _c.leftCascadeReversed : _c.rightCascadeReversed;
    BOOL accionable = newPosition<SWCellRevealPositionCenter ? _c.performsActionOnLeftOverdraw : _c.performsActionOnRightOverdraw;
    BOOL *isExtended = newPosition<SWCellRevealPositionCenter ? &_isLeftExtended : &_isRightExtended;
    CGFloat symmetry = newPosition<SWCellRevealPositionCenter ? 1 : -1;
    
    CGFloat overdrawWidth = symmetry*OverDrawWidth;
    BOOL isExtendedOverDraw = fabs(xLocation) >= fabs(maxLocation+overdrawWidth);
    
    CGFloat xTarget = xLocation;
    if ( fabs(xLocation) > fabs(maxLocation) )
    {
        CGFloat overdraw = xLocation-maxLocation;
//        CGFloat dampeningWidth = symmetry*DampeningWidth;
//        xTarget = maxLocation + (overdraw*dampeningWidth)/(overdraw+dampeningWidth);
        xTarget = maxLocation + overdraw*BrakeFactor;
        
        CGFloat scale = Scale();
        xTarget = round(scale*xTarget)/scale;  // round to nearest screen pixel, good for retina and non-retina
    }
    
    NSInteger count = views.count;
    CGSize size = self.bounds.size;
    
    CGFloat endLocation = 0;
    for ( NSInteger i=0 ; i<count ; i++ )
    {
        SWCellButtonItem *item = [items objectAtIndex:i];
        
        CGFloat width = item.width;
        endLocation += width*symmetry;
        
        BOOL mayExtend = ( i==0 && reversed && accionable );
        
        CGFloat lWidth, location;
        if ( mayExtend && isExtendedOverDraw )
        {
            lWidth = fabs(xLocation);
            location = lWidth*symmetry;
        }
        else
        {
            lWidth = width*xTarget/maxLocation;
            location = xTarget*(endLocation/maxLocation);
        }
        
        CGFloat scale = Scale();
        if ( item.isOpaque ) lWidth += 1/scale;
        
        CGFloat xReference = symmetry<0 ? size.width+0 : 0-lWidth;
    
        CGFloat x = floor(scale*(xReference+location))/scale; // round to nearest screen pixel, good for retina and non-retina
        CGFloat w = ceil(scale*lWidth)/scale;
        
        CGRect frame = CGRectMake(x, 0, w, size.height);
        SWUtilityButtonView *utilityButtonView = [views objectAtIndex:i];
        
        void (^block)(void) = ^
        {
            [utilityButtonView setFrame:frame];
            [utilityButtonView layoutForPosition:newPosition reversed:reversed];
        };
        
        BOOL animated = NO;
        if ( mayExtend )
        {
            animated = (isExtendedOverDraw != *isExtended);
            *isExtended = isExtendedOverDraw;
        }
        
        if ( animated )
        {
            NSTimeInterval duration = isExtendedOverDraw?0.3:0.5;
            [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:0
            animations:block completion:nil];
        }
        else
        {
            block();
        }
    }
}


@end


#pragma mark - UIActionSheetExtension

@implementation UIActionSheet(SWCellButtonItem)

- (void)showFromCellButtonItem:(SWCellButtonItem *)item animated:(BOOL)animated
{
    SWUtilityContentView *utilityContentView = item.view;
    CGRect frame = [utilityContentView referenceFrameForCellButtonItem:item];
    
    [self showFromRect:frame inView:utilityContentView animated:animated];
}

@end

#pragma mark - UIViewPopoverPresentationController

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
@implementation UIPopoverPresentationController(SWCellButtonItem)

@dynamic cellButtonItem;
- (void)setCellButtonItem:(SWCellButtonItem *)cellButtonItem
{
    SWUtilityContentView *utilityContentView = cellButtonItem.view;
    CGRect frame = [utilityContentView referenceFrameForCellButtonItem:cellButtonItem];
    self.barButtonItem = nil;
    self.sourceView = utilityContentView;
    self.sourceRect = frame;
}

@end
#endif

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
    
    if (fabs(nowPoint.x - _beginPoint.x) > kDirectionPanThreshold) _dragging = YES;
    else if (fabs(nowPoint.y - _beginPoint.y) > kDirectionPanThreshold) self.state = UIGestureRecognizerStateFailed;
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
    _animationQueue = [NSMutableArray array];
    [self setCellRevealMode:SWCellRevealModeNormal];
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

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];

    if ( [self superview] )
    {
        SWCellRevealPosition initialPosition = _frontViewPosition;
        
        if ( _utilityContentView == nil )
        {
            // We pick the cell contentView's superview to perform our layout magic.
            // On iOS7 this used to be a UIScrollView, which was handy, but it is no longer the case on iOS8.
            // In case the contentOffset methods on the revealScrollView are not available we will perform our layout manualy.
            // See _setRevealLocation: implementation
            _revealLayoutView = (id)[self.contentView superview];
        
            // Create a view to hold our custom utility views and insert it into the cell hierarchy
            _utilityContentView = [[SWUtilityContentView alloc] initWithRevealTableViewCell:self frame:self.bounds];
            [_utilityContentView setAutoresizesSubviews:NO];
            [_utilityContentView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
            [_revealLayoutView insertSubview:_utilityContentView atIndex:0];

            // Force the initial reveal position to the developer provided value
            _frontViewPosition = SWCellRevealPositionNone;
            _leftViewPosition = SWCellRevealPositionNone;
            _rightViewPosition = SWCellRevealPositionNone;
        }
        
        // Finally, set the current position if needed
        [self _setRevealPosition:initialPosition withDuration:0.0];
    }
    else
    {
        // this will prevent retain cycles around item action blocks
        [_utilityContentView resetButtonItems];
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


- (SWCellRevealPosition)revealPosition;
{
    return _frontViewPosition;
}


- (void)setRevealPosition:(SWCellRevealPosition)revealPosition
{
    [self setRevealPosition:revealPosition animated:NO];
}


- (void)setRevealPosition:(SWCellRevealPosition)revealPosition animated:(BOOL)animated
{
    if ( ![self superview] )
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

- (void)setCellRevealMode:(SWCellRevealMode)cellRevealMode
{
    _cellRevealMode = cellRevealMode;
    BOOL reversed = NO, bounce = NO, action = NO;
    switch ( cellRevealMode )
    {
        case SWCellRevealModeNormalWithBounce: bounce = YES ; break;
        case SWCellRevealModeReversedWithAction: reversed = YES; action = YES ; break;
        default : break;
    }
    _rightCascadeReversed = reversed;
    _leftCascadeReversed = reversed;
    _bounceBackOnRightOverdraw = bounce;
    _bounceBackOnLeftOverdraw = bounce;
    _performsActionOnRightOverdraw = action;
    _performsActionOnLeftOverdraw = action;
}


#pragma mark - Reveal Location

- (void)_setRevealLocation:(CGFloat)xLocation
{
    // store the new reveal location
    _revealLocation = xLocation;
    
    // compensate our utilityContentView for cell layout comming next.
    CGRect utilityFrame = self.bounds;
    utilityFrame.size.height -= 0.5;
    utilityFrame.origin.x = -xLocation;
    [_utilityContentView setFrame:utilityFrame];
    
    // layout cell
    if ( [_revealLayoutView respondsToSelector:@selector(setContentOffset:)] )
    {
        // We have an underlying UIScrollView supporting our views (iOS7). We just set its contentOfset,
        // Apple implementation takes care of all the required layout code.
        [(UIScrollView*)_revealLayoutView setContentOffset:CGPointMake(-xLocation,0)];
    }

    else
    {
        // Ok, so no underlying scrollView for our layout needs :-/ (iOS8).
        // We must explicitly offset the cell contentView and its siblings to create our custom layout.
        // First, we call super layoutSubviews to get base cell subview frames from Apple implementation.
        [super layoutSubviews];
        
        // Now we apply our custom layout offset to the contentView sibling views
        for ( UIView *view in _revealLayoutView.subviews )
        {
            // One of the contentView's siblings of is the cell's separatorView.
            // We do not want to apply our custom layout to that particular view, so we skip that view based on its class name.
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
    
    if ( [_dataSource respondsToSelector:@selector(leftButtonItemsInRevealTableViewCell:)] )
        leftItems = [_dataSource leftButtonItemsInRevealTableViewCell:self];
    
    return leftItems;
}


- (NSArray*)_getRightButtonItems
{
    NSArray *rightItems = nil;
    
    if ( [_dataSource respondsToSelector:@selector(rightButtonItemsInRevealTableViewCell:)] )
        rightItems = [_dataSource rightButtonItemsInRevealTableViewCell:self];

    return rightItems;
}


#pragma mark - Symmetry

- (void)_getAdjustedRevealPosition:(SWCellRevealPosition*)revealPosition forSymmetry:(CGFloat)symmetry
{
    if ( symmetry < 0 )
        *revealPosition = SWCellRevealPositionCenter + symmetry*(*revealPosition-SWCellRevealPositionCenter);
}


- (void)_getDragLocation:(CGFloat*)xLocation progress:(CGFloat*)progress
{
    *xLocation = _revealLocation;
    CGFloat symmetry = *xLocation<0 ? -1 : 1;
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

// Primitive method for utility view deployment and animated layout to the given position.
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

// Deploy/Undeploy of the utility view. Returns a block
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

// Deploy/Undeploy of the left view items. Returns a block
// that must be invoked on animation completion in order to finish deployment
- (void (^)(void))_leftDeploymentForNewRevealPosition:(SWCellRevealPosition)newPosition
{

    if ( newPosition > SWCellRevealPositionCenter && _utilityContentView.leftCount==0 )
        newPosition = SWCellRevealPositionCenter;
    
    if ( !_allowsRevealInEditMode && self.editing )
        newPosition = SWCellRevealPositionCenter;

    BOOL appear = (_leftViewPosition <= SWCellRevealPositionCenter || _leftViewPosition == SWCellRevealPositionNone) && newPosition > SWCellRevealPositionCenter;
    BOOL disappear = newPosition <= SWCellRevealPositionCenter && (_leftViewPosition > SWCellRevealPositionCenter && _leftViewPosition != SWCellRevealPositionNone);
    
    if ( appear )
        [_revealLayoutView sendSubviewToBack:_utilityContentView];
    
    _leftViewPosition = newPosition;
    
    return [self _deploymentForLeftItemsWithAppear:appear disappear:disappear];
}

// Deploy/Undeploy of the right view items. Returns a block
// that must be invoked on animation completion in order to finish deployment
- (void (^)(void))_rightDeploymentForNewRevealPosition:(SWCellRevealPosition)newPosition
{
    if ( newPosition < SWCellRevealPositionCenter && _utilityContentView.rightCount==0)
        newPosition = SWCellRevealPositionCenter;
    
    if ( !_allowsRevealInEditMode && self.editing )
        newPosition = SWCellRevealPositionCenter;

    BOOL appear = (_rightViewPosition >= SWCellRevealPositionCenter || _rightViewPosition == SWCellRevealPositionNone) && newPosition < SWCellRevealPositionCenter ;
    BOOL disappear = newPosition >= SWCellRevealPositionCenter && (_rightViewPosition < SWCellRevealPositionCenter && _rightViewPosition != SWCellRevealPositionNone);
    
    if ( appear )
        [_revealLayoutView sendSubviewToBack:_utilityContentView];
    
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
    // apply damper effect on the overdraw area
    CGFloat maxLocation = xLocation<0 ? -[_utilityContentView rightRevealWidth] : [_utilityContentView leftRevealWidth];
    CGFloat symmetry = xLocation<0 ? -1 : 1;
    CGFloat overdrawLocation = maxLocation + symmetry*OverDrawWidth;
    
    if ( fabs(xLocation) > fabs(overdrawLocation) )
    {
        CGFloat secondaryOverdraw = xLocation-overdrawLocation;
//        CGFloat dampeningWidth = symmetry*DampeningWidth;
//        xLocation = overdrawLocation + (secondaryOverdraw*dampeningWidth)/(secondaryOverdraw+dampeningWidth);
        xLocation = overdrawLocation + secondaryOverdraw*BrakeFactor;

        CGFloat scale = Scale();
        xLocation = round(scale*xLocation)/scale;  // round to nearest screen pixel, good for retina and non-retina
    }
    
    // update frames according to our required offset
    [self _setRevealLocation:xLocation];
    
    // layout utilityContentView
    [_utilityContentView layoutForLocation:xLocation];
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
    
    // forbid gesture if the following delegate is implemented and returns NO
    if ( [_delegate respondsToSelector:@selector(revealTableViewCellPanGestureShouldBegin:)] )
        if ( [_delegate revealTableViewCellPanGestureShouldBegin:self] == NO )
            return NO;

    UIView *recognizerView = _panGestureRecognizer.view;
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
    CGFloat symmetry = xLocation<0 ? -1 : 1;
    
    // symmetric computing of widths
    CGFloat revealWidth = symmetry<0 ? [_utilityContentView rightRevealWidth] : [_utilityContentView leftRevealWidth];
    BOOL bounceBack = symmetry<0 ? _bounceBackOnRightOverdraw : _bounceBackOnLeftOverdraw;
    BOOL reversed = symmetry<0 ? _rightCascadeReversed : _leftCascadeReversed;
    BOOL actionable = symmetry<0 ? _performsActionOnRightOverdraw : _performsActionOnLeftOverdraw;
  
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
            journey = revealWidth - xLocation;
            revealPosition = SWCellRevealPositionRight;
            if (xLocation >= revealWidth+OverDrawWidth)
            {
                if (bounceBack) revealPosition = SWCellRevealPositionCenter;
                else if (reversed && actionable) revealPosition = SWCellRevealPositionRightExtended;
                else revealPosition = SWCellRevealPositionRight;
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
            if (xLocation >= revealWidth+OverDrawWidth)
            {
                if (bounceBack) revealPosition = SWCellRevealPositionCenter;
                else if (reversed && actionable) revealPosition = SWCellRevealPositionRightExtended;
                else revealPosition = SWCellRevealPositionRight;
            }
        }
    }

    // symetric replacement of revealPosition
    [self _getAdjustedRevealPosition:&revealPosition forSymmetry:symmetry];
    
    // Notify delegate
    [self _notifyPanGestureEnded];

    // Perform item action if necessary
    if ( [_utilityContentView performExtendedActionIfNeeded] )
        revealPosition = SWCellRevealPositionCenter;

    // Animate to the final position
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