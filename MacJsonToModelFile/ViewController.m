//
//  ViewController.m
//  MacJsonToModelFile
//
//  Created by gupengling on 2017/4/1.
//  Copyright © 2017年 gupengling. All rights reserved.
//

#import "ViewController.h"
#import "NSString+Empty.h"



@interface ViewController() {

    dispatch_group_t group;
    dispatch_queue_t globalQueue;
    
@private
    NSMutableArray *arrH,*arrM,*arrAddClass;
    BOOL hasManyFile;

}
@property (weak) IBOutlet NSTextField *txfFileName;
@property (weak) IBOutlet NSTextField *txfFartherObjName;
@property (unsafe_unretained) IBOutlet NSTextView *txvDetail;
@property (weak) IBOutlet NSButton *btnCheck;

@end
@implementation ViewController
-(void)runWriteWithContent:(NSString*)content path:(NSString*)path
{
    //用上面的目录创建这个文件
    NSString *deskTopLocation=[NSHomeDirectoryForUser(NSUserName()) stringByAppendingPathComponent:@"Desktop/CreatFiles"];
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    BOOL successF = [fileManager createDirectoryAtPath:deskTopLocation withIntermediateDirectories:YES attributes:nil error:nil];
    if (successF) {
        NSLog(@"successF");
    }
    
    BOOL success=[fileManager createFileAtPath:path contents:nil attributes:nil];
    if (success) {
        NSLog(@"success");
    }
    
    //打开上面创建的那个文件
    NSFileHandle *fileHandle=[NSFileHandle fileHandleForWritingAtPath:path];
    [fileHandle seekToEndOfFile];
    NSData *data=[content dataUsingEncoding:NSUTF8StringEncoding];
    [fileHandle writeData:data];//写入文件
    [fileHandle closeFile];//关闭文件
    
}

- (void)createFileWithDict:(NSDictionary*)dict fileName:(NSString*)fileName fartherClassName:(NSString *)fartherClassName {
    dispatch_group_enter(group);
    dispatch_group_async(group, globalQueue, ^{
        
        NSString *fartherName = @"NSObject";
        if (![NSString isBlank:fartherClassName]) {
            fartherName = fartherClassName;
        }
        
        
        //以下两行生成一个文件目录
        NSString *deskTopLocation=[NSHomeDirectoryForUser(NSUserName()) stringByAppendingPathComponent:@"Desktop/CreatFiles"];
        NSString *hFilePath=[deskTopLocation stringByAppendingPathComponent: [NSString stringWithFormat:@"%@.h",fileName]];
        NSString *mFilePath=[deskTopLocation stringByAppendingPathComponent: [NSString stringWithFormat:@"%@.m",fileName]];
        
        
        NSString *hContent=@"";
        if (dict==nil) {
            
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:@"创建失败"];
            [alert addButtonWithTitle:@"取消"];
            
            [alert setAlertStyle:NSAlertStyleWarning];
            [alert beginSheetModalForWindow:nil modalDelegate:nil didEndSelector:nil contextInfo:nil];
            
            return;
            
        }
        for (NSString *key in dict.allKeys) {
            
            id value=dict[ key];
            NSString *type=[[value class]description];
            NSLog(@"class======%@",type);
            NSString *content=@"";
            if ([type rangeOfString:@"NSCFBoolean"].length>0) {
                //Bool类型
                content =[NSString stringWithFormat:@"@property (nonatomic, assign) BOOL %@;\n",key];
            }else if ([type rangeOfString:@"NSArray"].length>0)
            {//数组
                
                NSString *arrFileName = [NSString stringWithFormat:@"%@%@",fileName,[key getFirstLetterFromString]];
                
                content =[NSString stringWithFormat:@"@property (nonatomic, strong) NSArray <%@ *>*%@;\n",arrFileName,key];
                
                NSArray *arr=value;
                if (arr.count>0) {
                    if ([arr.firstObject isKindOfClass:[NSDictionary class]]) {
                        [arrAddClass addObject:[NSString stringWithFormat:@"@class %@;\n",arrFileName]];
                        [self createFileWithDict:arr.firstObject fileName:arrFileName fartherClassName:fartherName];
                        
                    }
                }
            }else if ([type rangeOfString:@"NSDictionary"].length>0){
                //字典
                NSString *dicFileName = [NSString stringWithFormat:@"%@%@",fileName,[key getFirstLetterFromString]];
                content =[NSString stringWithFormat:@"@property (nonatomic, strong) %@ *%@;\n",dicFileName,key];
                NSDictionary *dic = value;
                if ([[dic allKeys] count] > 0) {
                    [arrAddClass addObject:[NSString stringWithFormat:@"@class %@;\n",dicFileName]];
                    [self createFileWithDict:dic fileName:dicFileName fartherClassName:fartherName];
                }
                
                
            }else if([type rangeOfString:@"NSCFNumber"].length > 0) {
                content =[NSString stringWithFormat:@"@property (nonatomic, assign)  NSInteger %@;\n",key];
            }
            else{
                content =[NSString stringWithFormat:@"@property (nonatomic, copy)  NSString *%@;\n",key];
            }
            hContent=[hContent stringByAppendingString:content];
            
            
        }
        
        if (hasManyFile) {

            NSString *fileHeader= [NSString stringWithFormat:@"\n\n//\n// %@\n// Created by gupengling on %@\n//\n",[NSString stringWithFormat:@"%@.h",fileName],[NSDate date]];
            
            
            NSString *hFile1=@"\n\n#import <Foundation/Foundation.h>\n\n";
            NSString *hFile2=[NSString stringWithFormat:@"@interface %@ : %@\n\n\n",fileName,fartherName];
            
            NSString *fileFooter=@"\n\n@end\n\n\n";
            
            NSString *hFile=[NSString stringWithFormat:@"%@%@%@%@%@",fileHeader,hFile1,hFile2,hContent,fileFooter];
            [self runWriteWithContent:hFile path:hFilePath];
            
            
            
            fileHeader= [NSString stringWithFormat:@"\n\n//\n// %@\n// Created by gupengling on %@\n//\n",[NSString stringWithFormat:@"%@.m",fileName],[NSDate date]];
            NSString *mFile1=[NSString stringWithFormat:@"\n\n#import \"%@.h\"\n\n",fileName];
            NSString *mFile2=[NSString stringWithFormat:@"@implementation %@\n\n\n",fileName];
            NSString *mFile=[NSString stringWithFormat:@"%@%@%@%@",fileHeader,mFile1,mFile2,fileFooter];
            
            [self runWriteWithContent:mFile path:mFilePath];
            
        }else {
            [self logfileName:fileName Text:hContent fatherName:fartherName];
        }
        
        
        dispatch_group_leave(group);
    });

}
- (void)logfileName:(NSString *)fileName Text:(NSString *)text fatherName:(NSString *)fartherName {
    NSString *fileFooter = @"\n\n@end\n\n";
    
    NSString *hFile = [NSString stringWithFormat:@"@interface %@ : %@\n\n",fileName,fartherName];
    NSString *hFileText = [NSString stringWithFormat:@"%@%@%@\n\n",hFile,text,fileFooter];
    //    NSLog(@"生成的文件h ：\n%@\n",hFileText);
    [arrH addObject:hFileText];
    
    NSString *mFile = [NSString stringWithFormat:@"@implementation %@\n\n",fileName];
    
    NSString *mInit = [NSString stringWithFormat:@"- (instancetype)init {\n\tself = [super init];\n\tif (self) {\n\n\t}\n\treturn self;\n}\n"];
    
    NSString *mFileText = [NSString stringWithFormat:@"%@%@%@\n\n",mFile,mInit,fileFooter];
    //    NSLog(@"生成的文件m ：\n%@\n",mFileText);
    [arrM addObject:mFileText];
}

- (void)parseForFile:(NSString *)content {
    content = [content stringByReplacingOccurrencesOfString:@" " withString:@""];
    content = [content stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    NSString *regexStr1 = @"[0-9]+\"[a-zA-Z0-9]+";
    content =  [NSString replace1WithContent:content regexStr:regexStr1];
    NSString *regexStr2 = @"[^:][0-9]+[\\]\{\\}]";
    content =  [NSString replace2WithContent:content regexStr:regexStr2];
    content = [NSString stringWithFormat:@"{%@}",content];
    NSLog(@"%@",content);
    NSError *error = nil;
    NSDictionary *dict= [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:(NSJSONReadingMutableContainers) error:&error];
    if (error) {
        
    }else {
        NSString *fileName = self.txfFileName.stringValue;
        NSString *fartherName = self.txfFartherObjName.stringValue;
        
        [self createFileWithDict:dict fileName:fileName fartherClassName:fartherName];

        
        //以下两行生成一个文件目录
        NSString *deskTopLocation=[NSHomeDirectoryForUser(NSUserName()) stringByAppendingPathComponent:@"Desktop/CreatFiles"];
        __block NSString *hFilePath = [deskTopLocation stringByAppendingPathComponent: [NSString stringWithFormat:@"%@.h",fileName]];
        
        __block NSString *mFilePath = [deskTopLocation stringByAppendingPathComponent: [NSString stringWithFormat:@"%@.m",fileName]];
        
        
        NSString *fileHeaderH = [NSString stringWithFormat:@"\n\n//\n// %@\n// Created by gupengling on %@\n//\n",[NSString stringWithFormat:@"%@.h",fileName],[NSDate date]];
        NSString *hFile1 = @"\n\n#import <Foundation/Foundation.h>\n\n";
        
        __block NSString *hWrite = [NSString stringWithFormat:@"%@%@",fileHeaderH,hFile1];
        
        
        NSString *fileHeaderM = [NSString stringWithFormat:@"\n\n//\n// %@\n// Created by gupengling on %@\n//\n",[NSString stringWithFormat:@"%@.m",fileName],[NSDate date]];
        NSString *mFile1 = [NSString stringWithFormat:@"\n\n#import \"%@.h\"\n\n",fileName];
        
        __block NSString *mWrite = [NSString stringWithFormat:@"%@%@",fileHeaderM,mFile1];
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            if (hasManyFile) {
                NSLog(@"创建多个文件");
            }else {
                NSLog(@"创建单个文件");
                NSLog(@"\n%@\n%@\n",arrH,arrM);
//                NSArray *arrHFile = [[arrH reverseObjectEnumerator] allObjects];
//                NSLog(@"arrHFile = %@",arrHFile);
                
                for (NSString *add in arrAddClass) {
                    hWrite = [hWrite stringByAppendingString:add];
                    
                }
                hWrite = [hWrite stringByAppendingString:@"\n\n"];
                
                for (NSString *strH in arrH) {
                    hWrite = [hWrite stringByAppendingString:strH];
                }
                NSLog(@"hWrite = %@",hWrite);
                
                
//                NSArray *arrMFile = [[arrM reverseObjectEnumerator] allObjects];
//                NSLog(@"arrMFile = %@",arrMFile);
                
                for (NSString *strM in arrM) {
                    mWrite = [mWrite stringByAppendingString:strM];
                }
                NSLog(@"mWrite = %@",mWrite);
                [self runWriteWithContent:hWrite path:hFilePath];
                [self runWriteWithContent:mWrite path:mFilePath];
            }
            NSLog(@"finished");
            
            
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:@"创建成功"];
            //[alert setInformativeText:@"副标题"];
            [alert addButtonWithTitle:@"取消"];
            //[alert addButtonWithTitle:@"取消"];
            
            [alert setAlertStyle:NSAlertStyleWarning];
            [alert beginSheetModalForWindow:nil modalDelegate:nil didEndSelector:nil contextInfo:nil];

        });

        
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    
    [_txvDetail setString:@"\"school\": \"XX大学\", \"des\":{ \"sex\": \"男\", \"like\": \"篮球\", \"class\": \"初一\" }, \"pageSize\": 10, \"list\": [ { \"userId\": 33237, \"goodsTypeName\": \"我的天\", \"companyName\": \"YiMi公司\" } ], \"last\": false, \"first\": true"];

    arrH = [NSMutableArray array];
    arrM = [NSMutableArray array];
    arrAddClass = [NSMutableArray array];

    
    //dispatch_group_t
    group = dispatch_group_create();
    //dispatch_queue_t
    globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //dispatch_queue_t
//    globalQueue = dispatch_queue_create("my.concurrent.queue", DISPATCH_QUEUE_CONCURRENT);

}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

#pragma mark - button Clicked
- (IBAction)checkBtnClicked:(id)sender {
    hasManyFile = _btnCheck.state;
}
- (IBAction)createBtnClicked:(id)sender {
    [arrH removeAllObjects];
    [arrM removeAllObjects];
    [arrAddClass removeAllObjects];

    if (self.txfFileName.stringValue.length<=0) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"请输入创建的类名"];
        //[alert setInformativeText:@"副标题"];
        [alert addButtonWithTitle:@"取消"];
        //[alert addButtonWithTitle:@"取消"];
        
        [alert setAlertStyle:NSAlertStyleWarning];
        [alert beginSheetModalForWindow:nil modalDelegate:nil didEndSelector:nil contextInfo:nil];
        return;
    }
    
    if (![NSString isBlank:_txvDetail.string]) {
        [self parseForFile:_txvDetail.string];
    }
    
}

@end
