//
//  ListsViewController.m
//  SimpleDo
//
//  Created by David Buhauer on 17/05/15.
//  Copyright (c) 2015 David Buhauer. All rights reserved.
//

#import "ListsViewController.h"

@interface ListsViewController ()

@end

@implementation ListsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.filterArray = [[NSMutableArray alloc] initWithObjects:@"Today", @"Tomorrow", @"Upcoming", @"No due dates", @"Everything", nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0){
        return self.filterArray.count;
    }
    else if (section == 1){
        return 2;
    }
    else{
        return 1;
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    if (indexPath.section == 0){
        cell.textLabel.text = [self.filterArray objectAtIndex:indexPath.row];
    }
    else if (indexPath.section == 1){
        
    }
    else {
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        NSString *filter = [self.filterArray objectAtIndex:indexPath.row];
        
        if ([filter isEqualToString:[self.filterArray lastObject]]){
            // User tapped 'Everything'
            [self performSegueWithIdentifier:@"EverythingSegue" sender:self];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0){
        return @"Filters";
    }
    else if (section == 1){
        return @"Lists";
    }
    else{
        return @"";
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
