//
//  ListsViewController.m
//  SimpleDo
//
//  Created by David Buhauer on 17/05/15.
//  Copyright (c) 2015 David Buhauer. All rights reserved.
//

#import "ListsViewController.h"

@interface ListsViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ListsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.filterArray = [[NSMutableArray alloc] initWithObjects:@"Today", @"Tomorrow", @"Upcoming", @"No due dates", @"Everything", nil];
    
    // Load custom lists
    self.customListArray = [[NSMutableArray alloc]init];
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
        return self.customListArray.count;
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
        cell.textLabel.text = [self.customListArray objectAtIndex:indexPath.row];
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
    
    else if (indexPath.section == 1){
        [self performSegueWithIdentifier:@"EverythingSegue" sender:self];
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
- (IBAction)NewListTapped:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Add new list" message:@"Please name your custom list:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *alertTextField = [alert textFieldAtIndex:0];
    alertTextField.placeholder = @"Enter name of list";
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *inputTitle = [[alertView textFieldAtIndex:0] text];
    if (buttonIndex == 0){
        NSLog(@"Cancel");
    }
    else{
        NSLog(@"Add");
        [self.customListArray addObject:inputTitle];
        [self.tableView reloadData];
    }
    NSLog(@"Entered: %@",inputTitle);
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    
}

@end
