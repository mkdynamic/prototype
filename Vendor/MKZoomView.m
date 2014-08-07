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

#import "MKZoomView.h"

@interface MKZoomView ()

@end
    
@implementation MKZoomView

@synthesize scale;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		scale = 1.0;
	}
    return self;
}

- (IBAction)zoomIn:(id)sender {
	[self zoomViewByFactor:2.0];
}

- (IBAction)zoomOut:(id)sender {
	[self zoomViewByFactor:0.5];
}

- (IBAction)zoomToActualSize:(id)sender {
	[self zoomViewToAbsoluteScale:1.0];
}

- (IBAction)zoomFitInWindow:(id)sender {
	[self zoomViewToFitRect:[[self superview] frame]];
}

- (void)zoomViewByFactor:(float)factor {
	[self zoomViewByFactor:factor 
            andCentrePoint:[self centredPointInDocView]];
}

- (void)zoomViewToAbsoluteScale:(float)newScale {
	[self zoomViewByFactor:(newScale / [self scale])];
}

- (void)zoomViewToFitRect:(NSRect)aRect {
	NSRect fr = [self frame];
	float sx = aRect.size.width / fr.size.width;
	float sy = aRect.size.height / fr.size.height;
	
	[self zoomViewByFactor:MIN(sx, sy)];
}

- (void)zoomViewToRect:(NSRect)aRect {
	NSRect fr = [self convertRect:[[[self enclosingScrollView] contentView] documentVisibleRect]
                         fromView:[self superview]];
	NSPoint cp;
	
	float sx = fr.size.width / aRect.size.width;
	float sy = fr.size.height / aRect.size.height;
	
	cp.x = aRect.origin.x + aRect.size.width / 2.0;
	cp.y = aRect.origin.y + aRect.size.height / 2.0;
	
	[self zoomViewByFactor:MIN(sx, sy) 
            andCentrePoint:cp];
}

- (void)zoomViewToPaddedRect:(NSRect)aRect {
    float padding = 10 / [self scale];
    [self zoomViewToRect:NSInsetRect(aRect, -padding, -padding)];
}

- (void)zoomViewByFactor:(float)factor 
          andCentrePoint:(NSPoint)p {
    [self performZoom:(factor * [self scale])];
    [self setNeedsDisplay:YES];
    [self scrollPointToCentre:p];
}

- (void)setScale:(float)aScale {
    NSPoint p = [self centredPointInDocView];
    [self performZoom:aScale];
    [self setNeedsDisplay:YES];
    [self scrollPointToCentre:p];
}

- (void)zoomWithScrollWheelDelta:(float)delta 
                   toCentrePoint:(NSPoint)cp {
    if (delta == 0) return;
    
	[self zoomViewByFactor:delta < 0 ? 0.9 : 1.1
            andCentrePoint:cp];
}

- (void)scrollWheel:(NSEvent *)theEvent {
	if (([theEvent modifierFlags] & NSAlternateKeyMask) != 0) {
		[self zoomWithScrollWheelDelta:[theEvent deltaY] 
                         toCentrePoint:[self centredPointInDocView]];
	} else {
        [super scrollWheel:theEvent];
    }
}

- (NSPoint)centredPointInDocView {
	NSRect fr = [self convertRect:[[[self enclosingScrollView] contentView] documentVisibleRect] 
                         fromView:[self superview]];
	
	return NSMakePoint(NSMidX(fr), NSMidY(fr));
}

- (void)scrollPointToCentre:(NSPoint)aPoint {
    NSRect fr = [self convertRect:[[[self enclosingScrollView] contentView] documentVisibleRect] 
                         fromView:[self superview]];
	NSPoint sp;
	
	sp.x = aPoint.x - (fr.size.width / 2.0);
	sp.y = aPoint.y - (fr.size.height / 2.0);
	
	[self scrollPoint:sp];
}

- (float)minimumScale {
	return 0.10;
}

- (float)maximumScale {
	return 5.0;
}

/* private */

- (void)performZoom:(float)aScale {
    NSRect fr;
    NSSize newSize;
    float sc = aScale;
    float factor = aScale / [self scale];
    
    if (sc < [self minimumScale]) {
        sc = [self minimumScale];
        factor = sc / [self scale];
    }
    
    if (sc > [self maximumScale]) {
        sc = [self maximumScale];
        factor = sc / [self scale];
    }
    
    if (sc != [self scale]) {
        [self willChangeValueForKey:@"scale"];
        scale = sc;
        [self didChangeValueForKey:@"scale"];
        
        fr = [self frame];
        
        newSize.width = newSize.height = factor;
        
        [self scaleUnitSquareToSize:newSize];
        
        fr.size.width *= factor;
        fr.size.height *= factor;
        [self setFrameSize:fr.size];
    }
}

@end
