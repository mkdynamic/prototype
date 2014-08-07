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
#import "LTPixelAlign.h"
#import "MKZoomView.h"
@class MKWidget;
@class MKDocument;

@interface MKDrawView : MKZoomView {
    IBOutlet NSTextField *textEditor;
	IBOutlet NSArrayController *dataSource;
@private
    BOOL editingWidget;
    MKWidget *hoverWidget;
    BOOL preventHoverHandles;
    NSArray *selectedWidgetsAtMarqueeStart;
    NSIndexSet *deferredSetSelection;
    NSIndexSet *deferredAddSelection;
    NSIndexSet *deferredRemoveSelection;
    BOOL didMouseDragWidgets;
	MKWidget *_dragWidget;
    MKWidget *textEditingWidget;
	NSPoint mouseDownPoint;
	NSPoint dragStartPoint;
	NSPoint marqueeStartPoint;
	NSInteger dragState;
    BOOL isFixedResizeAspectRatio;
    float fixedResizeAspectRatio;
    
    NSArray *snapLinesX;
    NSArray *snapLinesY;
    
    float gridSize;
}

@property (readwrite, retain) NSArrayController *dataSource;
@property BOOL preventHoverHandles;
@property BOOL isFixedResizeAspectRatio;
@property int outputMode; // 0 = screen, 1 = print, 2 = data (pdf)

- (BOOL)control:(NSControl *)control 
       textView:(NSTextView *)textView 
doCommandBySelector:(SEL)commandSelector;
- (void)textEditingStart;
- (IBAction)textEditingFinish:(id)sender;
- (NSUndoManager *)docUndoManager;

// FIXME broken
//- (NSPoint)snappedPointForDraggingWidgetWithPoint:(NSPoint)point 
//                                            andSize:(NSSize)size;

/* export */

- (NSData *)pdfData;
- (NSData *)imageData:(CFStringRef)type;

@end
