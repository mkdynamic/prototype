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

#import "MKAppController.h"
#import "MKElement.h"
#import "MKWidget.h"
#import "MKWindowController.h"

@implementation MKElement

@synthesize stroke, fill, frame, path, debug, subelements, 
    superelement, autoresizingMask, frameBase, visible, root;

- (id)init {
    self = [super init];
	if (self) {
        visible = YES;
        atMinSize = NO;
		stroke = 0;
		fill = 0;
        debug = NO;
        subelements = [NSMutableArray array];
        autoresizingMask = NSViewNotSizable | NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin;
        frame = frameBase = NSZeroRect;
    
        seed = (uint)rand(); // srandom used up
	}
	return self;
}

- (id)initWithFrame:(NSRect)aRect {
	self = [self init];
    if (self) {
        frame = frameBase = aRect;
        
	}
	return self;	
}

- (id)initWithFrame:(NSRect)aRect 
         withStroke:(int)aStroke 
           withFill:(int)aFill {
    self = [self initWithFrame:aRect];
	if (self) {
		stroke = aStroke;
		fill = aFill;
	}
	return self;	
}

/* element hieracrhy */

- (void)addSubelement:(id <MKHierarchicalElement>)element {
    [self.subelements addObject:element];
    [element setSuperelement:self];
}

- (void)setSuperelement:(id<MKHierarchicalElement>)el {
    superelement = el;
    
    // TODO works but this is clunky, can improve
    id parent = superelement;
    while ([parent respondsToSelector:@selector(superelement)]) {
        parent = [parent superelement];
    }
    self.root = (MKWidget *)parent;
    
    if (path == nil) {
        path = [self defaultPath];
    }
}

/* geometry */

- (void)setFrame:(NSRect)aFrame {
    NSRect oldFrame = frame;
    
    frame = aFrame;
    
    NSRect superFrameBase = superelement.frameBase;
    
    frameBase =  NSMakeRect(frame.origin.x + superFrameBase.origin.x, 
                            frame.origin.y + superFrameBase.origin.y, 
                            frame.size.width, 
                            frame.size.height);
      
    
     [self resizeSubelementsWithOldSize:oldFrame.size];
}

- (void)resizeSubelementsWithOldSize:(NSSize)oldSize {
    for (id <MKHierarchicalElement> el in self.subelements)
        [el resizeWithOldSuperelementSize:oldSize];
}

- (void)resizeWithOldSuperelementSize:(NSSize)oldSize {
    if (autoresizingMask == NSViewNotSizable)
        return;
    
    NSRect newFrame = frame;
    NSRect superFrameBase = superelement.frameBase;
    
    float dX = superFrameBase.size.width - oldSize.width;
    float dY = superFrameBase.size.height - oldSize.height;
    
    float evenFractionX = 1.0 / ((autoresizingMask & NSViewMinXMargin ? 1 : 0) + 
                                 (autoresizingMask & NSViewWidthSizable ? 1 : 0) + 
                                 (autoresizingMask & NSViewMaxXMargin ? 1 : 0));
    
    float evenFractionY = 1.0 / ((autoresizingMask & NSViewMinYMargin ? 1 : 0) + 
                                 (autoresizingMask & NSViewHeightSizable ? 1 : 0) + 
                                 (autoresizingMask & NSViewMaxYMargin ? 1 : 0));
    
    float baseX = ((autoresizingMask & NSViewMinXMargin ? newFrame.origin.x : 0) + 
                   (autoresizingMask & NSViewWidthSizable ? newFrame.size.width : 0) + 
                   (autoresizingMask & NSViewMaxXMargin ? oldSize.width - newFrame.size.width - newFrame.origin.x : 0));
    
    float baseY = ((autoresizingMask & NSViewMinYMargin ? newFrame.origin.y : 0) + 
                   (autoresizingMask & NSViewHeightSizable ? newFrame.size.height : 0) + 
                   (autoresizingMask & NSViewMaxYMargin ? oldSize.height - newFrame.size.height - newFrame.origin.y : 0));
    
    if (autoresizingMask & NSViewMinXMargin)
        newFrame.origin.x += dX * (baseX > 0 ? newFrame.origin.x / baseX : evenFractionX);
    
    if (autoresizingMask & NSViewWidthSizable)
        newFrame.size.width += dX * (baseX > 0 ? newFrame.size.width / baseX : evenFractionX);
    
    if (autoresizingMask & NSViewMinYMargin)
        newFrame.origin.y += dY * (baseY > 0 ? newFrame.origin.y / baseY : evenFractionY);
    
    if (autoresizingMask & NSViewHeightSizable)
        newFrame.size.height += dY * (baseY > 0 ? newFrame.size.height / baseY : evenFractionY);
    
    
    self.frame = newFrame;
}

/* autoresizing */

- (MKElement *)pinLeft
{
    self.autoresizingMask &= ~NSViewMinXMargin;
    return self;
}

- (MKElement *)unpinLeft
{
    self.autoresizingMask |= NSViewMinXMargin;
    return self;
}

- (MKElement *)pinRight
{
    self.autoresizingMask &= ~NSViewMaxXMargin;
    return self;
}

- (MKElement *)unpinRight
{
    self.autoresizingMask |= NSViewMaxXMargin;
    return self;
}

- (MKElement *)pinTop
{
    self.autoresizingMask &= ~NSViewMinYMargin;
    return self;
}

- (MKElement *)unpinTop
{
    self.autoresizingMask |= NSViewMinYMargin;
    return self;
}

- (MKElement *)pinBottom
{
    self.autoresizingMask &= ~NSViewMaxYMargin;
    return self;
}

- (MKElement *)unpinBottom
{
    self.autoresizingMask |= NSViewMaxYMargin;
    return self;
}

- (MKElement *)fixWidth {
    self.autoresizingMask &= ~NSViewWidthSizable;
    return self;
}

- (MKElement *)flexWidth
{
    self.autoresizingMask |= NSViewWidthSizable;
    return self;
}

- (MKElement *)fixHeight
{
    self.autoresizingMask &= ~NSViewHeightSizable;
    return self;
}

- (MKElement *)flexHeight
{
    self.autoresizingMask |= NSViewHeightSizable;
    return self;
}

- (MKElement *)pin
{
    return [self pin:@"Top", @"Right", @"Bottom", @"Left", nil];
}

- (MKElement *)fix
{
    return [self fix:@"Width", @"Height", nil];
}

- (MKElement *)flex
{
    return [self flex:@"Width", @"Height", nil];
}

- (MKElement *)pin:(NSString *)edge, ...
{
    va_list args;
    va_start(args, edge);
    NSString *edg;
    NSString *messageName;
    NSString *messagePrefix = @"pin";
    
    edg = edge;
    messageName = [messagePrefix stringByAppendingString:edg];
    [self performSelector:NSSelectorFromString(messageName)];
    
    while ((edg = va_arg(args, NSString *))) {
        messageName = [messagePrefix stringByAppendingString:edg];
        [self performSelector:NSSelectorFromString(messageName)];
    }
    
    va_end(args);
    
    return self;
}

- (MKElement *)unpin:(NSString *)edge, ...
{
    va_list args;
    va_start(args, edge);
    NSString *edg;
    NSString *messageName;
    NSString *messagePrefix = @"unpin";
    
    edg = edge;
    messageName = [messagePrefix stringByAppendingString:edg];
    [self performSelector:NSSelectorFromString(messageName)];
    
    while ((edg = va_arg(args, NSString *))) {
        messageName = [messagePrefix stringByAppendingString:edg];
        [self performSelector:NSSelectorFromString(messageName)];
    }
    
    va_end(args);
    
    return self;
}

- (MKElement *)fix:(NSString *)dimension, ...
{
    va_list args;
    va_start(args, dimension);
    NSString *edg;
    NSString *messageName;
    NSString *messagePrefix = @"fix";
    
    edg = dimension;
    messageName = [messagePrefix stringByAppendingString:edg];
    [self performSelector:NSSelectorFromString(messageName)];
    
    while ((edg = va_arg(args, NSString *))) {
        messageName = [messagePrefix stringByAppendingString:edg];
        [self performSelector:NSSelectorFromString(messageName)];
    }
    
    va_end(args);
    
    return self;
}

- (MKElement *)flex:(NSString *)dimension, ...
{
    va_list args;
    va_start(args, dimension);
    NSString *edg;
    NSString *messageName;
    NSString *messagePrefix = @"flex";
    
    edg = dimension;
    messageName = [messagePrefix stringByAppendingString:edg];
    [self performSelector:NSSelectorFromString(messageName)];
    
    while ((edg = va_arg(args, NSString *))) {
        messageName = [messagePrefix stringByAppendingString:edg];
        [self performSelector:NSSelectorFromString(messageName)];
    }
    
    va_end(args);
    
    return self;
}

/* paths (i.e. template/shape instructions) */

- (NSBezierPath *)defaultPath
{
	return [NSBezierPath bezierPathWithRect:NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height)];
}

// NOTE can optimize this and probably use some caching
- (NSBezierPath *)path
{
    NSRect pathBounds = [path bounds];
	
    // discard cached path and regenerate from default 
    // when we shrunk down to zero previously
//    if (pathBounds.size.width <= 0 || pathBounds.size.height <= 0) {
//        path = [self defaultPath];
//        pathBounds = [path bounds];
//    }
    
    NSPoint scaleFactorOrigin = self.root.scaleFactorOrigin;
    
    float ratioX;
    if (pathBounds.size.width > 0) {
        ratioX = frameBase.size.width / pathBounds.size.width;
    } else {
        ratioX = 1;
    }
    
    float ratioY;
    if (pathBounds.size.height > 0) {
        ratioY = frameBase.size.height / pathBounds.size.height;
    } else {
        ratioY = 1;
    }
    
    NSAffineTransformStruct m0 = {1, 0, 0, 1, 0 - pathBounds.origin.x, 0 - pathBounds.origin.y};
    NSAffineTransformStruct m1 = {ratioX, 0, 0, ratioY, frameBase.origin.x, frameBase.origin.y};
    NSAffineTransformStruct m2 = {1, 0, 0, 1, 0 - scaleFactorOrigin.x, 0 - scaleFactorOrigin.y };
    NSAffineTransformStruct m3 = {self.root.scaleXFactor, 0, 0, self.root.scaleYFactor, scaleFactorOrigin.x, scaleFactorOrigin.y};
    
    NSAffineTransform *t = [NSAffineTransform transform];
    [t setTransformStruct:m0];
    [path transformUsingAffineTransform:t];
    [t setTransformStruct:m1];
    [path transformUsingAffineTransform:t];
    [t setTransformStruct:m2];
    [path transformUsingAffineTransform:t];
    [t setTransformStruct:m3];
    [path transformUsingAffineTransform:t];
    
	return path;
}

@end

//
// quartz specific code
//

@implementation MKElement (MKElementQuartzDrawing)

- (void)drawForWidget:(MKWidget *)widget {
    if (!self.visible)
        return;
    
	NSBezierPath *paintPath = [self sketchedFitPathForWidget:widget];
    
    // fill
        if (self.fill == 1) { // inherit
            if (widget.fillColor) {
                [widget.fillColor setFill];
                [paintPath fill];
            }
        } else if (self.fill == 2) { 
            [[NSColor whiteColor] setFill];
            [paintPath fill];
        } else if (self.fill == 3) { // gray
            NSImage *img = [NSImage imageNamed:@"graybg_s1"];
            [[NSColor colorWithPatternImage:img] setFill];
            [paintPath fill];
        } else if (self.fill == 4) { // black
            [[NSColor blackColor] setFill];
            [paintPath fill];
        } else if (self.fill == 5) { // stroke inherit
            if (widget.strokeColor) {
                [widget.strokeColor setFill];
                [paintPath fill];
            }
        } else if (self.fill == 6) { // shadow (transparent gray)
            [[NSColor colorWithCalibratedWhite:0 alpha:0.10] setFill];
            [paintPath fill];
        } else if (self.fill == 100) { // red
            [[NSColor redColor] setFill];
            [paintPath fill];
        }
    
    // stroke
	if (self.stroke > 0) {
        [paintPath setLineWidth:widget.sidebar ? 1.6 : [widget strokeWidth]];
        
        if (widget.strokeStyle == 2) {
            CGFloat pat[3];
            pat[0] = 5.0;
            pat[1] = 5.0;
            [paintPath setLineDash:pat count:2 phase:0.0];
        }
	}
    if (widget.strokeStyle > 0) {
            if (self.stroke == 1) { // inherit
                if (widget.strokeColor) {
                    [widget.strokeColor setStroke];
                    [paintPath stroke];
                }
            } else if (self.stroke == 2) { // white
                [[NSColor whiteColor] setStroke];
                [paintPath stroke];
            } else if (self.stroke == 3) { // gray
                [[NSColor grayColor] setStroke];
                [paintPath stroke];
            } else if (self.stroke == 4) { // black
                [[NSColor blackColor] setStroke];
                [paintPath stroke];
            } else if (self.stroke == 100) { // red
                [[NSColor redColor] setStroke];
                [paintPath stroke];
            }
    }
    
    for (id <MKHierarchicalElement> el in self.subelements) {
        [(MKElement *)el drawForWidget:widget];
    }
}

- (NSBezierPath *)sketchedFitPathForWidget:(MKWidget *)widget {
    NSBezierPath *drawPath = [NSBezierPath bezierPath];
	NSBezierPath *fittedPath = self.path;
    
    [drawPath setLineCapStyle:NSRoundLineCapStyle];
    [drawPath setLineJoinStyle:NSRoundLineJoinStyle];
    
	NSPoint currentPoint, lastPoint;
	NSPoint curvePoints[4];
	lastPoint = NSZeroPoint;
	int i;
	
	for(i = 0; i < [fittedPath elementCount]; i++) {
		switch ([fittedPath elementAtIndex:i]) {
			case NSMoveToBezierPathElement:
				[fittedPath elementAtIndex:i associatedPoints:&currentPoint];
				[drawPath moveToPoint:currentPoint];
				lastPoint = currentPoint;
				break;
			case NSLineToBezierPathElement:
				[fittedPath elementAtIndex:i associatedPoints:&currentPoint];
				[MKElement sketchToBezierPath:drawPath 
                                    fromPoint:lastPoint 
                                      toPoint:currentPoint 
                                     withSeed:seed];
				lastPoint = currentPoint;
				break;
			case NSCurveToBezierPathElement:
                curvePoints[0] = lastPoint;
                [fittedPath elementAtIndex:i associatedPoints:&curvePoints[1]];
				[drawPath curveToPoint:curvePoints[3] 
                         controlPoint1:curvePoints[1] 
                         controlPoint2:curvePoints[2]];
                lastPoint = curvePoints[3];
				break;
			case NSClosePathBezierPathElement:
				[drawPath closePath];
                lastPoint = [drawPath currentPoint];
				break;
		}
	}
	
	return drawPath;
}

//
// sketchy drawing stuff
//

float
randomFloat()
{
    return (float)random() / RAND_MAX;
}

int
randomSign()
{
    return random() % 2 == 0 ? -1 : 1;
}

float
handDrawnPosition(float x0, float xf, float t, float tf)
{
    float T = t / tf;
    return x0 + (x0 - xf) * (15 * powf(T, 4) - 6 * powf(T, 5) - 10 * powf(T, 3));
}

// Mimicking Hand-Drawn Pencil Lines 2008
// Computational Aesthetics in Graphics, Visualization, and Imaging (2008)
// Zainab Meraj1, Brian Wyvill1, Tobias Isenberg2, Amy A. Gooch1, Richard Guy3 1
// University of Victoria, BC,Canada 2
// University of Groningen, Netherlands 3
// University of Calgary, AB, Canada
+ (void)sketchToBezierPath:(NSBezierPath *)targPath 
                 fromPoint:(NSPoint)orig
                   toPoint:(NSPoint)dest
                  withSeed:(uint)seed {
    float x0 = orig.x;
    float y0 = orig.y;
    
    float xf = dest.x;
    float yf = dest.y;
    
    float dx = xf - x0;
    float dy = yf - y0;
    float m = dx / dy || 0;
    
    float d = sqrt(pow(xf - x0, 2) + pow(yf - y0, 2));
    
    float dt;
    if (d < 205) { // 200 is a common default, avoid bounce
        dt = 0.5;
    } else if (d < 400) {
        dt = 0.3;
    } else {
        dt = 0.2;
    }
    
    float t = 0;
    float tf = 2;
    
    float xt;
    float yt;

    float Dr = 0.9;
    float D;
    float Dx;
    float Dy;
    
    NSPoint pt;
    
    
    srandom(seed);
    
    while (t < (tf + dt)) {
        xt = handDrawnPosition(x0, xf, t, tf);
        yt = handDrawnPosition(y0, yf, t, tf);
        
        D = randomFloat() * Dr;
        Dx = sqrt(pow(D, 2) / (1 + pow(m,  2)));
        Dy = sqrt(pow(D, 2) / (1 + pow((float)1 / m, 2)));
        if (randomSign() > 0) {
            xt += Dx;
            yt -= Dy;
        } else {
            xt -= Dx;
            yt += Dy;
        }
        
        pt = NSMakePoint(xt, yt);
        [targPath lineToPoint:pt];
        
        t += dt;
    }
    
}
@end
