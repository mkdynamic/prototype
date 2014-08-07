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

#import "MKSideView.h"
#import "PrioritySplitViewDelegate.h"

#define TOP_VIEW_INDEX 0
#define TOP_VIEW_PRIORITY 1
#define TOP_VIEW_MINIMUM_HEIGHT 0
#define BOTTOM_VIEW_INDEX 1
#define BOTTOM_VIEW_PRIORITY 0
#define BOTTOM_VIEW_MINIMUM_HEIGHT 0

@implementation MKSideView
- (void)awakeFromNib
{
    PrioritySplitViewDelegate *sideViewDelegate = [[PrioritySplitViewDelegate alloc] init];
    
    [sideViewDelegate setPriority:TOP_VIEW_PRIORITY
                   forViewAtIndex:TOP_VIEW_INDEX];
    [sideViewDelegate setMinimumLength:TOP_VIEW_MINIMUM_HEIGHT
                        forViewAtIndex:TOP_VIEW_INDEX];
    [sideViewDelegate setPriority:BOTTOM_VIEW_PRIORITY
                   forViewAtIndex:BOTTOM_VIEW_INDEX];
    [sideViewDelegate setMinimumLength:BOTTOM_VIEW_MINIMUM_HEIGHT
                        forViewAtIndex:BOTTOM_VIEW_INDEX];
    
    [self setDelegate:sideViewDelegate];
    
    [propertiesScrollView setDocumentView:propertiesView];
}

- (void)drawRect:(NSRect)dirtyRect
{
    float shadowSize = 3.0f;
    
    NSRect rect = NSInsetRect([self bounds], -(shadowSize + 1), -(shadowSize + 1));
    rect = NSOffsetRect(rect, -shadowSize, 0);
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:rect];
    
    NSImage *img = [NSImage imageNamed:@"sidebg_s1"];
    [[NSColor colorWithPatternImage:img] setFill];
    [path fill];
    
    [NSGraphicsContext saveGraphicsState];
    NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
    [shadow setShadowColor:[NSColor colorWithCalibratedWhite:0.0f     
                                                       alpha:0.45f]];
    [shadow setShadowBlurRadius:9];
    [shadow set];
    [path setLineWidth:1];
    [path stroke];
    [NSGraphicsContext restoreGraphicsState];
    
    [super drawRect:dirtyRect];
}

- (void)drawDividerInRect:(NSRect)rect
{   
    NSBezierPath *p = [NSBezierPath bezierPathWithRect:rect];
    [[NSColor colorWithDeviceWhite:0 alpha:0.15] setFill];
    [p fill];
    rect.origin.y += 1;
    p = [NSBezierPath bezierPathWithRect:rect];
    [[NSColor colorWithDeviceWhite:1 alpha:0.50] setFill];
    [p fill];
    
    NSImage *img = [NSImage imageNamed:@"side-sep-shade"];
    [img setFlipped:YES];
    NSPoint pt = rect.origin;
    pt.y -= [img size].height;
    [img drawAtPoint:pt fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
}
@end
