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

#import "MKWindowController+Pasteboard.h"
#import "MKWidget.h"

@implementation MKWindowController (Pasteboard)

- (IBAction)cut:(id)sender {
	[self copy:sender];
	[self delete:sender];
    
    [[self docUndoManager] setActionName:@"Cut"];
}

- (IBAction)copy:(id)sender {
    NSArray *sel = [self.graphicsController selectedObjects];
    
	if ([sel count] > 0) {
		NSData *clipData = [NSKeyedArchiver archivedDataWithRootObject:sel];
		NSPasteboard *cb = [NSPasteboard generalPasteboard];
		
		[cb declareTypes:[NSArray arrayWithObjects:@"Prototypeprivate", nil] owner:self];
		[cb setData:clipData forType:@"Prototypeprivate"];
        
        [[self docUndoManager] setActionName:@"Copy"];
	}
}

- (IBAction)paste:(id)sender {
	NSPasteboard *cb = [NSPasteboard generalPasteboard];
	NSString *type = [cb availableTypeFromArray:[NSArray arrayWithObjects:@"Prototypeprivate", nil]];
	
	if (type) {
		[self.graphicsController setSelectionIndexes:[NSIndexSet indexSet]];
        
        NSData *clipData = [cb dataForType:type];
		NSArray *pastedObjects = [NSKeyedUnarchiver unarchiveObjectWithData:clipData];
        [self.graphicsController addObjects:pastedObjects];
        
        [[self docUndoManager] setActionName:@"Paste"];
	}
}

- (IBAction)delete:(id)sender {
    [self.graphicsController removeObjectsAtArrangedObjectIndexes:[self.graphicsController selectionIndexes]];
    [self.graphicsController setSelectionIndexes:[NSIndexSet indexSet]];
    
    [[self docUndoManager] setActionName:@"Delete"];
}

- (IBAction)duplicate:(id)sender {
    NSArray *widgets = [self.graphicsController arrangedObjects];
    NSIndexSet *selIndexes = [self.graphicsController selectionIndexes];
    
    __block MKWidget *copy;
    NSMutableIndexSet *insertionIndexes = [NSMutableIndexSet indexSet];
    NSMutableArray *insertionWidgets = [NSMutableArray array];
    __block int insertionOffset = 1;
    
    if ([selIndexes count] > 0) {
        [selIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            copy = [[widgets objectAtIndex:idx] copy];
            copy.frame = NSOffsetRect(copy.frame, 10, 10);
            [insertionWidgets addObject:copy];
            [insertionIndexes addIndex:(idx + insertionOffset)];
            insertionOffset++;
        }];
        
        [self.graphicsController insertObjects:insertionWidgets 
                       atArrangedObjectIndexes:insertionIndexes];
        
        [[self docUndoManager] setActionName:@"Duplicate"];
    }
}

- (void)selectAll:(id)sender {
    int cnt = [[self.graphicsController arrangedObjects] count];
    
    if (cnt > 0) {
        NSRange rng = NSMakeRange(0, cnt);
        [self.graphicsController setSelectionIndexes:[NSIndexSet indexSetWithIndexesInRange:rng]];
    }
}

@end
