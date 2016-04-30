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

@interface Grayifier : NSObject
@end

@implementation Grayifier

bool _filtersAdded = false;
NSArray *_filters;

+ (void)load
{
    NSArray *blacklist = @[@"com.apple.notificationcenterui"];
    NSString *appID = [[NSBundle mainBundle] bundleIdentifier];
    if (![blacklist containsObject:appID])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wb_grayWindow:) name:NSWindowDidResignKeyNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wb_grayWindow:) name:NSWindowDidResignMainNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wb_restoreColor:) name:NSWindowDidBecomeMainNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wb_restoreColor:) name:NSWindowDidBecomeKeyNotification object:nil];
        NSLog(@"Grayifier loaded...");
    }
}

+ (void)wb_grayWindow:(NSNotification *)note
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

+ (void)wb_restoreColor:(NSNotification *)note
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
