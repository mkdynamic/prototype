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

#import "MKPropertiesViewController.h"
#import "MKPropertiesView.h"
#import "MKWindowController.h"
#import "MKAppController.h"
#import "MKWidget.h"
#import "MKImageWidget.h"
#import "MKWidgetElement.h"
#import "MKGroupWidget.h"

@interface MKPropertiesViewController ()
- (MKAppController *)appController;
- (MKWindowController *)docWindowController;
- (NSArrayController *)graphicsController;
@end

@implementation MKPropertiesViewController
- (MKAppController *)appController
{
    return (MKAppController *)[NSApp delegate];
}

- (MKWindowController *)docWindowController
{
    return (MKWindowController *)([self appController]).docWindowController;
}

- (NSArrayController *)graphicsController
{
    return (NSArrayController *)([self docWindowController]).graphicsController;
}

- (void)awakeFromNib
{
    
    
    
    NSArray *keyPaths = [NSArray arrayWithObjects:
                         @"docWindowController.graphicsController.selectedObjects",
                         @"docWindowController.graphicsController.selectedObjects.fontStyleMask",
                         nil];
    
    for (NSString *keyPath in keyPaths) {
        [[self appController] addObserver:self 
                                    forKeyPath:keyPath
                                       options:(NSKeyValueObservingOptionNew) 
                                       context:nil];
    }
    
    
  //  [((MKPropertiesView *)[self view]).fillColorWell addObserver:self forKeyPath:@"color options:<#(NSKeyValueObservingOptions)#> context:<#(void *)#>
}

- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object 
                        change:(NSDictionary *)change 
                       context:(void *)context
{
    NSArrayController *ac = [self graphicsController];
    
    NSUInteger mask = 0;
    MKWidget *widget;
    for (widget in [ac selectedObjects]) {
        // FIXME grouped widgets return NSPlaceholders which fuck this up
        mask |= widget.fontStyleMask;
    }
    
    for (NSInteger i = 0; i < [fontStyles segmentCount]; i++) {
        NSUInteger tag = [[fontStyles cell] tagForSegment:i];
        [fontStyles setSelected:((tag & mask) > 0 ? YES : NO) forSegment:i];
    }
    
    NSMutableSet *selectedClasses = [NSMutableSet set];
    for (widget in [ac selectedObjects]) {
        if ([widget isKindOfClass:[MKGroupWidget class]]) {
            for (MKWidgetElement *el in ((MKGroupWidget *)widget).groupedWidgets) {
                [selectedClasses addObject:[el.groupedWidget className]];
            }
        } else {
            [selectedClasses addObject:[widget className]];
        }
    }
    
    [(MKPropertiesView *)[self view] showPropertiesForWidgetKinds:selectedClasses];
}

- (IBAction)fontStyleChanged:(id)sender
{
    NSArrayController *ac = [self graphicsController];
    NSUInteger segment = [fontStyles selectedSegment];
    NSUInteger tag = [[fontStyles cell] tagForSegment:segment];
    BOOL isSelected = [fontStyles isSelectedForSegment:segment];
    
    for (MKWidget *widget in [ac selectedObjects]) {
        if (isSelected) {
            widget.fontStyleMask |= tag; // apply mask
        } else {
            widget.fontStyleMask -= widget.fontStyleMask & tag; // remove mask
        }
    }
}

- (IBAction)chooseFile:(id)sender
{
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    [panel setAllowedFileTypes:[NSImage imageFileTypes]];
    
    [panel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSArrayController *ac = [self graphicsController];
            for (MKImageWidget *widget in [ac selectedObjects]) {
                widget.imagePath = panel.URL;
            } 
        }
    }];
}

- (void)chooseIcon:(id)sender {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(iconPicked:)
                                                 name:@"IconPicked"
                                               object:nil];
    [[self appController] showIconPicker:self];
}

- (void)strokeColorChanged:(id)sender
{
  //  NSLog(@"stroke color changed");
}

- (void)fillColorChanged:(id)sender
{
    //NSLog(@"fill color changed");
}

- (void)iconPicked:(NSNotification *)note
{
    NSString *filename = (NSString *)[note object];
    if (filename) {
        NSArrayController *ac = [self graphicsController];
        for (MKImageWidget *widget in [ac selectedObjects]) {
            widget.sketch = NO;
            widget.imagePath = [NSURL fileURLWithPath:filename];
        } 
    }
}
@end
