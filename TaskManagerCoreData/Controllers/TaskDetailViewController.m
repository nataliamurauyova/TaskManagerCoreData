//
//  TaskDetailViewController.m
//  TaskManagerCoreData
//
//  Created by Nataliya Murauyova on 7/16/18.
//  Copyright © 2018 Nataliya Murauyova. All rights reserved.
//

#import "TaskDetailViewController.h"
#import "AppDelegate.h"


@interface TaskDetailViewController ()
@property(nonatomic,strong) NSArray *pickerdata;
@property(nonatomic,strong) DBManager *dbManager;

-(void)loadInfoToEdit;
@end

@implementation TaskDetailViewController

-(NSManagedObjectContext*)managedObjectContext{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return [delegate managedObjectContext];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pickerdata = @[@"High",@"Medium",@"Low"];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    
    self.priority.text = @"";
    
    self.taskName.delegate = self;
    self.taskDescription.delegate = self;
    self.deadline.delegate = self;
    self.priority.delegate = self;
    
    self.navigationController.navigationBar.tintColor = self.navigationItem.rightBarButtonItem.tintColor;
    
//    TaskViewController *taskVC = [[TaskViewController alloc] init];
//    if([taskVC.changeDB isOn]){
    if(self.switchState){
    if(self.task){
        [self.taskName setText:[self.task valueForKey:@"taskName"]];
        [self.taskDescription setText:[self.task valueForKey:@"taskDescription"]];
        [self.deadline setText:[self.task valueForKey:@"deadline"]];
        [self.priority setText:[self.task valueForKey:@"priority"]];
        
    } } else if 
//    }
//     else if (![taskVC.changeDB isOn]){
//        self.dbManager = [[DBManager alloc] initWithFileName:@"taskMananger"];
//        if(self.recordIDToEdit != -1){
//            [self loadInfoToEdit];
//        }
//    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(id)sender {
    NSManagedObjectContext *context = [self managedObjectContext];
    
//    TaskViewController *taskVC = [[TaskViewController alloc] init];
//    if([taskVC.changeDB isOn]){
    
    
    if (self.switchState){
    if(self.task){
        [self.task setValue:self.taskName.text forKey:@"taskName"];
        [self.task setValue:self.taskDescription.text forKey:@"taskDescription"];
        [self.task setValue:self.deadline.text forKey:@"deadline"];
        [self.task setValue:self.priority.text forKey:@"priority"];
    } else {
    NSManagedObject *newTask = [NSEntityDescription insertNewObjectForEntityForName:@"Tasks" inManagedObjectContext:context];
    [newTask setValue:self.taskName.text forKey:@"taskName"];
    [newTask setValue:self.taskDescription.text forKey:@"taskDescription"];
    [newTask setValue:self.deadline.text forKey:@"deadline"];
    [newTask setValue:self.priority.text forKey:@"priority"];
    }
    
    NSError *error = nil;
    if(![context save:&error]) {
        NSLog(@"Can't save! %@",[error localizedDescription]);
    }
    } else if (!self.switchState)

    {
        NSString *query;
        if(self.recordIDToEdit == -1){
            query = [NSString stringWithFormat:@"insert into taskInfo values(null,'%@','%@',%d, '%@')",self.taskName.text,self.taskDescription.text,[self.deadline.text intValue],self.priority.text ];
        } else {
            query = [NSString stringWithFormat:@"update taskInfo set taskName = '%@', taskDescription = '%@', deadline = %d, prioriry = '%@' where taskInfoID = %d", self.taskName.text,self.taskDescription.text,self.deadline.text.intValue, self.priority.text, self.recordIDToEdit];
        }
        [self.dbManager executeQuery:query];
        if(self.dbManager.affectedRows !=0){
            NSLog(@"Query executed successfully. Affected rows = %d",self.dbManager.affectedRows);
            //[self.delegate editingInfoWasFinished];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            NSLog(@"Problems with executing the query");
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)loadInfoToEdit{
    NSString *query = [NSString stringWithFormat:@"select * from taskInfo where taskInfoID = %d", self.recordIDToEdit];

    NSArray *results = [[NSArray alloc] initWithArray:[self.dbManager loadDataFromDB:query]];

    self.taskName.text = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"taskName"]];
    self.taskDescription.text = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"taskDescription"]];
    self.deadline.text = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"deadline"]];
    self.priority.text = [[results objectAtIndex:0] objectAtIndex:[self.dbManager.arrColumnNames indexOfObject:@"priority"]];
}

#pragma mark - UITextFieldDelegate methods
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIPickerViewDataSourse methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.pickerdata.count;
}

#pragma mark - UIPickerViewDelegate methods
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return self.pickerdata[row];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    //NSLog(@"User have chosen %@",self.pickerdata[row]);
    self.priority.text = [NSString stringWithFormat:@"%@",self.pickerdata[row]];
}


@end
