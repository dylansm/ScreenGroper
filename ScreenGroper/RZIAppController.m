//
//  RZIAppController.m
//  ScreenGroper
//
//  Created by Dylan Smith on 1/21/14.
//  Copyright (c) 2014 Rhizome Industries LLC. All rights reserved.
//

#import "RZIAppController.h"

@implementation RZIAppController

- (void)awakeFromNib
{
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:22];
    NSBundle *bundle = [NSBundle mainBundle];
    _statusImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"clario_statusmenu_icon" ofType:@"tiff"]];
    _statusImageHighlight = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"clario_statusmenu_icon-active" ofType:@"tiff"]];
    [_statusImage setBackgroundColor:[NSColor clearColor]];
    [_statusImageHighlight setBackgroundColor:[NSColor clearColor]];
    [_statusItem setImage:_statusImage];
    [_statusItem setAlternateImage:_statusImageHighlight];
    [_statusItem setMenu:_statusMenu];
}

- (IBAction)captureSafariURL:(id)sender
{
    NSLog(@"sender:%@", [sender parent]);
}

- (id)init
{
    self = [super init];
    if (self) {
        [self registerHotKey];
    }
    return self;
}

- (void)registerHotKey
{
    NSLog(@"registerring...");
}

@end
