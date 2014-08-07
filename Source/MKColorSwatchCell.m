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

#import "MKColorSwatchCell.h"

@implementation MKColorSwatchCell

@synthesize color;

- (void)drawWithFrame:(NSRect)cellFrame
               inView:(NSMatrix *)controlView {
    [super drawWithFrame:cellFrame inView:controlView];
    
    if ([color isEqualTo:[NSColor clearColor]]) {
        [[NSColor whiteColor] setFill];
        NSRectFill(cellFrame);
        
        NSBezierPath *line = [NSBezierPath bezierPath];
        [line moveToPoint:NSMakePoint(cellFrame.size.width, cellFrame.origin.y)];
        [line lineToPoint:NSMakePoint(cellFrame.origin.x, cellFrame.size.height)];
        [line setLineWidth:1.5];
        [[NSColor redColor] setStroke];
        
        [[NSGraphicsContext currentContext] saveGraphicsState];
        [[NSBezierPath bezierPathWithRect:cellFrame] setClip];
        [line stroke];
        [[NSGraphicsContext currentContext] restoreGraphicsState];
    } else {
        [color setFill];
        NSRectFill(cellFrame);
    }
}

@end
