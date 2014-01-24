//
//  RZIAppController.m
//  ScreenGroper
//
//  Created by Dylan Smith on 1/21/14.
//  Copyright (c) 2014 Rhizome Industries LLC. All rights reserved.
//

#import "RZIAppController.h"
#import "MASShortcutView.h"
#import "MASShortcutView+UserDefaults.h"
#import "MASShortcut+UserDefaults.h"
#import "MASShortcut+Monitoring.h"
#include <Python.h>

NSString *const RZIPreferenceKeyShortcut = @"ScreenGroperShortcut";
NSDictionary static *RZIWidths;
typedef enum {
    MOBILE = 320,
    TABLET = 768,
    DESKTOP = 1280
} screenWidths;

@implementation RZIAppController

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.shortcutView.associatedUserDefaultsKey = RZIPreferenceKeyShortcut;
}

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
    NSString *widthKey = [[NSString alloc] initWithString:[sender title]];
    _width = [RZIWidths objectForKey:widthKey];
    
    _url = [[NSString alloc] initWithString:[self safariURL]];
    if ([_url length] == 0) {
        [[NSAlert alertWithMessageText:NSLocalizedString(@"Nothing to Grope.\nPlease open a URL in Safari.", @"Alert message for constant shortcut")
                         defaultButton:NSLocalizedString(@"OK", @"Default button for the alert on constant shortcut")
                       alternateButton:nil otherButton:nil informativeTextWithFormat:@""] runModal];
    } else {
      [self runScript:@"webkit2png"];
    }
}

- (NSString *)safariURL
{
    NSDictionary *dict;
    NSAppleEventDescriptor *result;
    
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:
                             @"\ntell application \"Safari\"\n\tget URL of document 1\nend tell\n"];
    
    result = [script executeAndReturnError:&dict];
    
    if ((result != nil) && ([result descriptorType] != kAENullEvent)) {
        return [result stringValue];
    }
    
    return @"";
}

-(void) runScript:(NSString*)scriptName
{
    NSTask *task;
    task = [[NSTask alloc] init];
    task.launchPath = @"/usr/bin/python";
    
//    NSArray *arguments;
    NSString* newpath = [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] privateFrameworksPath], scriptName];
    
//    NSString *desktop = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *desktop = [@"~/Desktop" stringByExpandingTildeInPath];
//    task.arguments = @[newpath, [NSString stringWithFormat:@"-W %@ -z 2.0 --delay=1 -F -D %@ %@", _width, desktop, _url]];
//    NSArray *arguments = @[newpath, [NSString stringWithFormat:@"-W %@ -z 2.0 --delay=1 -F -D %@ %@", _width, desktop, _url]];
    NSArray *arguments = @[newpath, [NSString stringWithFormat:@"-W %@", _width], @"-z 2.0", @"-F", [NSString stringWithFormat:@"-D %@", desktop], [NSString stringWithFormat:@"%@", _url]];
//    NSArray *arguments = @[[NSString stringWithFormat:@"%@ -W %@ -z 2.0 --delay=1 -F -D %@ %@", newpath, _width, desktop, _url]];
    task.arguments = arguments;
    NSLog(@"args = %@", arguments);
    task.arguments = arguments;
//    task.arguments = @[newpath, [NSString stringWithFormat:@"%@", _url]];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    [task setStandardInput:[NSPipe pipe]];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *string;
    string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    NSLog (@"script returned:\n%@", string);
}

- (id)init
{
    self = [super init];
    if (self) {
        [self registerHotKey];
        RZIWidths = @{
                      @"Mobile": [NSNumber numberWithInt:MOBILE],
                      @"Tablet": [NSNumber numberWithInt:TABLET],
                      @"Desktop": [NSNumber numberWithInt:DESKTOP]
                    };
    }
    return self;
}

- (void)registerHotKey
{
    MASShortcut *shortcut = [MASShortcut shortcutWithKeyCode:kVK_ANSI_5 modifierFlags:NSCommandKeyMask | NSControlKeyMask | NSShiftKeyMask];
    
    self.shortcutView.associatedUserDefaultsKey = RZIPreferenceKeyShortcut;
//    [MASShortcut registerGlobalShortcutWithUserDefaultsKey:RZIPreferenceKeyShortcut handler:^{
        // Let me know if you find a better or more convenient API.
//    }];
    [MASShortcut addGlobalHotkeyMonitorWithShortcut:shortcut handler:^{
        [_statusItem popUpStatusItemMenu:_statusMenu];
//        NSString *msg = [[NSString alloc] initWithFormat:@"%@ has been pressed.", shortcut];
//        [[NSAlert alertWithMessageText:NSLocalizedString(msg, @"Alert message for constant shortcut")
//                         defaultButton:NSLocalizedString(@"OK", @"Default button for the alert on constant shortcut")
//                       alternateButton:nil otherButton:nil informativeTextWithFormat:@""] runModal];
    }];
}

@end
