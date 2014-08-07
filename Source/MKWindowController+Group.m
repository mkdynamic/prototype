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

#import "MKWindowController+Group.h"
#import "MKWidget.h"
#import "MKGroupWidget.h"
#import "MKWidgetElement.h"

@implementation MKWindowController (Group)

- (IBAction)group:(id)sender {
    NSArray *sel = [self.graphicsController selectedObjects];
    
    if ([sel count] > 1) {
        // TODO: Should move a lot of this stuff into MKGroupWidget
        // just pass it a list of elements and let it do the rest
        MKGroupWidget *group = [[MKGroupWidget alloc] init];
        NSMutableArray *parts = [[NSMutableArray alloc] init];
        NSRect groupRect = NSZeroRect;
        MKWidgetElement *el;
        
        for (MKWidget *widget in sel) {
            el = [[MKWidgetElement alloc] init];
            el.group = group;
            el.groupedWidget = widget;
            [parts addObject:el];
            groupRect = NSUnionRect(groupRect, widget.frame);
        }
        
        MKWidgetElement *firstPart = [parts objectAtIndex:0];
        [group setStrokeWidth:firstPart.groupedWidget.strokeWidth];
        [group setStrokeColor:firstPart.groupedWidget.strokeColor];
        [group setFillColor:firstPart.groupedWidget.fillColor];
        group.groupedWidgets = parts;
        [group setInitialGroupFrame:groupRect];
        
        int insertionIndex = [[self.graphicsController selectionIndexes] firstIndex];
        [self.graphicsController removeObjectsAtArrangedObjectIndexes:[self.graphicsController selectionIndexes]];
        [self.graphicsController insertObject:group atArrangedObjectIndex:insertionIndex];
        
        [[self docUndoManager] setActionName:@"Group"];
    }
}

- (IBAction)ungroup:(id)sender {
    NSIndexSet *selIndexes = [self.graphicsController selectionIndexes];
    NSArray *objs = [NSArray arrayWithArray:[self.graphicsController arrangedObjects]];
    
    NSMutableIndexSet *finalSelectionIndexes = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *removalIndexes = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *insertionIndexes = [NSMutableIndexSet indexSet];
    NSMutableArray *insertionWidgets = [NSMutableArray array];
    __block NSArray *groupedWidgets;
    __block int insertionIndex;
    __block int insertionOffset = 0;
    __block MKWidget *widget;
    __block MKWidget *ungroupingWidget;
    __block NSRect ungroupingWidgetFrame;
    
    if ([selIndexes count] > 0) {
        [selIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            widget = [objs objectAtIndex:idx];
            
            if ([widget isKindOfClass:[MKGroupWidget class]]) {
                // we will remove this object
                [removalIndexes addIndex:idx];
                
                // for each of the grouped widget, add it for insertion
                groupedWidgets = ((MKGroupWidget *)widget).groupedWidgets;
                insertionIndex = idx;
                for (MKWidgetElement *el in groupedWidgets) {
                    ungroupingWidget = el.groupedWidget;
                    
                    // whilst grouped, the frame may have become non integral
                    // we can fix that here
                    ungroupingWidgetFrame = ungroupingWidget.frame;
                    ungroupingWidgetFrame.origin.x = roundf(ungroupingWidgetFrame.origin.x);
                    ungroupingWidgetFrame.origin.y = roundf(ungroupingWidgetFrame.origin.y);
                    ungroupingWidgetFrame.size.width = roundf(ungroupingWidgetFrame.size.width);
                    ungroupingWidgetFrame.size.height = roundf(ungroupingWidgetFrame.size.height);
                    ungroupingWidget.frame = ungroupingWidgetFrame;
                    
                    ungroupingWidget.widgetElement = nil;
                    [insertionWidgets addObject:ungroupingWidget];
                    [insertionIndexes addIndex:(insertionIndex + insertionOffset)];
                    [finalSelectionIndexes addIndex:(insertionIndex + insertionOffset)];
                    insertionIndex++;
                }
                
                // we've removed 1 item, but added the seperate grouped items
                // i.e. we've added: [groupedWidgets count] - 1
                insertionOffset += [groupedWidgets count] - 1;
            } else {
                [finalSelectionIndexes addIndex:(idx + insertionOffset)];
            }
        }];
        
        [self.graphicsController removeObjectsAtArrangedObjectIndexes:removalIndexes];
        [self.graphicsController insertObjects:insertionWidgets 
                       atArrangedObjectIndexes:insertionIndexes];
        [self.graphicsController setSelectionIndexes:finalSelectionIndexes];
        
        [[self docUndoManager] setActionName:@"Ungroup"];
    }
}


@end
