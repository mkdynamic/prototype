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

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
@class MKDrawView;

@interface MKWindowController : NSWindowController <NSSplitViewDelegate> {
@private
    MKDrawView *drawView;
	NSArrayController *graphicsController;
    NSSearchField *search;
    IBOutlet NSSegmentedControl *filter;
    IBOutlet NSArrayController *browserArrayController;
    BOOL shiftKey;
    IBOutlet NSScrollView *scrollView;
    
    IBOutlet NSSplitView *splitView;
    IBOutlet NSSplitView *bottomSplitView;
    IBOutlet NSSplitView *topSplitView;
    IBOutlet NSSplitView *sideView;
   // IBOutlet NSView *contentView;
    
    NSMutableDictionary *lengthsByViewIndex;
	NSMutableDictionary *viewIndicesByPriority;
    
    IBOutlet NSComboBox *spacingStrategy;
    int spacingPixels;
    
    IBOutlet NSViewController *propertiesViewController;
    
   
}

@property IBOutlet NSArrayController *graphicsController;
@property IBOutlet MKDrawView *drawView;
@property IBOutlet NSSearchField *search;

- (IBAction)zoomToFit:(id)sender;
- (IBAction)zoomToFitSelection:(id)sender;
- (NSUndoManager *)docUndoManager;

- (IBAction)spacingStrategyChanged:(id)sender;
- (int)spacingPixels;
- (NSString *)spacingStrategy;

- (IBAction)searched:(id)sender;
- (IBAction)filtered:(id)sender;

@end
