//
//  HelpViewController.m
//  QuickResponse
//
//  Created by Haifisch on 11/7/13.
//  Copyright (c) 2013 Haifisch. All rights reserved.
//

#import "HelpViewController.h"
#import "ViewController.h"
@interface HelpViewController ()

@end

@implementation HelpViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    ViewController *view = [[ViewController alloc] init];
    [view.session stopRunning];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(15, 8, 320, 20);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithRed:48/255 green:48/255 blue:48/255 alpha:1];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    label.text = sectionTitle;
    
    UIView *view = [[UIView alloc] init];
    [view addSubview:label];
    
    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 33.0;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
   // NSLog(@"%ld",(long)indexPath.row);
    if (indexPath.row == 1) {
        //NSLog(@"Julian");
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/insanj"]];

    }else if (indexPath.row == 0) {
        //NSLog(@"Haifisch");
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/0x8badfl00d"]];
    }
}

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
