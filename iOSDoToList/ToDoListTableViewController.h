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

@interface ToDoListTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, SWTableViewCellDelegate>{
}
@property NSMutableArray *toDoItems;
@property ToDoItem *toDoItem;

-(IBAction)unWindFromAdd:(UIStoryboardSegue*) segue;
-(IBAction)unWindFromReminder:(UIStoryboardSegue*) segue;
-(IBAction)unWindFromShortCut:(UIStoryboardSegue*) segue;
-(IBAction)editButton:(id)sender;

@end
