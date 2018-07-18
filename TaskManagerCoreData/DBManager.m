//
//  DBManager.m
//  TaskManagerCoreData
//
//  Created by Nataliya Murauyova on 7/17/18.
//  Copyright © 2018 Nataliya Murauyova. All rights reserved.
//

#import "DBManager.h"


@interface DBManager()
@property (strong,nonatomic) NSString* documentsDirectory;
@property(strong,nonatomic) NSString* databaseFileName;
@property(strong,nonatomic) NSMutableArray* results;

-(void)copyDatabaseIntoDocumentsDirectory;
-(void)runQuery:(const char*)query isQueryExecutable:(BOOL)queryExecutable;

@end

@implementation DBManager
-(instancetype) initWithFileName:(NSString *)dbFileName{
    self = [super init];
    if(self){
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.documentsDirectory = [paths objectAtIndex:0];
        self.databaseFileName = dbFileName;
        [self copyDatabaseIntoDocumentsDirectory];
    }
    return self;
}
-(void) copyDatabaseIntoDocumentsDirectory{
    NSString *destinationPath = [self.documentsDirectory stringByAppendingPathComponent:self.databaseFileName];
    if (![[NSFileManager defaultManager]  fileExistsAtPath:destinationPath]){
        NSString *sourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.databaseFileName];
        NSError *error;
        [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:destinationPath error:&error];
        
        if (error != nil){
            NSLog(@"%@", [error localizedDescription]);
        }
    }
    
}
-(void)runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable{
    sqlite3 *sqlite3DB;
    NSString *databasePath = [self.documentsDirectory stringByAppendingPathComponent:self.databaseFileName];
    
    if(self.results != nil){
        [self.results removeAllObjects];
        self.results = nil;
    }
    self.results = [[NSMutableArray alloc] init];
    
    if(self.arrColumnNames != nil){
        [self.arrColumnNames removeAllObjects];
        self.arrColumnNames = nil;
    }
    self.arrColumnNames = [[NSMutableArray alloc] init];
    
    BOOL openDataBaseResult = sqlite3_open([databasePath UTF8String], &sqlite3DB);
    if (openDataBaseResult == SQLITE_OK) {
        sqlite3_stmt *compiledStatement;
        
        BOOL prepareStatementResult = sqlite3_prepare_v2(sqlite3DB, query, -1, &compiledStatement, NULL);
        if(prepareStatementResult == SQLITE_OK){
            if (!queryExecutable) {
                NSMutableArray *arrDataRow;
                while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                    arrDataRow = [[NSMutableArray alloc] init];
                    int totalColumns = sqlite3_column_count(compiledStatement);
                    for (int i=0; i<totalColumns; i++){
                        char *databaseDataAsChars = (char*) sqlite3_column_text(compiledStatement, i); 
                        
                        
                        if (databaseDataAsChars != NULL){
                            [arrDataRow addObject:[NSString stringWithUTF8String:databaseDataAsChars]];
                        }
                        if(self.arrColumnNames.count != totalColumns){
                            databaseDataAsChars = (char*)sqlite3_column_name(compiledStatement, i);
                            [self.arrColumnNames addObject:[NSString stringWithUTF8String:databaseDataAsChars]];
                        }
                    }
                    if(arrDataRow>0){
                        [self.results addObject:arrDataRow];
                    }
                }
                
            }
            else {
                int execQueryResults = sqlite3_step(compiledStatement);
                if (execQueryResults == SQLITE_DONE){
                    self.affectedRows = sqlite3_changes(sqlite3DB);
                    self.lastInsertedRowID = sqlite3_last_insert_rowid(sqlite3DB);
                } else {
                    NSLog(@"DB Error: %s", sqlite3_errmsg(sqlite3DB));
                }
            }
        } else{
            NSLog(@"%s",sqlite3_errmsg(sqlite3DB));
        }
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(sqlite3DB);
}

-(NSArray*)loadDataFromDB:(NSString *)query{
    [self runQuery:[query UTF8String] isQueryExecutable:NO];
    return (NSArray*)self.results;
}

-(void)executeQuery:(NSString *)query{
    [self runQuery:[query UTF8String] isQueryExecutable:YES];
}
@end
