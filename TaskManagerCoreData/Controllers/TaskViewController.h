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
#import "TaskDetailViewController.h"

@interface TaskViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISwitch *changeDB;
@property (strong,nonatomic) NSManagedObject *task;



- (IBAction)changeSwitch:(id)sender;
-(BOOL) switchState;
- (IBAction)addNewRecord:(id)sender;
-(void)loadData;
-(void)loadCoredata;

@end
