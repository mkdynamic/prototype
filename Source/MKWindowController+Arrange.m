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

#import "MKWindowController+Arrange.h"
#import "MKWidget.h"

@implementation MKWindowController (Arrange)

- (IBAction)bringToFront:(id)sender {
    NSArray *sel = [self.graphicsController selectedObjects];
    NSIndexSet *selIndexes = [self.graphicsController selectionIndexes];
    
    if ([sel count] > 0) {
        // remove objects
        [self.graphicsController removeObjectsAtArrangedObjectIndexes:selIndexes];
        
        // add objects to end
        [self.graphicsController addObjects:sel];
        
        [[self docUndoManager] setActionName:@"Bring to Front"];
    }
}

- (IBAction)bringForward:(id)sender {
    NSArray *sel = [self.graphicsController selectedObjects];
    NSIndexSet *selIndexes = [self.graphicsController selectionIndexes];
    int indexAbove = [selIndexes lastIndex] + 1;
    
    // TODO should check if any of selected objects has something above them
    // and just move those ones (vs. checking the highest item as we do here)
    if ([sel count] > 0 && [[self.graphicsController arrangedObjects] count] > indexAbove) {
        // remove objects
        [self.graphicsController removeObjectsAtArrangedObjectIndexes:selIndexes];
        
        // insert objects after one previously above them
        NSRange rng = NSMakeRange(indexAbove - [selIndexes count] + 1, [selIndexes count]);
        NSIndexSet *insertionIndexes = [NSIndexSet indexSetWithIndexesInRange:rng];
        [self.graphicsController insertObjects:sel atArrangedObjectIndexes:insertionIndexes];
        
        // TODO maybe do the thing where we only arrange overlapping objects
        
        [[self docUndoManager] setActionName:@"Bring Forward"];
    }
}

- (IBAction)sendToBack:(id)sender {
    NSArray *sel = [self.graphicsController selectedObjects];
    NSIndexSet *selIndexes = [self.graphicsController selectionIndexes];
    
    if ([sel count] > 0) {
        // remove objects
        [self.graphicsController removeObjectsAtArrangedObjectIndexes:selIndexes];
        
        // add objects to front
        [self.graphicsController insertObjects:sel 
                       atArrangedObjectIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [selIndexes count])]];
        
        [[self docUndoManager] setActionName:@"Send to Back"];
    }
}

- (IBAction)sendBackward:(id)sender {
    NSArray *sel = [self.graphicsController selectedObjects];
    NSIndexSet *selIndexes = [self.graphicsController selectionIndexes];
    int indexBelow = [selIndexes firstIndex] - 1;
    
    // TODO should check if any of selected objects has something behind them
    // and just move those ones (vs. checking the lowest item as we do here)
    if ([sel count] > 0 && indexBelow >= 0) {
        // remove objects
        [self.graphicsController removeObjectsAtArrangedObjectIndexes:selIndexes];
        
        // insert objects beneath one previously below them
        NSRange rng = NSMakeRange(indexBelow, [selIndexes count]);
        NSIndexSet *insertionIndexes = [NSIndexSet indexSetWithIndexesInRange:rng];
        [self.graphicsController insertObjects:sel atArrangedObjectIndexes:insertionIndexes];
        
        // TODO maybe do the thing where we only arrange overlapping objects
        
        [[self docUndoManager] setActionName:@"Send Backwards"];
    }
}


@end
