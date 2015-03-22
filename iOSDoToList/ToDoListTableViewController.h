//
//  ToDoListTableViewController.h
//  iOSDoToList
//
//  Created by David Buhauer on 17/01/15.
//  Copyright (c) 2015 David Buhauer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ToDoItem.h"
#import "SWTableViewCell.h"

@interface ToDoListTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SWTableViewCellDelegate>{
    UIImageView *imageView;
}
@property NSMutableArray *toDoItems;
@property NSMutableArray *sortedItems;
@property NSMutableArray *tempItems;
@property ToDoItem *toDoItem;

-(IBAction)unWindFromAdd:(UIStoryboardSegue*) segue;
-(IBAction)unWindFromReminder:(UIStoryboardSegue*) segue;
-(IBAction)unWindFromShortCut:(UIStoryboardSegue*) segue;
-(IBAction)mainControlSwitched:(id)sender;
-(IBAction)editButton:(id)sender;
-(IBAction)selectAllItems:(id)sender;
-(IBAction)deleteSelectedItems:(id)sender;

@end
