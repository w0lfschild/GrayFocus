//
//  Grayifier.m
//  GrayFocus
//
//  Created by Andy Matuschak on 8/5/10.
//  Updated by Wolfgang Baird on 4/23/16.
//
//  Copyright 2010 Andy Matuschak. All rights reserved.
//

@import AppKit;
#import <QuartzCore/QuartzCore.h>
#import "Grayifier.h"

@implementation Grayifier

bool _filtersAdded = false;
NSArray *_filters;

+ (void)load
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(grayify:) name:NSWindowDidResignKeyNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(grayify:) name:NSWindowDidResignMainNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(colorize:) name:NSWindowDidBecomeMainNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(colorize:) name:NSWindowDidBecomeKeyNotification object:nil];
    
    NSLog(@"Grayifier loaded...");
}

+ (void)grayify:(NSNotification *)note
{
    if (!_filtersAdded) {
//        NSLog(@"Filter added");
//        Yes, apply grayscale filter
        
        CIFilter *filt = [CIFilter filterWithName:@"CIColorMonochrome"]; // CIImage
        [filt setDefaults];
        [filt setValue:[CIColor colorWithRed:.3 green:.3 blue:.3 alpha:1] forKey:@"inputColor"];
        
        CIFilter *filt2 = [CIFilter filterWithName:@"CIGammaAdjust"]; // CIImage
        [filt2 setDefaults];
        [filt2 setValue:[NSNumber numberWithFloat:0.3] forKey:@"inputPower"];
        
        NSWindow *win = note.object;
        _filters = [[win.contentView superview] contentFilters];
        [[win.contentView superview] setWantsLayer:YES];
        [[win.contentView superview] setContentFilters:[NSArray arrayWithObjects:filt, filt2, nil]];
        _filtersAdded = !_filtersAdded;
    }
}

+ (void)colorize:(NSNotification *)note
{
    if (_filtersAdded) {
//        NSLog(@"Filter removed");
//        Yes, remove grayscale filter
        
        NSWindow *win = note.object;
        [[win.contentView superview] setWantsLayer:YES];
        [[win.contentView superview] setContentFilters:_filters];
        _filtersAdded = !_filtersAdded;
    }
}

@end
