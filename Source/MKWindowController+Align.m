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

#import "MKWindowController+Align.h"
#import "MKWidget.h"

typedef enum _MKAlignType {
    MKAlignLeft = 1,
    MKAlignCenterHorizontal = 2,
    MKAlignRight = 3,
    MKAlignTop = 4,
    MKAlignCenterVertical = 5,
    MKAlignBottom = 6,
} MKAlignType;

@implementation MKWindowController (Align)
- (void)align:(id)sender 
        along:(MKAlignType)edge {
    NSArray *sel = [self.graphicsController selectedObjects];
    NSRect selectedFrame, newFrame;
    MKWidget *widget;
    
    if ([sel count] > 1) {
        selectedFrame = [MKWidget widgetsFrame:sel];
        
        for (widget in sel) {
            newFrame = widget.frame;
            
            switch (edge) {
                case MKAlignLeft:
                    newFrame.origin.x = NSMinX(selectedFrame);
                    break;
                    
                case MKAlignCenterHorizontal:
                    newFrame.origin.x = NSMidX(selectedFrame) - (newFrame.size.width / 2);
                    break;
                    
                case MKAlignRight:
                    newFrame.origin.x = NSMaxX(selectedFrame) - newFrame.size.width;
                    break;
                    
                case MKAlignTop:
                    newFrame.origin.y = NSMinY(selectedFrame);
                    break;
                    
                case MKAlignCenterVertical:
                    newFrame.origin.y = NSMidY(selectedFrame) - (newFrame.size.height / 2);
                    break;
                    
                case MKAlignBottom:
                    newFrame.origin.y = NSMaxY(selectedFrame) - newFrame.size.height;
            }
            
            widget.frame = newFrame;
        }
    }
}

- (IBAction)alignLeft:(id)sender {
    [self align:sender along:MKAlignLeft];
    [[self docUndoManager] setActionName:@"Align Left Edges"];
}

- (IBAction)alignCenterHorizontal:(id)sender {
    [self align:sender along:MKAlignCenterHorizontal];
    [[self docUndoManager] setActionName:@"Align Horizontal Centers"];
}

- (IBAction)alignRight:(id)sender {
    [self align:sender along:MKAlignRight];
    [[self docUndoManager] setActionName:@"Align Right Edges"];
}

- (IBAction)alignTop:(id)sender {
    [self align:sender along:MKAlignTop];
    [[self docUndoManager] setActionName:@"Align Top Edges"];
}

- (IBAction)alignCenterVertical:(id)sender {
    [self align:sender along:MKAlignCenterVertical];
    [[self docUndoManager] setActionName:@"Align Vertical Centers"];
}

- (IBAction)alignBottom:(id)sender {
    [self align:sender along:MKAlignBottom];
    [[self docUndoManager] setActionName:@"Align Bottom Edges"];
}


@end
