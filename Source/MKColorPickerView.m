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

#import "MKColorPickerView.h"
#import "MKColorSwatchMatrix.h"
#import "MKColorSwatchCell.h"
#import "MKColorWell.h"

@implementation MKColorPickerView

@synthesize matrix;

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor darkGrayColor] setFill];
    NSRectFill(dirtyRect);
    [super drawRect:dirtyRect];
}

- (id)initWithColors:(NSArray *)colors
        numberOfRows:(NSInteger)rows
     numberOfColumns:(NSInteger)columns
          swatchSize:(NSSize)size
     targetColorWell:(MKColorWell *)aTargetColorWell
{
    NSSize spacing = NSMakeSize(1, 1);
    NSRect matrixFrame = NSMakeRect(spacing.width, spacing.height, 
                                    columns * size.width + ((columns - 1) * spacing.width), 
                                    rows * size.height + ((rows - 1)) * spacing.height);
    
    self = [self initWithFrame:NSInsetRect(matrixFrame, -spacing.width, -spacing.height)];
    
    if (self) {
        matrix = [[MKColorSwatchMatrix alloc] initWithFrame:matrixFrame 
                                               numberOfRows:rows 
                                            numberOfColumns:columns
                                                     colors:colors
                                            targetColorWell:aTargetColorWell];
        [matrix setIntercellSpacing:spacing];
        [matrix setCellSize:size];
        
        [self addSubview:matrix];
    } 
    
    return self;
}

@end
