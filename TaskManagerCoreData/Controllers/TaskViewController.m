//
//  TaskViewController.m
//  TaskManagerCoreData
//
//  Created by Nataliya Murauyova on 7/16/18.
//  Copyright © 2018 Nataliya Murauyova. All rights reserved.
//

#import "TaskViewController.h"
#import "AppDelegate.h"
#import "TaskDetailViewController.h"

static CGFloat const tableViewCellHeight = 60.0;
static NSString* const Cellidentifier = @"Cell";
static NSString* const sequeForTaskDetailVC = @"idSequeEditInfo";

@interface TaskViewController ()
//properties for Core data
@property(strong)NSMutableArray *tasks;
//properties for SQlite3
@property(strong,nonatomic) DBManager* dbManager;
@property(strong,nonatomic)NSArray* arrTaskInfo;
@property(nonatomic) int recordIDToEdit;

@end

@implementation TaskViewController

-(NSManagedObjectContext*)managedObjectContext{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return [delegate managedObjectContext];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSString *value = [[NSUserDefaults standardUserDefaults] stringForKey:@"stateOfSwitch"];
    if([value compare:@"on"] == NSOrderedSame){
        self.changeDB.on = YES;
    } else {
        self.changeDB.on = NO;
    }
   
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    if ([self.changeDB isOn]){
    [self.tableView reloadData];
    } else if (![self.changeDB isOn]){
        self.dbManager = [[DBManager alloc] initWithFileName:@"taskManagerDB"];
        [self loadData];
    }
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if([self.changeDB isOn]){
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Tasks"];
    self.tasks = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy] ;
    
    [self.tableView reloadData];
    }
}
-(void)loadData{
    NSString *query = @"select * from taskInfo";
    
    if(self.arrTaskInfo != nil){
        self.arrTaskInfo = nil;
    }
    self.arrTaskInfo = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger *numberOfRows =nil;
    if (self.changeDB.on) {
        numberOfRows = [self.tasks count];
    } else if (!self.changeDB.on) {
        numberOfRows = [self.arrTaskInfo count];
    }
        return numberOfRows;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return tableViewCellHeight;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Cellidentifier forIndexPath:indexPath];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    
    if([self.changeDB isOn]){
    NSManagedObject *task = [self.tasks objectAtIndex:indexPath.row];
    [cell.textLabel setText:[NSString stringWithFormat:@"%@(%@)",[task valueForKey:@"taskName"],[task valueForKey:@"taskDescription"]]];
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"Deadline:%@ Priority:%@",[task valueForKey:@"deadline"],[task valueForKey:@"priority"]]];
    } else if (![self.changeDB isOn])
    {
        NSInteger taskNameIndex = [self.dbManager.arrColumnNames indexOfObject:@"taskName"];
        NSInteger taskDescriptionIndex = [self.dbManager.arrColumnNames indexOfObject:@"taskDescription"];
        NSInteger deadlineIndex = [self.dbManager.arrColumnNames indexOfObject:@"deadline"];
        NSInteger priorityIndex = [self.dbManager.arrColumnNames indexOfObject:@"priority"];
        
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@) ",[[self.arrTaskInfo objectAtIndex:indexPath.row] objectAtIndex:taskNameIndex],[[self.arrTaskInfo objectAtIndex:indexPath.row]objectAtIndex:taskDescriptionIndex] ];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Deadline: %@ day(s) Priority: %@", [[self.arrTaskInfo objectAtIndex:indexPath.row] objectAtIndex:deadlineIndex],[[self.arrTaskInfo objectAtIndex:indexPath.row] objectAtIndex:priorityIndex]] ;
    }
    
    return cell;
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    if (editingStyle == UITableViewCellEditingStyleDelete){
        if([self.changeDB isOn]){
        [managedObjectContext deleteObject:[self.tasks objectAtIndex:indexPath.row]];
        
        NSError *error = nil;
        if(![managedObjectContext save:&error]){
            NSLog(@"Problems with deleting  - %@",[error localizedDescription]);
        }
        [self.tasks removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        } else if(![self.changeDB isOn]){
            int recordIDToDelete = [[[self.arrTaskInfo objectAtIndex:indexPath.row] objectAtIndex:0] intValue];
            NSString *query = [NSString stringWithFormat:@"delete from taskInfo where taskInfoID=%d", recordIDToDelete];
            [self.dbManager executeQuery:query];
            [self loadData];
        }
        
    }
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:sequeForTaskDetailVC]){
        if([self.changeDB isOn]){
        NSManagedObject *selectedTask = [self.tasks objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
        TaskDetailViewController *taskDetailVC = segue.destinationViewController;
        taskDetailVC.task=selectedTask;
        } else if(![self.changeDB isOn]){
            self.recordIDToEdit = [[self.arrTaskInfo objectAtIndex:[[self.tableView indexPathForSelectedRow] row]] intValue];
            TaskDetailViewController *taskDetailVC = segue.destinationViewController;
            taskDetailVC.recordIDToEdit = self.recordIDToEdit;
            taskDetailVC.switchState = self.changeDB.isOn;
        }
    }
}


- (IBAction)changeSwitch:(id)sender {
    NSString *onValue = @"on";
    NSUserDefaults *userpref = [NSUserDefaults standardUserDefaults];
    if(![self.changeDB isOn]){
        onValue = @"off";
        [userpref setObject:onValue forKey:@"stateOfSwitch"];
    }
    [userpref setObject:onValue forKey:@"stateOfSwitch"];
    [self.tableView reloadData];
}
-(BOOL) switchState{
    BOOL flag = nil;
    if([self.changeDB isOn]){
        flag = YES;
    } else if (![self.changeDB isOn]){
        flag = NO;
    }
    return flag;
}
@end
