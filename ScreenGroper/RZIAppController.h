//
//  RZIAppController.h
//  ScreenGroper
//
//  Created by Dylan Smith on 1/21/14.
//  Copyright (c) 2014 Rhizome Industries LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RZIAppController : NSObject

@property (nonatomic, strong) IBOutlet NSMenu *statusMenu;
@property (nonatomic, strong) NSStatusItem *statusItem;
@property (nonatomic, strong) NSImage *statusImage;
@property (nonatomic, strong) NSImage *statusImageHighlight;

-(IBAction)captureSafariURL:(id)sender;
@end
