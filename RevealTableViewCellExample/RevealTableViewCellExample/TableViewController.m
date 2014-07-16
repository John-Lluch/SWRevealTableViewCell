//
//  TableViewController.m
//  RevealTableViewCellExample
//
//  Created by Joan Lluch on 14/06/14.
//  Copyright (c) 2014 John-Lluch. All rights reserved.
//

#import "TableViewController.h"
#import "SWRevealTableViewCell.h"

@interface TableViewController ()<SWRevealTableViewCellDelegate,SWRevealTableViewCellDataSource,UIActionSheetDelegate>
{
    NSIndexPath *_revealingCellIndexPath;
    NSInteger _sectionTitleRowCount;
}

@end

@implementation TableViewController

typedef enum
{
    SectionTitle = 0,
    SectionImage,
    SectionsCount,
} Sections;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

static NSString *RevealCellReuseIdentifier = @"RevealCellReuseIdentifier";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UITableView *tableView = self.tableView;
    //[tableView setBackgroundColor:[UIColor grayColor]];
    
    //UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"abstract-free-wallpaper-and-backgrounds-141.jpg"]];
    //imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    //[tableView setBackgroundView:imageView];
    
    [tableView registerClass:[SWRevealTableViewCell class] forCellReuseIdentifier:RevealCellReuseIdentifier];
    self.title = @"My Table View Title";
    
    UIBarButtonItem *buttonItemAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(buttonItemAddAction:)];
    [self.navigationItem setRightBarButtonItem:buttonItemAdd];
    
    _sectionTitleRowCount = 4;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SectionsCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( section == SectionTitle )
        return _sectionTitleRowCount;
    
    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SWRevealTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RevealCellReuseIdentifier forIndexPath:indexPath];

    cell.delegate = self;
    cell.dataSource = self;
    
    // Configure the cell...
    cell.textLabel.text = [NSString stringWithFormat:@"My cell content %ld", (long)indexPath.section];
    cell.imageView.image = [[UIImage imageNamed:@"ipod.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.imageView.tintColor = [UIColor darkGrayColor];
    
    //cell.rightCascadeReversed = YES;
    //cell.leftCascadeReversed = YES;
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}


- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    switch ( section )
    {
        case SectionTitle:
            title = @"Reveal Title Items";
            break;
            
        case SectionImage:
            title = @"Reveal Image Items";
            break;
    }
    return title;
}

//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return UITableViewCellEditingStyleDelete;
//}
//
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//}
//
//
//- (NSArray*)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewRowAction *action1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"primer"
//    handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
//    {
//        NSLog( @"M'han tocat primer");
//    }];
//    
//    action1.backgroundColor = [UIColor redColor];
//    
//    UITableViewRowAction *action2 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"seg"
//    handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
//    {
//        NSLog( @"M'han tocat segon");
//    }];
//
//    action2.backgroundColor = [UIColor orangeColor];
//
//    return @[action1,action2];
//}
//
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    SWRevealTableViewCell *cell = (id)[tableView cellForRowAtIndexPath:indexPath];
//    [cell setRevealPosition:SWCellRevealPositionLeft animated:YES];
//}
//
//
//- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    SWRevealTableViewCell *cell = (id)[tableView cellForRowAtIndexPath:indexPath];
//    [cell setRevealPosition:SWCellRevealPositionCenter animated:YES];
//}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - SWRevealTableViewCell delegate

- (void)revealTableViewCell:(SWRevealTableViewCell *)revealTableViewCell willMoveToPosition:(SWCellRevealPosition)position
{
    if ( position == SWCellRevealPositionCenter )
        return;
    
    for ( SWRevealTableViewCell *cell in [self.tableView visibleCells] )
    {
        if ( cell == revealTableViewCell )
            continue;
        
        [cell setRevealPosition:SWCellRevealPositionCenter animated:YES];
    }
}


- (void)revealTableViewCell:(SWRevealTableViewCell *)revealTableViewCell didMoveToPosition:(SWCellRevealPosition)position
{
    if ( position == SWCellRevealPositionCenter )
        _revealingCellIndexPath = nil;
    else
        _revealingCellIndexPath = [self.tableView indexPathForCell:revealTableViewCell];
}


#pragma mark - SWRevealTableViewCell data source

- (NSArray*)leftButtonItemsInRevealTableViewCell:(SWRevealTableViewCell *)revealTableViewCell
{
    SWCellButtonItem *item1 = [SWCellButtonItem itemWithTitle:@"Snap" handler:^(SWCellButtonItem *item, SWRevealTableViewCell *cell)
    {
        NSLog( @"Snap Tapped");
    }];
    
    item1.backgroundColor = [UIColor cyanColor];
    item1.width = 50;
    item1.tintColor = [UIColor darkGrayColor];
    
    SWCellButtonItem *item2 = [SWCellButtonItem itemWithTitle:@"Select" handler:^(SWCellButtonItem *item, SWRevealTableViewCell *cell)
    {
        NSLog( @"Select Tapped");
    }];
    
    item2.backgroundColor = [UIColor colorWithRed:0 green:0.5 blue:1 alpha:1];
    item2.image = [UIImage imageNamed:@"heart.png"];
    item2.tintColor = [UIColor whiteColor];
    item2.width = 75;
    
    return @[item1,item2];
}


- (NSArray*)rightButtonItemsInRevealTableViewCell:(SWRevealTableViewCell *)revealTableViewCell
{
    NSArray *items = nil;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:revealTableViewCell];
    NSInteger section = indexPath.section;
    
    if ( section == SectionTitle )
    {
        SWCellButtonItem *item1 = [SWCellButtonItem itemWithTitle:@"Delete" handler:^(SWCellButtonItem *item, SWRevealTableViewCell *cell)
        {
            [self presentDeleteActionSheetForItem:item];
        }];
    
        item1.backgroundColor = [UIColor redColor];
        item1.tintColor = [UIColor whiteColor];
        item1.width = 75;
    
    
        SWCellButtonItem *item2 = [SWCellButtonItem itemWithTitle:@"Rename" handler:^(SWCellButtonItem *item, SWRevealTableViewCell *cell)
        {
            [self presentRenameActionSheetForItem:item];
        }];

        item2.backgroundColor = [UIColor darkGrayColor];
        item2.tintColor = [UIColor whiteColor];
        item2.width = 75;
    
        SWCellButtonItem *item3 = [SWCellButtonItem itemWithTitle:@"More" handler:^(SWCellButtonItem *item, SWRevealTableViewCell *cell)
        {
            [self presentMoreActionSheetForItem:item];
        }];
    
        item3.backgroundColor = [UIColor lightGrayColor];
        item3.width = 75;
    
        items = @[item1,item2,item3];
    }
    
    else if ( section == SectionImage )
    {
        SWCellButtonItem *item1 = [SWCellButtonItem itemWithImage:[UIImage imageNamed:@"star.png"] handler:^(SWCellButtonItem *item, SWRevealTableViewCell *cell)
        {
            NSLog( @"Star Tapped");
        }];
    
        item1.backgroundColor = [UIColor orangeColor];
        item1.tintColor = [UIColor whiteColor];
        item1.width = 50;
    
    
        SWCellButtonItem *item2 = [SWCellButtonItem itemWithImage:[UIImage imageNamed:@"heart.png"] handler:^(SWCellButtonItem *item, SWRevealTableViewCell *cell)
        {
            NSLog( @"Heart Tapped");
        }];

        item2.backgroundColor = [UIColor darkGrayColor];
        item2.tintColor = [UIColor redColor];
        item2.width = 50;
    
        SWCellButtonItem *item3 = [SWCellButtonItem itemWithImage:[UIImage imageNamed:@"airplane.png"] handler:^(SWCellButtonItem *item, SWRevealTableViewCell *cell)
        {
            NSLog( @"Airplane Tapped");
        }];
    
        item3.backgroundColor = [UIColor lightGrayColor];
        item3.width = 50;
    
        items = @[item1,item2,item3];
    }

    return items;
}


#pragma mark - ButtonItemAdd action

- (void)buttonItemAddAction:(id)sender
{
    NSIndexPath *insertingPath = [NSIndexPath indexPathForRow:0 inSection:SectionTitle];
    _sectionTitleRowCount += 1;
    
    [self.tableView insertRowsAtIndexPaths:@[insertingPath] withRowAnimation:UITableViewRowAnimationFade];
}


#pragma mark - UIActionSheet


- (void)presentDeleteActionSheetForItem:(SWCellButtonItem*)cellItem
{
    UIActionSheet *actSheet = [[UIActionSheet alloc] initWithTitle:@"Delete Actions"
                delegate:self
                cancelButtonTitle:@"Cancel"
                destructiveButtonTitle:@"Delete Now"
                otherButtonTitles:nil ];

    [actSheet setTag:0];
    [actSheet showFromCellButtonItem:cellItem animated:YES];
}


- (void)_performDeleteAction
{
    _sectionTitleRowCount -= 1;
    [self.tableView deleteRowsAtIndexPaths:@[_revealingCellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
}


- (void)presentRenameActionSheetForItem:(SWCellButtonItem*)cellItem
{
    UIActionSheet *actSheet = [[UIActionSheet alloc] initWithTitle:@"More Actions"
                delegate:self
                cancelButtonTitle:@"Cancel"
                destructiveButtonTitle:nil
                otherButtonTitles:@"Action Rename", nil ];

    [actSheet setTag:1];
    [actSheet showFromCellButtonItem:cellItem animated:YES];
}


- (void)_performRenameAction
{
    NSLog( @"Rename Tapped");
}


- (void)presentMoreActionSheetForItem:(SWCellButtonItem*)cellItem
{
    UIActionSheet *actSheet = [[UIActionSheet alloc] initWithTitle:@"More Actions"
                delegate:self
                cancelButtonTitle:@"Cancel"
                destructiveButtonTitle:nil
                otherButtonTitles:@"Action One", @"Action Two", @"Action Three", nil ];

    [actSheet setTag:2];
    [actSheet showFromCellButtonItem:cellItem animated:YES];
}


- (void)_performMoreActionAtIndex:(NSInteger)firstOtherButtonIndex
{
    switch ( firstOtherButtonIndex)
    {
        case 0:
            NSLog( @" Action One Tapped");
            break;
            
        case 1:
            NSLog( @" Action Two Tapped");
            break;
            
        case 2:
            NSLog( @" Action Three Tapped");
            break;

        default:
            break;
    }
}


// UIActionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //NSLog( @"clickedButtonAtIndex: %d", buttonIndex );
    
    if ( buttonIndex == [actionSheet cancelButtonIndex] )
    {
        NSLog( @"Cancel");
        return;
    }
    
    NSInteger firstOtherButtonIndex = [actionSheet firstOtherButtonIndex];
    
    switch ( actionSheet.tag )
    {
        case 0:  // delete
            [self _performDeleteAction];
            break;
            
        case 1:  // rename
            [self _performRenameAction];
            break;
            
        case 2:  // more
            [self _performMoreActionAtIndex:firstOtherButtonIndex];
            break;

        default:
            break;
    }
    
    SWRevealTableViewCell *cell = (id)[self.tableView cellForRowAtIndexPath:_revealingCellIndexPath];
    [cell setRevealPosition:SWCellRevealPositionCenter animated:YES];
}


@end
