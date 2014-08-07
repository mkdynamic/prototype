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

#import "MKWindowController+Space.h"
#import "MKWidget.h"
#import "MKAppController.h"
#import "MKWindowController.h"

@implementation MKWindowController (Space)

- (IBAction)spaceHorizontally:(id)sender {
    NSArray *sel = [self.graphicsController selectedObjects];
    
    if ([sel count] > 1) {
        MKAppController *ac = [NSApp delegate];
        MKWindowController *wc = ac.docWindowController;
        NSString *strategy = [wc spacingStrategy];
        
        float space;
        float leftMostRightEdge = 9999;
        float rightMostLeftEdge = 0;
        MKWidget *leftMost;
        MKWidget *rightMost;
        
        // calc space
        if ([strategy isEqualToString:@"evenly"]) {
            for (MKWidget *widget in sel) {
                if (NSMaxX([widget frame]) < leftMostRightEdge) {
                    leftMostRightEdge = NSMaxX([widget frame]);
                    leftMost = widget;
                }
                
                if (NSMinX([widget frame]) > rightMostLeftEdge) {
                    rightMostLeftEdge = NSMinX([widget frame]);
                    rightMost = widget;
                }
            }
            
            float totalSpace = rightMostLeftEdge - leftMostRightEdge;
            float insideWidgetsTotalWidth = 0;
            for (MKWidget *widget in sel) {
                if (widget == leftMost || widget == rightMost) continue;
                insideWidgetsTotalWidth += NSWidth([widget frame]);
            }
            totalSpace -= insideWidgetsTotalWidth;
            space = totalSpace / ([sel count] - 1);
        } else {
            for (MKWidget *widget in sel) {
                if (NSMaxX([widget frame]) < leftMostRightEdge) {
                    leftMostRightEdge = NSMaxX([widget frame]);
                    leftMost = widget;
                }
            }
            
            space = [wc spacingPixels];
        }
        
        // distribute space
        float lastLeftEdge = leftMostRightEdge;
        NSArray *selByLeftEdge = [sel sortedArrayUsingComparator:^(MKWidget * a, MKWidget * b) {
            float leftEdgeA = NSMinX([a frame]);
            float leftEdgeB = NSMinX([a frame]);
            
            if (leftEdgeA < leftEdgeB) {
                return (NSComparisonResult)NSOrderedAscending;
            } else if (leftEdgeA > leftEdgeB) {
                return (NSComparisonResult)NSOrderedDescending;
            } else {
                return (NSComparisonResult)NSOrderedSame;
            }      
        }];
        for (MKWidget *widget in selByLeftEdge) {
            if (widget == leftMost || widget == rightMost) continue;
            NSRect r = [widget frame];
            r.origin.x = lastLeftEdge + space;
            [widget setFrame:r];
            lastLeftEdge = NSMaxX([widget frame]);
        }
        
        [[self docUndoManager] setActionName:@"Space Horizontally"];
    }
}

- (IBAction)spaceVertically:(id)sender {
    NSArray *sel = [self.graphicsController selectedObjects];
    
    if ([sel count] > 1) {
        MKAppController *ac = [NSApp delegate];
        MKWindowController *wc = ac.docWindowController;
        NSString *strategy = [wc spacingStrategy];
        
        float space;
        float topMostBottomEdge = 9999;
        float bottomMostTopEdge = 0;
        MKWidget *topMost;
        MKWidget *bottomMost;
        
        // calc space
        if ([strategy isEqualToString:@"evenly"]) {
            for (MKWidget *widget in sel) {
                if (NSMaxY([widget frame]) < topMostBottomEdge) {
                    topMostBottomEdge = NSMaxY([widget frame]);
                    topMost = widget;
                }
                
                if (NSMinY([widget frame]) > bottomMostTopEdge) {
                    bottomMostTopEdge = NSMinY([widget frame]);
                    bottomMost = widget;
                }
            }
            
            float totalSpace = bottomMostTopEdge - topMostBottomEdge;
            float insideWidgetsTotalHeight = 0;
            for (MKWidget *widget in sel) {
                if (widget == topMost || widget == bottomMost) continue;
                insideWidgetsTotalHeight += NSHeight([widget frame]);
            }
            totalSpace -= insideWidgetsTotalHeight;
            space = totalSpace / ([sel count] - 1);
        } else {
            for (MKWidget *widget in sel) {
                if (NSMaxY([widget frame]) < topMostBottomEdge) {
                    topMostBottomEdge = NSMaxY([widget frame]);
                    topMost = widget;
                }
            }
            
            space = [wc spacingPixels];
        }
        
        // distribute space
        NSComparisonResult (^sortBlock)(id, id) = ^(id a, id b) {
            float topEdgeA = NSMinY([((MKWidget *)a) frame]);
            float bottomEdgeB = NSMinY([((MKWidget *)b) frame]);
            
            if (topEdgeA < bottomEdgeB) {
                return (NSComparisonResult)NSOrderedAscending;
            } else if (topEdgeA > bottomEdgeB) {
                return (NSComparisonResult)NSOrderedDescending;
            } else {
                return (NSComparisonResult)NSOrderedSame;
            }      
        };
        float lastTopEdge = topMostBottomEdge;
        NSArray *selByTopEdge = [sel sortedArrayUsingComparator:sortBlock];
        for (MKWidget *widget in selByTopEdge) {
            if (widget == topMost || widget == bottomMost) continue;
            NSRect r = [widget frame];
            r.origin.y = lastTopEdge + space;
            [widget setFrame:r];
            lastTopEdge = NSMaxY([widget frame]);
        }
        
        [[self docUndoManager] setActionName:@"Space Vertically"];
    }
}

@end
