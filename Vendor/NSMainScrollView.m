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

#import "NSMainScrollView.h"

static const float shadowSize = 9.0f;
@implementation NSMainScrollView
-(void)drawRect:(NSRect)dirtyRect
{
    NSImage *img = [NSImage imageNamed:@"darkdenim3"];
    [[NSColor colorWithPatternImage:img] setFill];
    NSRectFill([self bounds]);
    
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:[self bounds]];
    NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
    [shadow setShadowColor:[NSColor colorWithDeviceWhite:0 alpha:0.75]];
    [shadow setShadowBlurRadius:shadowSize];
    [shadow setShadowOffset:NSMakeSize(0, -(shadowSize / 3))];
    
    // http://code.google.com/p/amber-framework/source/browse/trunk/AmberKit/NSBezierPath%2BAdditions.m?r=360
    [NSGraphicsContext saveGraphicsState];
    NSShadow *shadowCopy = [shadow copy];
    
    NSSize offset = shadowCopy.shadowOffset;
    CGFloat radius = shadowCopy.shadowBlurRadius;
    NSRect bounds = NSInsetRect(path.bounds, -(ABS(offset.width) + radius), -(ABS(offset.height) + radius));
    offset.height += bounds.size.height;
    shadowCopy.shadowOffset = offset;
    
    NSAffineTransform *transform = [NSAffineTransform transform];
    [transform translateXBy:0 yBy:([[NSGraphicsContext currentContext] isFlipped] ? 1 : -1) * bounds.size.height];
    
    NSBezierPath *drawingPath = [NSBezierPath bezierPathWithRect:bounds];
    [drawingPath setWindingRule:NSEvenOddWindingRule];
    [drawingPath appendBezierPath:path];
    [drawingPath transformUsingAffineTransform:transform];
    
    [path addClip];
    [shadowCopy set];
    [shadowCopy.shadowColor set];
    [drawingPath fill];
    
    [NSGraphicsContext restoreGraphicsState];
}

- (BOOL)isOpaque
{
    return YES;
}
@end
