//
//  GrayFocus.m
//  GrayFocus
//
//  Created by Andy Matuschak on 8/5/10.
//  Updated by Wolfgang Baird on 4/23/16.
//
//  Copyright 2010 Andy Matuschak. All rights reserved.
//

@import AppKit;
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

NSArray* GF_addFilter(NSArray* gray, NSArray* def)
{
    NSMutableArray *newFilters = [[NSMutableArray alloc] initWithArray:def];
    [newFilters addObjectsFromArray:gray];
    NSArray *result = [newFilters copy];
    return result;
}

@interface Grayifier : NSObject
@end

@implementation Grayifier

NSArray         *_grayFilters;
static void     *filterCache = &filterCache;
static void     *isActive = &isActive;

+ (void)load
{
    NSArray *blacklist = @[@"com.apple.notificationcenterui", @"com.google.Chrome", @"com.google.Chrome.canary"];
    NSString *appID = [[NSBundle mainBundle] bundleIdentifier];
    if (![blacklist containsObject:appID])
    {
        CIFilter *filt = [CIFilter filterWithName:@"CIColorMonochrome"];
        [filt setDefaults];
        [filt setValue:[CIColor colorWithRed:.3 green:.3 blue:.3 alpha:1] forKey:@"inputColor"];
        
        CIFilter *filt2 = [CIFilter filterWithName:@"CIGammaAdjust"];
        [filt2 setDefaults];
        [filt2 setValue:[NSNumber numberWithFloat:0.3] forKey:@"inputPower"];
        
        _grayFilters = [NSArray arrayWithObjects:filt, filt2, nil];
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(GF_grayWindow:) name:NSWindowDidResignKeyNotification object:nil];
        [center addObserver:self selector:@selector(GF_grayWindow:) name:NSWindowDidResignMainNotification object:nil];
        [center addObserver:self selector:@selector(GF_restoreColor:) name:NSWindowDidBecomeMainNotification object:nil];
        [center addObserver:self selector:@selector(GF_restoreColor:) name:NSWindowDidBecomeKeyNotification object:nil];
        
        NSLog(@"GrayFocus loaded...");
    }
}

+ (void)GF_grayWindow:(NSNotification *)note
{
    NSWindow *win = note.object;
    if (![objc_getAssociatedObject(win, isActive) boolValue]) {
        NSArray *_defaultFilters = [[win.contentView superview] contentFilters];
        objc_setAssociatedObject(win, filterCache, _defaultFilters, OBJC_ASSOCIATION_RETAIN);
        [[win.contentView superview] setWantsLayer:YES];
        [[win.contentView superview] setContentFilters:GF_addFilter(_grayFilters, _defaultFilters)];
        objc_setAssociatedObject(win, isActive, [NSNumber numberWithBool:true], OBJC_ASSOCIATION_RETAIN);
    }
}

+ (void)GF_restoreColor:(NSNotification *)note
{
    NSWindow *win = note.object;
    if ([objc_getAssociatedObject(win, isActive) boolValue]) {
        [[win.contentView superview] setWantsLayer:YES];
        [[win.contentView superview] setContentFilters:objc_getAssociatedObject(win, filterCache)];
        objc_setAssociatedObject(win, isActive, [NSNumber numberWithBool:false], OBJC_ASSOCIATION_RETAIN);
    }
}

@end
