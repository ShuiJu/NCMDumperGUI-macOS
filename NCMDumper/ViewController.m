//
//  ViewController.m
//  NCMDumper
//
//  Created by Lakr Sakura on 2018/11/18.
//  Copyright © 2018年 Lakr Sakura. All rights reserved.
//

#import "ViewController.h"

@interface VCWindowController()

@end

@implementation VCWindowController

- (BOOL)windowShouldClose:(id)sender {
    [NSApp hide:nil];
    return NO;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [_contentText becomeFirstResponder];
    NSError *error;
    NSBundle *myBundle = [NSBundle mainBundle];
    NSString *absPath= [myBundle pathForResource:@"ncmdump" ofType:NULL];
    if (![[NSFileManager defaultManager] fileExistsAtPath: @"/usr/local/bin/ncmdump"]) {
        [[NSFileManager defaultManager] copyItemAtPath:absPath toPath:@"/usr/local/bin/ncmdump" error:&error];
        if (error != nil) {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:@"NCMDumper GUI for macOS\n\n无法访问 /usr/local/bin/ \n请确定你有访问权限来安装dump帮助文件。"];
            [alert addButtonWithTitle:@"好"];
            [alert runModal];
            exit(2);
        }
    }
}

- (IBAction)doIt:(id)sender {
    
    NSError *error;
    BOOL thereIsJob = false;
    
    NSString *contentFilePath = [_contentText stringValue];
    NSArray *items = [contentFilePath componentsSeparatedByString:@"\n"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    documentsDirectory = [documentsDirectory stringByAppendingString:@"/NCMDumper/"];
    [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:true attributes:NULL error:NULL];
    
    NSString *commandFile = [documentsDirectory stringByAppendingString:@"dump.command"];
    [[NSFileManager defaultManager] removeItemAtPath:commandFile error:&error];
    
    int counter = 0;
    NSString *outputString = @"";
    
    NSString *ncmTempPath = [documentsDirectory stringByAppendingString:@"ncm"];
    [[NSFileManager defaultManager] createDirectoryAtPath:ncmTempPath withIntermediateDirectories:true attributes:NULL error:NULL];
    
    NSString *outDir = [_contentPath stringValue];
    if ([outDir  isEqual: @""]) {
        outDir = [documentsDirectory stringByAppendingString:@"mp3"];
    }
    [[NSFileManager defaultManager] createDirectoryAtPath:outDir withIntermediateDirectories:true attributes:NULL error:NULL];
    NSString *commandForCommand = [[NSString alloc] initWithFormat:@"cd %@ \n", outDir];
    
    while (items.count > counter) {
        if ([items[counter] rangeOfString:@".ncm"].location == NSNotFound) {
            if (counter == 0) {
                outputString = [[NSString alloc] initWithFormat: @"%@ 不是标准的NCM文件。" ,items[counter]];
            }else{
                outputString = [[NSString alloc] initWithFormat: @"%@\n%@ 不是标准的NCM文件。" ,outputString ,items[counter]];
            }
        }else{
            thereIsJob = true;
            NSString *thisName = @"";
            NSArray *splitForName = [items[counter] componentsSeparatedByString:@"/"];
            int nameC = 0;
            while (splitForName.count > nameC) {
                nameC ++;
            }
            thisName = splitForName[nameC - 1];
            NSString *target = [[NSString alloc] initWithFormat:@"%@/%@", ncmTempPath, thisName];
            [[NSFileManager defaultManager] copyItemAtPath:items[counter] toPath:target error:&error];
            NSArray *splitTargetForTerminal = [target componentsSeparatedByString:@" "];
            nameC = 0;
            NSString *targetC = splitTargetForTerminal[nameC];
            nameC = 1;
            while (splitTargetForTerminal.count > nameC) {
                targetC = [targetC stringByAppendingString: ([[NSString alloc] initWithFormat:@"\\ %@", splitTargetForTerminal[nameC]])];
                nameC ++;
            }
            NSString *command = [[NSString alloc] initWithFormat:@"/usr/local/bin/ncmdump %@\n", targetC];
            commandForCommand = [commandForCommand stringByAppendingString:command];
        }
        counter ++;
    }
    _contentText.stringValue = outputString;
    
    //[commandForCommand writeToFile:commandFile atomically:true encoding:NSUTF8StringEncoding error:&error];
    //getOutputOfThisCommand(@"/bin/chmod +x ~/Documents/NCMDumper/dump.command", 0.5);
    //[[NSWorkspace sharedWorkspace] openFile:commandFile];
    if (thereIsJob) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"即将进行处理，请耐心等待！"];
        [alert addButtonWithTitle:@"好"];
        [alert runModal];
    }
    getOutputOfThisCommand(commandForCommand, 300);
    if (thereIsJob) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"处理完成！"];
        [alert addButtonWithTitle:@"好"];
        [alert runModal];
    }
    [[NSFileManager defaultManager] removeItemAtPath:ncmTempPath error:&error];

}

- (IBAction)setDesktop:(id)sender {
    _contentPath.stringValue = @"~/Desktop/";
}

- (IBAction)clean:(id)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"清除缓存会直接删除位于文档的NCMDumper文件夹，请谨慎操作～"];
    [alert addButtonWithTitle:@"好"];
    [alert addButtonWithTitle:@"取消"];
    NSInteger button = [alert runModal];
    if (button == NSAlertFirstButtonReturn) {
        getOutputOfThisCommand(@"rm -rf ~/Documents/NCMDumper", 1);
    }
}


@end

NSString *getOutputOfThisCommand(NSString *command, double timeOut) {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];
    [task setArguments:[NSArray arrayWithObjects:@"-c", command,nil]];
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    [task launch];
    //[NSThread sleepForTimeInterval:timeOut];
    double timeController = 0.00;
    while ([task isRunning]) {
        [NSThread sleepForTimeInterval:0.01];
        timeController += 0.01;
        if (timeController > timeOut) {
            break;
        }
    }
    [task terminate];
    NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return result;
}
