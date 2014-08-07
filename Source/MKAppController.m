// Copyright (c) 2014 Mark Dodwell.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
// documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
// Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "MKAppController.h"
#import "MKToolsController.h"
#import "MKIconPickerController.h"
#import "MKFractionToPercentTransformer.h"
#import "MKWidget.h"

@implementation MKAppController

@synthesize docWindowController, iconPickerController;

- (id)init
{
    self = [super init];
    if (self) {
        MKFractionToPercentTransformer *scaleToZoomTransformer = [[[MKFractionToPercentTransformer alloc] init] autorelease];
        [NSValueTransformer setValueTransformer:scaleToZoomTransformer 
                                        forName:@"MKScaleToZoomTransformer"];
    }
    return self;
}

- (NSArray *)widgetKinds
{
    
    return [MKWidget kinds];
}

static uint randomSeed;
+ (uint)randomSeed
{
    if (!randomSeed) {
        randomSeed = (uint)time(NULL);
    }
    
    return randomSeed;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    srandom([[self class] randomSeed]);
    
    // Register the preference defaults early.
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:NO], @"showGrid",
                                 [NSNumber numberWithBool:YES], @"snapToGrid",
                                 [NSNumber numberWithBool:YES], @"showSmartGuides",
                                 [NSNumber numberWithBool:YES], @"snapToSmartGuides",
                                 nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
 
    
    [NSColor setIgnoresAlpha:NO];
    [NSColorPanel sharedColorPanel];
    [[NSColorPanel sharedColorPanel] setShowsAlpha:NO];
    
    NSPrintInfo *printInfo = [NSPrintInfo sharedPrintInfo];
    [printInfo setVerticallyCentered:YES];
    [printInfo setHorizontallyCentered:YES];
    [printInfo setLeftMargin:20];
    [printInfo setRightMargin:20];
    [printInfo setTopMargin:20];
    [printInfo setBottomMargin:20];
    [NSPrintInfo setSharedPrintInfo:printInfo];
}

- (IBAction)showIconPicker:(id)sender
{
    if (!iconPickerController) {
        iconPickerController = [[MKIconPickerController alloc] initWithWindowNibName:@"IconPicker"];
    }
    
    [iconPickerController showWindow:sender];
}

@end
