//
//  TaskDetailViewController.h
//  TaskManagerCoreData
//
//  Created by Nataliya Murauyova on 7/16/18.
//  Copyright © 2018 Nataliya Murauyova. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "TaskViewController.h"
#import "DBManager.h"



@interface TaskDetailViewController : UIViewController <UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
@property (strong, nonatomic) IBOutlet UITextField *taskName;
@property (strong, nonatomic) IBOutlet UITextField *taskDescription;
@property (strong, nonatomic) IBOutlet UITextField *deadline;
@property (strong, nonatomic) IBOutlet UITextField *priority;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;
@property(strong,nonatomic) NSManagedObject *task;
@property(assign,nonatomic) BOOL switchState;


@property(nonatomic) int recordIDToEdit;
@property(strong,nonatomic) NSManagedObject *rowToEdit;


- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;


@end
