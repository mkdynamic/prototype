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

#import "MKWindowController+Distribute.h"
#import "MKWidget.h"

@implementation MKWindowController (Distribute)

- (IBAction)distributeLeftEdges:(id)sender {
    NSArray *sel = [self.graphicsController selectedObjects];
    
    if ([sel count] > 1) {
        float space;
        float minEdge = 9999;
        float maxEdge = 0;
        MKWidget *minWidget;
        MKWidget *maxWidget;
        
        // calc space
        for (MKWidget *widget in sel) {
            if (NSMinX([widget frame]) < minEdge) {
                minEdge = NSMinX([widget frame]);
                minWidget = widget;
            }
            
            if (NSMinX([widget frame]) > maxEdge) {
                maxEdge = NSMinX([widget frame]);
                maxWidget = widget;
            }
        }
        float totalSpace = maxEdge - minEdge;
        space = totalSpace / ([sel count] - 1);
        
        // distribute space
        NSComparisonResult (^sortBlock)(id, id) = ^(id a, id b) {
            float minEdgeA = NSMinX([((MKWidget *)a) frame]);
            float minEdgeB = NSMinX([((MKWidget *)b) frame]);
            
            if (minEdgeA < minEdgeB) {
                return (NSComparisonResult)NSOrderedAscending;
            } else if (minEdgeA > minEdgeB) {
                return (NSComparisonResult)NSOrderedDescending;
            } else {
                return (NSComparisonResult)NSOrderedSame;
            }      
        };
        float lastMinEdge = minEdge;
        NSArray *selByMinEdge = [sel sortedArrayUsingComparator:sortBlock];
        for (MKWidget *widget in selByMinEdge) {
            if (widget == minWidget || widget == maxWidget) continue;
            NSRect r = [widget frame];
            r.origin.x = lastMinEdge + space;
            
            
            [widget setFrame:r];
            lastMinEdge = NSMinX([widget frame]);
        }
        
        [[self docUndoManager] setActionName:@"Distribute Left Edges"];
    }
}

- (IBAction)distributeHorizontalCenters:(id)sender {
    NSArray *sel = [self.graphicsController selectedObjects];
    
    if ([sel count] > 1) {
        float space;
        float minEdge = 9999;
        float maxEdge = 0;
        MKWidget *minWidget;
        MKWidget *maxWidget;
        
        // calc space
        for (MKWidget *widget in sel) {
            if (NSMidX([widget frame]) < minEdge) {
                minEdge = NSMidX([widget frame]);
                minWidget = widget;
            }
            
            if (NSMidX([widget frame]) > maxEdge) {
                maxEdge = NSMidX([widget frame]);
                maxWidget = widget;
            }
        }
        float totalSpace = maxEdge - minEdge;
        space = totalSpace / ([sel count] - 1);
        
        // distribute space
        NSComparisonResult (^sortBlock)(id, id) = ^(id a, id b) {
            float minEdgeA = NSMidX([((MKWidget *)a) frame]);
            float minEdgeB = NSMidX([((MKWidget *)b) frame]);
            
            if (minEdgeA < minEdgeB) {
                return (NSComparisonResult)NSOrderedAscending;
            } else if (minEdgeA > minEdgeB) {
                return (NSComparisonResult)NSOrderedDescending;
            } else {
                return (NSComparisonResult)NSOrderedSame;
            }      
        };
        float lastMinEdge = minEdge;
        NSArray *selByMinEdge = [sel sortedArrayUsingComparator:sortBlock];
        for (MKWidget *widget in selByMinEdge) {
            if (widget == minWidget || widget == maxWidget) continue;
            NSRect r = [widget frame];
            r.origin.x = lastMinEdge + space - (r.size.width / 2);
            [widget setFrame:r];
            lastMinEdge = NSMidX([widget frame]);
        }
        
        [[self docUndoManager] setActionName:@"Distribute Horizontal Centers"];
    }
}

- (IBAction)distributeRightEdges:(id)sender {
    NSArray *sel = [self.graphicsController selectedObjects];
    
    if ([sel count] > 1) {
        float space;
        float minEdge = 9999;
        float maxEdge = 0;
        MKWidget *minWidget;
        MKWidget *maxWidget;
        
        // calc space
        for (MKWidget *widget in sel) {
            if (NSMaxX([widget frame]) < minEdge) {
                minEdge = NSMaxX([widget frame]);
                minWidget = widget;
            }
            
            if (NSMaxX([widget frame]) > maxEdge) {
                maxEdge = NSMaxX([widget frame]);
                maxWidget = widget;
            }
        }
        float totalSpace = maxEdge - minEdge;
        space = totalSpace / ([sel count] - 1);
        
        // distribute space
        NSComparisonResult (^sortBlock)(id, id) = ^(id a, id b) {
            float minEdgeA = NSMaxX([((MKWidget *)a) frame]);
            float minEdgeB = NSMaxX([((MKWidget *)b) frame]);
            
            if (minEdgeA < minEdgeB) {
                return (NSComparisonResult)NSOrderedAscending;
            } else if (minEdgeA > minEdgeB) {
                return (NSComparisonResult)NSOrderedDescending;
            } else {
                return (NSComparisonResult)NSOrderedSame;
            }      
        };
        float lastMinEdge = minEdge;
        NSArray *selByMinEdge = [sel sortedArrayUsingComparator:sortBlock];
        for (MKWidget *widget in selByMinEdge) {
            if (widget == minWidget || widget == maxWidget) continue;
            NSRect r = [widget frame];
            r.origin.x = lastMinEdge + space - r.size.width;
            [widget setFrame:r];
            lastMinEdge = NSMaxX([widget frame]);
        }
        
        [[self docUndoManager] setActionName:@"Distribute Right Edges"];
    }
}

- (IBAction)distributeTopEdges:(id)sender {
    NSArray *sel = [self.graphicsController selectedObjects];
    
    if ([sel count] > 1) {
        float space;
        float minEdge = 9999;
        float maxEdge = 0;
        MKWidget *minWidget;
        MKWidget *maxWidget;
        
        // calc space
        for (MKWidget *widget in sel) {
            if (NSMinY([widget frame]) < minEdge) {
                minEdge = NSMinY([widget frame]);
                minWidget = widget;
            }
            
            if (NSMinY([widget frame]) > maxEdge) {
                maxEdge = NSMinY([widget frame]);
                maxWidget = widget;
            }
        }
        float totalSpace = maxEdge - minEdge;
        space = totalSpace / ([sel count] - 1);
        
        // distribute space
        NSComparisonResult (^sortBlock)(id, id) = ^(id a, id b) {
            float minEdgeA = NSMinY([((MKWidget *)a) frame]);
            float minEdgeB = NSMinY([((MKWidget *)b) frame]);
            
            if (minEdgeA < minEdgeB) {
                return (NSComparisonResult)NSOrderedAscending;
            } else if (minEdgeA > minEdgeB) {
                return (NSComparisonResult)NSOrderedDescending;
            } else {
                return (NSComparisonResult)NSOrderedSame;
            }      
        };
        float lastMinEdge = minEdge;
        NSArray *selByMinEdge = [sel sortedArrayUsingComparator:sortBlock];
        for (MKWidget *widget in selByMinEdge) {
            if (widget == minWidget || widget == maxWidget) continue;
            NSRect r = [widget frame];
            r.origin.y = lastMinEdge + space;
            [widget setFrame:r];
            lastMinEdge = NSMinY([widget frame]);
        }
        
        [[self docUndoManager] setActionName:@"Distribute Top Edges"];
    }
}

- (IBAction)distributeVerticalCenters:(id)sender {
    NSArray *sel = [self.graphicsController selectedObjects];
    
    if ([sel count] > 1) {
        float space;
        float minEdge = 9999;
        float maxEdge = 0;
        MKWidget *minWidget;
        MKWidget *maxWidget;
        
        // calc space
        for (MKWidget *widget in sel) {
            if (NSMidY([widget frame]) < minEdge) {
                minEdge = NSMidY([widget frame]);
                minWidget = widget;
            }
            
            if (NSMidY([widget frame]) > maxEdge) {
                maxEdge = NSMidY([widget frame]);
                maxWidget = widget;
            }
        }
        float totalSpace = maxEdge - minEdge;
        space = totalSpace / ([sel count] - 1);
        
        // distribute space
        NSComparisonResult (^sortBlock)(id, id) = ^(id a, id b) {
            float minEdgeA = NSMidY([((MKWidget *)a) frame]);
            float minEdgeB = NSMidY([((MKWidget *)b) frame]);
            
            if (minEdgeA < minEdgeB) {
                return (NSComparisonResult)NSOrderedAscending;
            } else if (minEdgeA > minEdgeB) {
                return (NSComparisonResult)NSOrderedDescending;
            } else {
                return (NSComparisonResult)NSOrderedSame;
            }      
        };
        float lastMinEdge = minEdge;
        NSArray *selByMinEdge = [sel sortedArrayUsingComparator:sortBlock];
        for (MKWidget *widget in selByMinEdge) {
            if (widget == minWidget || widget == maxWidget) continue;
            NSRect r = [widget frame];
            r.origin.y = lastMinEdge + space - (r.size.height / 2);
            [widget setFrame:r];
            lastMinEdge = NSMidY([widget frame]);
        }
        
        [[self docUndoManager] setActionName:@"Distribute Vertical Centers"];
    }
}

- (IBAction)distributeBottomEdges:(id)sender {
    NSArray *sel = [self.graphicsController selectedObjects];
    
    if ([sel count] > 1) {
        float space;
        float minEdge = 9999;
        float maxEdge = 0;
        MKWidget *minWidget;
        MKWidget *maxWidget;
        
        // calc space
        for (MKWidget *widget in sel) {
            if (NSMaxY([widget frame]) < minEdge) {
                minEdge = NSMaxY([widget frame]);
                minWidget = widget;
            }
            
            if (NSMaxY([widget frame]) > maxEdge) {
                maxEdge = NSMaxY([widget frame]);
                maxWidget = widget;
            }
        }
        float totalSpace = maxEdge - minEdge;
        space = totalSpace / ([sel count] - 1);
        
        // distribute space
        NSComparisonResult (^sortBlock)(id, id) = ^(id a, id b) {
            float minEdgeA = NSMaxY([((MKWidget *)a) frame]);
            float minEdgeB = NSMaxY([((MKWidget *)b) frame]);
            
            if (minEdgeA < minEdgeB) {
                return (NSComparisonResult)NSOrderedAscending;
            } else if (minEdgeA > minEdgeB) {
                return (NSComparisonResult)NSOrderedDescending;
            } else {
                return (NSComparisonResult)NSOrderedSame;
            }      
        };
        float lastMinEdge = minEdge;
        NSArray *selByMinEdge = [sel sortedArrayUsingComparator:sortBlock];
        for (MKWidget *widget in selByMinEdge) {
            if (widget == minWidget || widget == maxWidget) continue;
            NSRect r = [widget frame];
            r.origin.y = lastMinEdge + space - r.size.height;
            [widget setFrame:r];
            lastMinEdge = NSMaxY([widget frame]);
        }
        
        [[self docUndoManager] setActionName:@"Distribute Buttom Edges"];
    }
}


@end
