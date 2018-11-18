//
//  ViewController.h
//  NCMDumper
//
//  Created by Lakr Sakura on 2018/11/18.
//  Copyright © 2018年 Lakr Sakura. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController
@property (weak) IBOutlet NSTextField *contentText;
@property (weak) IBOutlet NSTextField *contentPath;


@end

@interface VCWindowController : NSWindowController<NSWindowDelegate>\


@end

NSString *getOutputOfThisCommand(NSString *command, double timeOut);
