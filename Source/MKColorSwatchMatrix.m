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

#import "MKColorSwatchMatrix.h"
#import "MKColorSwatchCell.h"
#import "MKColorWell.h"

@implementation MKColorSwatchMatrix

- (id)initWithFrame:(NSRect)frameRect
       numberOfRows:(NSInteger)rowsHigh
    numberOfColumns:(NSInteger)colsWide
             colors:(NSArray *)theColors
    targetColorWell:(MKColorWell *)aTargetColorWell
{
    colCount = (int)colsWide;
    colors = theColors;
    
    self = [super initWithFrame:frameRect
                           mode:NSTrackModeMatrix 
                      cellClass:[MKColorSwatchCell class] 
                   numberOfRows:rowsHigh 
                numberOfColumns:colsWide];
    
    if (self) {
        targetColorWell = aTargetColorWell;
        
        [self setBackgroundColor:[NSColor darkGrayColor]];
        [self setDrawsBackground:YES];
    }
    
    return self;
}

- (NSCell *)makeCellAtRow:(NSInteger)row
                   column:(NSInteger)column
{
    MKColorSwatchCell *cell = (MKColorSwatchCell *)[super makeCellAtRow:row column:column];

    int index = (int)(column + (row * colCount));
    
    if (index < [colors count]) {
        cell.color = [colors objectAtIndex:index];
    }
    
    return cell;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    NSPoint pt = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    NSInteger row;
    NSInteger column;
    BOOL hit = [self getRow:&row column:&column forPoint:pt];
    
    if (hit) {
        MKColorSwatchCell *cell = [self cellAtRow:row column:column];
        [targetColorWell setColorAndClose:[cell color]];
    }
}

@end
