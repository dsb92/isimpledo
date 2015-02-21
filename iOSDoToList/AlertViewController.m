//
//  AlertViewController.m
//  iOSDoToList
//
//  Created by David Buhauer on 07/02/15.
//  Copyright (c) 2015 David Buhauer. All rights reserved.
//

#import "AlertViewController.h"
#import "ReminderViewController.h"

@interface AlertViewController ()
@property (weak, nonatomic) IBOutlet UITableView *noneAlertTableView;
@property (weak, nonatomic) IBOutlet UITableView *alertTableView;
@end

@implementation AlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.alertArray = [[NSArray alloc]initWithObjects:@"On current due date", @"5 minutes before", @"15 minuttes before", @"30 minutes before", @"1 hour before", @"2 hours before", @"1 day before", @"2 days before", @"1 week before", nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.noneAlertTableView==tableView) {
        return 1;
    }
    else
        return [self.alertArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.noneAlertTableView==tableView){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoneAlertCell" forIndexPath:indexPath];
        cell.textLabel.text = @"None";

        return cell;
    }
    else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlertTimesCell" forIndexPath:indexPath];
        cell.textLabel.text = [self.alertArray objectAtIndex:indexPath.row];
        
        if ([self.alertArray objectAtIndex:indexPath.row] == self.alertSelection) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.alertTableView==tableView){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlertTimesCell" forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSIndexPath *indexPath = self.alertTableView.indexPathForSelectedRow;
    if(indexPath==nil){
        self.alertSelection = @"None";
    }
    else
        self.alertSelection = [self.alertArray objectAtIndex:indexPath.row];
}



@end
