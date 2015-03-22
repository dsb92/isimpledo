//
//  RepeatViewController.m
//  iOSDoToList
//
//  Created by David Buhauer on 07/02/15.
//  Copyright (c) 2015 David Buhauer. All rights reserved.
//

#import "RepeatViewController.h"

@interface RepeatViewController ()
@property (weak, nonatomic) IBOutlet UITableView *repeatTableView;

@end

@implementation RepeatViewController

#pragma mark - didLoad

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.repeatArray = [[NSArray alloc]initWithObjects:@"Never", @"Every day", @"Every week", @"Every month", @"Every year", nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tableview setup

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.repeatArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RepeatTimesCell" forIndexPath:indexPath];
    cell.textLabel.text = [self.repeatArray objectAtIndex:indexPath.row];
    
    if ([self.repeatArray objectAtIndex:indexPath.row] == self.repeatSelection && ![self.repeatSelection isEqual:@"Never"]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.repeatTableView==tableView && ![self.repeatSelection isEqual:@"Never"]){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RepeatTimesCell" forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark; 
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    NSIndexPath *indexPath = self.repeatTableView.indexPathForSelectedRow;
    self.repeatSelection = [self.repeatArray objectAtIndex:indexPath.row];
}


@end
