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

#import "MKWindowController.h"
#import "MKAppController.h"
#import "MKDrawView.h"
#import "MKWidget.h"
#import "MKGroupWidget.h"
#import "MKWidgetElement.h"
#import "INAppStoreWindow.h"
#import "MKCenteringDocumentView.h"
#import "MKWindow.h"

#define LEFT_PANE_WIDTH 275

@interface MKWindowController ()

- (void)setSpacingStrategies;

@end

@implementation MKWindowController

@synthesize graphicsController, drawView, search;

- (id)init {
    self = [super initWithWindowNibName:@"Document"];
    if (self) {
        shiftKey = NO;
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self updateBrowserPredicate];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    spacingPixels = 0;
    [self setSpacingStrategies];
    [spacingStrategy selectItemAtIndex:0];
    
    [splitView setDelegate:(id)self];
    [bottomSplitView setDelegate:(id)self];
    [topSplitView setDelegate:(id)self];
    
    NSSize s;
    NSView *v;
    
    v = [[splitView subviews] objectAtIndex:0];
    s = [v frame].size;
    s.width = LEFT_PANE_WIDTH;
    [v setFrameSize:s];
    
    v = [[bottomSplitView subviews] objectAtIndex:0];
    s = [v frame].size;
    s.width = LEFT_PANE_WIDTH;
    [v setFrameSize:s];
    
    
    v = [[topSplitView subviews] objectAtIndex:0];
    s = [v frame].size;
    s.width = LEFT_PANE_WIDTH;
    [v setFrameSize:s];
    
    
    INAppStoreWindow *w = (INAppStoreWindow *)self.window;

    w.titleBarHeight = 36.0;
    w.centerFullScreenButton = YES;
    w.fullScreenButtonRightMargin = 5.0f;
    [w.titleBarView addSubview:topSplitView];
    [topSplitView setFrame:[w.titleBarView bounds]];
    
    // wrap draw view in a centering document view
    MKCenteringDocumentView *centeringDocumentView = [[MKCenteringDocumentView alloc] initWithFrame:[[scrollView contentView] bounds]];
    NSView *oldDocumentView = [scrollView documentView];
    [scrollView setDocumentView:centeringDocumentView];
    [centeringDocumentView setDocumentView:oldDocumentView];
    
    [[self window] setInitialFirstResponder:self.drawView];
}

- (void)windowDidBecomeMain:(NSNotification *)notification {
    MKAppController *ac = [NSApp delegate];
    ac.docWindowController = self;
}

- (void)windowWillClose:(NSNotification *)notification {
    MKAppController *ac = [NSApp delegate];
    if (ac.docWindowController == self) {
        ac.docWindowController = nil;
    }
}

- (NSUndoManager *)docUndoManager {
   return [[self document] undoManager];
}

/* keyboard */

- (void)flagsChanged:(NSEvent *)anEvent {
    if (([anEvent modifierFlags] & NSShiftKeyMask) != 0) {
        drawView.isFixedResizeAspectRatio = YES;
        shiftKey = YES;
    } else {
        drawView.isFixedResizeAspectRatio = NO;
        
        // oh, the polish... this is so that if we were hiding hover handles previously
        // due to shift key being down, we reshow them on shift key up. nobody will care but me :)
        if (self.drawView.preventHoverHandles) {
            self.drawView.preventHoverHandles = NO;
            [self.drawView setNeedsDisplay:YES];
        }
        
        shiftKey = NO;
    }
}

- (void)keyDown:(NSEvent *)theEvent {
    // Arrow keys are associated with the numeric keypad
    if ([theEvent modifierFlags] & NSNumericPadKeyMask) {
        [self interpretKeyEvents:[NSArray arrayWithObject:theEvent]];
    } else {
        [super keyDown:theEvent];
    }
}

/* mouse */

//- (void)mouseDown:(NSEvent *)theEvent {
//    // NOTE why was this here? breaks text editing first responder on dbl click
//    //[[self window] makeFirstResponder:self.drawView];
//    [super mouseDown:theEvent];
//}

/* zoom */

// TODO should move to draw view
- (void)zoomToFit:(id)sender {
    NSRect r = [MKWidget widgetsFrame:self.graphicsController.arrangedObjects];
    [self.drawView zoomViewToPaddedRect:r];
}

- (void)zoomToFitSelection:(id)sender {
    NSRect r = [MKWidget widgetsFrame:self.graphicsController.selectedObjects];
    [self.drawView zoomViewToPaddedRect:r];
}

/* split view delegate */

-(void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize
{
    CGFloat dividerThickness = [sender dividerThickness];
    NSRect leftRect = [[[sender subviews] objectAtIndex:0] frame];
    NSRect rightRect = [[[sender subviews] objectAtIndex:1] frame];
    NSRect newFrame = [sender frame];
    
 	leftRect.size.height = newFrame.size.height;
	leftRect.origin = NSMakePoint(0, 0);
    //leftRect.size.width = 275.f;
	rightRect.size.width = newFrame.size.width - leftRect.size.width - dividerThickness;
	rightRect.size.height = newFrame.size.height;
	rightRect.origin.x = leftRect.size.width + dividerThickness;
    
 	[[[sender subviews] objectAtIndex:0] setFrame:leftRect];
	[[[sender subviews] objectAtIndex:1] setFrame:rightRect];
}

- (NSRect)splitView:(NSSplitView *)theSplitView 
      effectiveRect:(NSRect)proposedEffectiveRect 
       forDrawnRect:(NSRect)drawnRect
   ofDividerAtIndex:(NSInteger)dividerIndex
{
    return NSZeroRect;
}

// spacing

- (void)getSpacingStrategyValue {
    NSString *value = [spacingStrategy stringValue];
    
    // parse pixel value
    NSCharacterSet* nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSString* digitString = [value stringByTrimmingCharactersInSet:nonDigits];
    if (![value isEqualToString:@"Evenly"] && ![digitString isEqualToString:@""]) {
        spacingPixels = (int)[digitString longLongValue];
    }
    
    // set list of available options to 'Equally' and the last pixel value
    [self setSpacingStrategies];
    
    // set selected value to picked options
    if ([value isEqualToString:@"Evenly"] || [digitString isEqualToString:@""]) {
        [spacingStrategy selectItemAtIndex:0];
    } else {
        [spacingStrategy selectItemAtIndex:1];
    }
}

- (void)spacingStrategyChanged:(id)sender {
    [self getSpacingStrategyValue];
}

- (int)spacingPixels {
    return spacingPixels;
}

- (NSString *)spacingStrategy {
    [self getSpacingStrategyValue];
    
    if ([[spacingStrategy stringValue] isEqualToString:@"Evenly"]) {
        return @"evenly";
    } else {
        return @"pixels";
    }
}

- (void)setSpacingStrategies {
    [spacingStrategy removeAllItems];
    NSArray *items = [NSArray arrayWithObjects:@"Evenly", 
                      [NSString stringWithFormat:@"%dpx", spacingPixels], 
                      nil];
    [spacingStrategy addItemsWithObjectValues:items];
}


// filtering

- (void)updateBrowserPredicate
{
    NSPredicate *filterPredicate;
    switch ([filter selectedSegment]) {
        case 0:
            filterPredicate = [NSPredicate predicateWithFormat:@"SELF.filters CONTAINS 'web'"];
            break;
        case 1:
            filterPredicate = [NSPredicate predicateWithFormat:@"SELF.filters CONTAINS 'mac'"];
            break;
        case 2:
            filterPredicate = [NSPredicate predicateWithFormat:@"SELF.filters CONTAINS 'ios'"];
            break;
    }
    
    NSString *query = [NSString stringWithFormat:@"*%@*", [search stringValue]];
    NSPredicate *queryPredicate = [NSPredicate predicateWithFormat:
                                   @"SELF.keywords LIKE[cd] %@", query];
    
    NSPredicate *predicate;
    predicate = [NSCompoundPredicate andPredicateWithSubpredicates:
                 [NSArray arrayWithObjects:filterPredicate, queryPredicate, nil]];
    
    [browserArrayController setFilterPredicate:predicate];
}

- (void)searched:(id)sender
{
    [self updateBrowserPredicate];
}

- (void)filtered:(id)sender
{
    [self updateBrowserPredicate];

}

@end
