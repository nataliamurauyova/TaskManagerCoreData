//
//  TaskViewController.h
//  TaskManagerCoreData
//
//  Created by Nataliya Murauyova on 7/16/18.
//  Copyright © 2018 Nataliya Murauyova. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "DBManager.h"

@interface TaskViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISwitch *changeDB;


- (IBAction)changeSwitch:(id)sender;
-(BOOL) switchState;

@end
