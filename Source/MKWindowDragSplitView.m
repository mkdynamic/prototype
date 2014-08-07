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

#import "MKWindowDragSplitView.h"

@implementation MKWindowDragSplitView
@synthesize bottom;

- (id)init
{
    self = [super init];
    
    if (self) {
        bottom = NO;
    }
    
    return self;
}

- (void)drawDividerInRect:(NSRect)rect
{
    float opacity = 0.15;
    
    NSColor *startColor = [NSColor colorWithDeviceWhite:0 alpha:opacity * 0.5];
    NSColor *endColor = [NSColor colorWithDeviceWhite:0 alpha:opacity];
    NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:startColor
                                                         endingColor:endColor];
    [gradient drawInRect:rect angle:self.bottom ? -90 : 90];
    
    rect.origin.x += 1;
    startColor = [NSColor colorWithDeviceWhite:1 alpha:opacity * 0.5];
    endColor = [NSColor colorWithDeviceWhite:1 alpha:opacity];
    gradient = [[NSGradient alloc] initWithStartingColor:startColor
                                                         endingColor:endColor];
    [gradient drawInRect:rect angle:self.bottom ? -90 : 90];
}

@end
