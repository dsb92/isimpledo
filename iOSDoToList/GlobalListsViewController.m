//
//  GlobalListsViewController.m
//  SimpleDo
//
//  Created by David Buhauer on 18/06/15.
//  Copyright (c) 2015 David Buhauer. All rights reserved.
//

#import "GlobalListsViewController.h"

@interface GlobalListsViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation GlobalListsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.customListDictionary.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListsCell" forIndexPath:indexPath];
    NSArray * sortedKeys = [[self.customListDictionary allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    cell.textLabel.text = [sortedKeys objectAtIndex:indexPath.row];
    
    if ([[sortedKeys objectAtIndex:indexPath.row] isEqualToString:self.selectedKey])
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListsCell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSArray * sortedKeys = [[self.customListDictionary allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];

    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
    self.selectedKey = [sortedKeys objectAtIndex:indexPath.row];
}


@end
