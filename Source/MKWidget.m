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

#import "MKWidget.h"
#import "MKElement.h"
#import "MKAppController.h"
#import "MKWindowController.h"
#import "MKDrawView.h"
#import "MKWidgetElement.h"

const float MKWidgetMinUngroupedWidth = 10.f;
const float MKWidgetMinUngroupedHeight = 10.f;
const float MKWidgetHandleSize = 4.0f;

float getScaleFactor(float value, float min, float max)
{
    if (value < min) {
        return value / min;
    } else if (value > max) {
        return value / max;
    } else {
        return 1.f;
    }
}

@implementation MKWidget

@synthesize frame, minNaturalSize, maxNaturalSize, widgetElement, fixedWidth, fixedHeight, strokeWidth, text, fillColor, strokeColor, strokeStyle, strokeCornerStyle, fontSize, fontStyleMask, textAlignment, sidebar, lockAspectRatio, debug, subelements, frameBase, properties, opacity, scaleXFactor, scaleYFactor, scaleFactorOrigin;

@dynamic root;

- (id)init {
    self = [super init];
	if (self) {
        _enabled = YES;
        _focused = NO;
        opacity = 1;
        properties = [NSMutableDictionary dictionary];
        
		_dragState = 0;
		_anchor = NSZeroPoint;
        lockAspectRatio  =NO;
        
        fillColor = [NSColor whiteColor];
        sidebar = NO;
		strokeColor = [NSColor blackColor];
		strokeWidth = 2.0;
        strokeStyle = 1;
        fontStyleMask = 0;
        textAlignment = NSNaturalTextAlignment;
        fontSize = 14.f;
		
		minNaturalSize = NSZeroSize; // below this the widget will be scaled
		maxNaturalSize = NSMakeSize(9999, 9999); // above this the widget will be scaled
        fixedWidth = 0;
        fixedHeight = 0;
		text = @"";
        
        subelements = [NSMutableArray array];
		
		NSSize size = [self defaultSize];
		frame = frameBase = NSMakeRect(10, 10, size.width, size.height);
        scaleXFactor = getScaleFactor(frame.size.width, minNaturalSize.width, maxNaturalSize.width);
        scaleYFactor = getScaleFactor(frame.size.height, minNaturalSize.height, maxNaturalSize.height);
        scaleFactorOrigin = frameBase.origin;
    }
	return self;
}

- (BOOL)isGrouped {
    return (self.widgetElement != nil);
}

/* element hieracrhy */

- (void)addSubelement:(id <MKHierarchicalElement>)element {
    [self.subelements addObject:element];
    [element setSuperelement:self];
    
}

- (void)setRoot:(MKWidget *)widget
{
    // intentionally blank
}

- (MKWidget *)root
{
    return nil; // i am root :)
}

/* geometry */

- (void)resizeSubelementsWithOldSize:(NSSize)oldSize {
    for (id <MKHierarchicalElement> el in self.subelements)
        [el resizeWithOldSuperelementSize:oldSize];
}

- (BOOL)isFixedWidth {
    return (self.fixedWidth > 0);
}

- (BOOL)isFixedHeight {
    return (self.fixedHeight > 0);
}

// OPTIMIZE can cache this with isGrouped as invalidator
- (NSSize)minSize {
    return NSMakeSize([self isFixedWidth] ? self.fixedWidth : ([self isGrouped] ? 0 : MKWidgetMinUngroupedWidth), 
                      [self isFixedHeight] ? self.fixedHeight : ([self isGrouped] ? 0 : MKWidgetMinUngroupedHeight));
}

// OPTIMIZE can cache this with isGrouped as invalidator
- (NSSize)maxSize {
    return NSMakeSize([self isFixedWidth] ? self.fixedWidth : 9999, 
                      [self isFixedHeight] ? self.fixedHeight : 9999);
}

- (void)moveByDeltaX:(float)deltaX 
              deltaY:(float)deltaY {
	[self setFrame:NSOffsetRect(self.frame, deltaX, deltaY)];
}

- (NSRect)drawFrame {
	return NSInsetRect(self.frame, 
                       -MKWidgetHandleSize - self.strokeWidth, 
                       -MKWidgetHandleSize - self.strokeWidth);
}

- (NSSize)constrainedSize:(NSSize)size {
    NSSize minSize = [self minSize];
    NSSize maxSize = [self maxSize];
    
	size.width = MIN(MAX(size.width, minSize.width), maxSize.width);
    
    // FIXME
    //if (self.lockAspectRatio) {
    //    size.height = size.width * (self.frame.size.height / self.frame.size.width);
    //} else {
        size.height = MIN(MAX(size.height, minSize.height), maxSize.height);
    //}
	
	return size;
}

- (NSRect)constrainedFrame:(NSRect)aFrame {
    NSSize intendedSize = aFrame.size;
    aFrame.size = [self constrainedSize:aFrame.size];
    
    // adjust origin, to account for size change
    if (aFrame.origin.x != frame.origin.x) {
        // we changed origin x, so update accordingly with constrained width
        aFrame.origin.x -= (aFrame.size.width - intendedSize.width); 
    }
    if (aFrame.origin.y != frame.origin.y) {
        // we changed origin y, so update accordingly with constrained height
        aFrame.origin.y -= (aFrame.size.height - intendedSize.height);
    } 

    return aFrame;
}

- (void)setFrame:(NSRect)aFrame {
    self.debug = [NSString stringWithFormat:@"Origin: %f,%f\nSize: %fx%f\nAspect Ratio: %f", 
                  aFrame.origin.x, aFrame.origin.y, aFrame.size.width, aFrame.size.height, 
                  aFrame.size.width / aFrame.size.height];
    
    frame = [self constrainedFrame:aFrame];
    self.scaleXFactor = getScaleFactor(frame.size.width, minNaturalSize.width, maxNaturalSize.width);
    self.scaleYFactor = getScaleFactor(frame.size.height, minNaturalSize.height, maxNaturalSize.height);
    
    NSRect oldFrameBase = frameBase;
    frameBase = NSMakeRect(frame.origin.x, frame.origin.y, 
                           MIN(self.maxNaturalSize.width, 
                               MAX(self.minNaturalSize.width, frame.size.width)), 
                           MIN(self.maxNaturalSize.height, 
                               MAX(self.minNaturalSize.height, frame.size.height)));
    self.scaleFactorOrigin = frameBase.origin;
    
    [self resizeSubelementsWithOldSize:oldFrameBase.size];
}

- (void)setLocation:(NSPoint)loc {
	NSRect b = self.frame;
	b.origin = loc;
	self.frame = b;
}

- (void)setSize:(NSSize)size {
	NSRect b = self.frame;
	b.size = [self constrainedSize:size];
	self.frame = b;
}

// TODO make this more intelligent (factor in path)
- (BOOL)containsPoint:(NSPoint)pt {
	return NSPointInRect(pt, [self drawFrame]);
}

- (NSRect)newFrameFromFrame:(NSRect)old 
                    forHandle:(int)whichOne 
                    withPoint:(NSPoint)p 
         withFixedAspectRatio:(BOOL)fixAspectRatio 
              withAspectRatio:(float)aspectRatio {
    
    //fixAspectRatio = self.lockAspectRatio || fixAspectRatio;
    
	NSRect nb = old;
       
    // TODO calc. for offset of point from center of handle
    
    // changing width
    if (whichOne == 1 || whichOne == 8 || whichOne == 7) {
        nb.size.width = NSMaxX(old) - p.x;
    } else if (whichOne == 3 || whichOne == 4 || whichOne == 5) {
        nb.size.width = p.x - NSMinX(old);
    }
    
    
    // changing height
    if (whichOne == 1 || whichOne == 2 || whichOne == 3) {
        nb.size.height = NSMaxY(old) - p.y;
    } else if (whichOne == 5 || whichOne == 6 || whichOne == 7) {
        nb.size.height = p.y - NSMinY(old);
    }
    
    // constrain min/max size
    nb.size = [self constrainedSize:nb.size];
    
    // maintain ratio of size
    float currentAspectRatio = nb.size.width / nb.size.height;
    if (fixAspectRatio && aspectRatio != currentAspectRatio && ![self isFixedWidth] && ![self isFixedHeight]) {
        NSSize minSize = [self minSize];
        NSSize maxSize = [self maxSize];
        
        if (whichOne == 2 || whichOne == 6 || ((whichOne % 2 == 1) && currentAspectRatio < aspectRatio)) {
            nb.size.width = MIN(MAX(nb.size.height * aspectRatio, minSize.width), maxSize.width);
            nb.size.height = MIN(MAX(nb.size.width / aspectRatio, minSize.height), maxSize.height);
        } else if (whichOne == 4 || whichOne == 8 || ((whichOne % 2 == 1) && currentAspectRatio > aspectRatio)) {
            nb.size.height = MIN(MAX(nb.size.width / aspectRatio, minSize.height), maxSize.height);
            nb.size.width = MIN(MAX(nb.size.height * aspectRatio, minSize.width), maxSize.width);
        }
    }
    
    // adjust origins if needed
    if (whichOne == 1 || whichOne == 7 || whichOne == 8) {
        nb.origin.x += (old.size.width - nb.size.width);
    }
    if (whichOne == 1 || whichOne == 2 || whichOne == 3) {
        nb.origin.y += (old.size.height - nb.size.height);
    } 
	
	return nb;
}

// override this if needed
- (NSSize)defaultSize {
	return NSMakeSize(200, 200);
}

+ (NSRect)widgetsFrame:(NSArray *)widgets {
    if ([widgets count] == 0) return NSZeroRect;
    
    MKWidget *widget = [widgets objectAtIndex:0];
    NSRect frm = widget.frame;
    
    for (widget in widgets) {
        frm = NSUnionRect(frm, widget.frame);
    }
    
    return frm;
}

/* selection */

- (NSArray *)handles {
    if (![self resizable] || ([self isFixedHeight] && [self isFixedWidth])) {
        return [NSArray arrayWithObjects:nil];
    } else if ([self isFixedHeight]) {
        return [NSArray arrayWithObjects:
                [NSNumber numberWithInteger:4], 
                [NSNumber numberWithInteger:8], 
                nil];
    } else if ([self isFixedWidth]) {
        return [NSArray arrayWithObjects:
                [NSNumber numberWithInteger:2], 
                [NSNumber numberWithInteger:6], 
                nil];
    } else {
        return [NSArray arrayWithObjects:
                [NSNumber numberWithInteger:1], 
                [NSNumber numberWithInteger:2], 
                [NSNumber numberWithInteger:3], 
                [NSNumber numberWithInteger:4], 
                [NSNumber numberWithInteger:5], 
                [NSNumber numberWithInteger:6], 
                [NSNumber numberWithInteger:7], 
                [NSNumber numberWithInteger:8], 
                nil];
    }
}

- (BOOL)resizable
{
    return YES;
}

- (void)drawHandlesForHover:(BOOL)hover {
    
    // draw box
    

    
	for (NSNumber *h in [self handles]) {
		[self drawAHandle:[h intValue] forHover:hover];
	}
    
    
    
    
}

- (void)drawAHandle:(int)whichOne 
           forHover:(BOOL)hover {
	NSRect hr = [self handleRect:whichOne];
    NSBezierPath *p;
    
    // account for current scaling in view
    MKAppController *ac = (MKAppController *)[NSApp delegate];
    
    if (hover) {
//        hr = [ac.docWindowController.drawView pixelAlignRect:hr withStroke:0];
//        
//        p = [NSBezierPath bezierPathWithRect:hr];
//        [[NSColor blackColor] setFill];
//        [p setLineWidth:0];
//        [p fill];
    } else {
        // TODO optimize: can calculate stroke width part 1x on zoom change
        float strokeSize = 1; // change this
        float s0 = strokeSize * (1 / ac.docWindowController.drawView.scale);
        s0 = [ac.docWindowController.drawView pixelAlignStroke:s0];
        hr = [ac.docWindowController.drawView pixelAlignRect:hr withStroke:s0];
        
        p = [NSBezierPath bezierPathWithRect:hr];
        
        
        [[NSColor whiteColor] setFill];
                [[NSColor colorWithDeviceWhite:0.0 alpha:0.4] setStroke];
             
        [p setLineWidth:s0];
        [p fill];
//        [[NSColor colorWithCalibratedRed:0.000 green:0.502 blue:1.000 alpha:1.000] setStroke];
   //      [[NSColor colorWithDeviceRed:0.000 green:0.659 blue:1.000 alpha:1.000] setFill];
        [p stroke];
        
//       hr = [ac.docWindowController.drawView pixelAlignRect:hr withStroke:0];
//       
//       p = [NSBezierPath bezierPathWithRect:hr];
//       [[NSColor colorWithDeviceRed:0.000 green:0.659 blue:1.000 alpha:1.000] setFill];
//       [p setLineWidth:0];
//       [p fill];
        
    }
}

- (int)handleAtPoint:(NSPoint)pt {
	NSRect hr;
	
	if (self.frame.size.width == 0 && self.frame.size.height == 0) {
		if ([self isFixedHeight] && [self isFixedWidth]) {
            return 0;
        } else if ([self isFixedHeight]) {
            return 4;
        } else if ([self isFixedWidth]) {
            return 6;
        } else {
            return 5;
        }
	} else {
        for (NSNumber *h in [self handles]) {
            hr = [self handleRect:[h intValue]];
			hr.size.width = hr.size.width + 1; // due to NSPointInRect not including right side inside
			hr.size.height = hr.size.height + 1; // due to NSPointInRect not including bottom side inside
			
			if (NSPointInRect(pt, hr)) {
				return [h intValue];
			}
        }
		return 0;
	}
}

- (NSRect)handleRect:(int)whichOne {
	NSPoint p;
	NSRect b = self.frame;
	
	switch (whichOne) {
		case 1:
			p.x = NSMinX(b);
			p.y = NSMinY(b);
			break;
		case 2:
			p.x = NSMidX(b);
			p.y = NSMinY(b);
			break;
		case 3:
			p.x = NSMaxX(b);
			p.y = NSMinY(b);
			break;
		case 4:
			p.x = NSMaxX(b);
			p.y = NSMidY(b);
			break;
		case 5:
			p.x = NSMaxX(b);
			p.y = NSMaxY(b);
			break;
		case 6:
			p.x = NSMidX(b);
			p.y = NSMaxY(b);
			break;
		case 7:
			p.x = NSMinX(b);
			p.y = NSMaxY(b);
			break;
		case 8:
			p.x = NSMinX(b);
			p.y = NSMidY(b);
			break;
	}
	
	b.origin = p;
	b.size = NSZeroSize;
    
    // account for current scaling in view
    MKAppController *ac = (MKAppController *)[NSApp delegate];
    
    // TODO optimization: can calculate 1x when zooming and store this in the view
    float scaleCorrect = 1 / ac.docWindowController.drawView.scale;
    float handleSize = MKWidgetHandleSize * scaleCorrect;
    
	NSRect r = NSInsetRect(b, -handleSize, -handleSize);
        
    return r;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeRect:self.frame forKey:@"bounds"];
    [coder encodeObject:self.text forKey:@"text"];
	[coder encodeObject:self.fillColor forKey:@"fill_color"];
	[coder encodeObject:self.strokeColor forKey:@"stroke_color"];
    [coder encodeInt:self.strokeStyle forKey:@"stroke_style"];
    [coder encodeInt:self.strokeCornerStyle forKey:@"stroke_corner_style"];
    [coder encodeFloat:self.fontSize forKey:@"font_size"];
    [coder encodeInteger:self.fontStyleMask forKey:@"font_style_mask"];
    [coder encodeInt:self.textAlignment forKey:@"text_alignment"];
    [coder encodeFloat:self.opacity forKey:@"opacity"];
    [coder encodeObject:self.properties forKey:@"properties"];
    [coder encodeBool:self.enabled forKey:@"enabled"];
    [coder encodeBool:self.focused forKey:@"focused"];
}

- (id)initWithCoder:(NSCoder *)coder {
	[self init];
    
    // NOTE take stuff from encodeWithCoder and find/replace with:
    // \[coder\sencode(.+?)\:(.+?)\sforKey:\@\"(.+?)\"\]\;
    // $2 = [coder decode$1ForKey:@"$3"];
    self.frame = [coder decodeRectForKey:@"bounds"];
    self.text = [coder decodeObjectForKey:@"text"];
    self.fillColor = [coder decodeObjectForKey:@"fill_color"];
    self.strokeColor = [coder decodeObjectForKey:@"stroke_color"];
    self.strokeStyle = [coder decodeIntForKey:@"stroke_style"];
    self.strokeCornerStyle = [coder decodeIntForKey:@"stroke_corner_style"];
    self.fontSize = [coder decodeFloatForKey:@"font_size"];
    self.fontStyleMask = [coder decodeIntegerForKey:@"font_style_mask"];
    self.textAlignment = [coder decodeIntForKey:@"text_alignment"];
    self.opacity = [coder decodeFloatForKey:@"opacity"];
    self.enabled = [coder decodeBoolForKey:@"enabled"];
    self.focused = [coder decodeBoolForKey:@"focused"];
    
    // think ruby Hash#merge :)
    NSDictionary *savedProperties = [coder decodeObjectForKey:@"properties"];
    for (id key in savedProperties) [self.properties setValue:[savedProperties valueForKey:key] 
                                                       forKey:key];
    
	return self;
}

/* NSCopying */

- (id)copyWithZone:(NSZone *)zone {
    MKWidget *copy = [[[self class] allocWithZone:zone] init];
    
    // NOTE take stuff from encodeWithCoder and find/replace with:
    // \[coder\sencode(.+?)\:self\.(.+?)\sforKey:\@\"(.+?)\"\]\;
    // copy.$2 = self.$2;
    copy.frame = self.frame;
    copy.text = self.text;
    copy.fillColor = self.fillColor;
    copy.strokeColor = self.strokeColor;
    copy.strokeStyle = self.strokeStyle;
    copy.strokeCornerStyle = self.strokeCornerStyle;
    copy.fontSize = self.fontSize;
    copy.fontStyleMask = self.fontStyleMask;
    copy.textAlignment = self.textAlignment;
    copy.opacity = self.opacity;
    copy.enabled = self.enabled;
    copy.focused = self.focused;
    
    // think ruby Hash#merge :)
    for (id key in self.properties) [copy.properties setValue:[self.properties valueForKey:key] 
                                                       forKey:key];
    
    return copy;
}


/* undo machinary */

- (NSDictionary *)keyPathsToObserveForUndo {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"Move/Resize", @"frame", 
            @"Text", @"text", 
            @"Fill Color", @"fillColor", 
            @"Stroke Color", @"strokeColor", 
            @"Stroke Style", @"strokeStyle", 
            @"Stroke Corner Style", @"strokeCornerStyle", 
            @"Font Size", @"fontSize", 
            @"Font Style", @"fontStyleMask", 
            @"Text Alignment", @"textAlignment", 
            @"Opacity", @"opacity",
            @"Enabled", @"enabled",
            @"Focused", @"focused", 
            nil];
}

/* text */

- (BOOL)hasEditableText {
    return NO;
}

- (BOOL)useSingleLineEditableTextMode {
    return NO;
}

- (BOOL)editOnAdd {
    return NO;
}

/* effective opacity */

- (float)effectiveOpacity
{
    return self.opacity;
}

/* kinds */

static NSMutableArray *kinds = nil;

+ (NSArray *)kinds
{
    if (kinds == nil)
        kinds = [NSMutableArray array];
    
    return (NSArray *)kinds;
}

+ (void)registerKind:(Class)kind
{
    if (kinds == nil)
        kinds = [NSMutableArray array];
    
    if (![kinds containsObject:kind])
        [kinds addObject:kind];
}

+ (void)load
{
    // don't register ourselves
}

+ (NSString *)filters
{
    return @"ios mac web";
}

+ (NSString *)keywords
{
    return self.description;
}

@end

// quartz specific stuff

@implementation MKWidget (MKWidgetQuartzDrawing)

- (void)drawRect:(NSRect)rect 
   withSelection:(BOOL)selected {
	if (NSIntersectsRect(rect, [self drawFrame])) {
        NSGraphicsContext *graphicsContext;
        CGContextRef graphicsPort;
        BOOL hasOpacity = [self effectiveOpacity] != 1;
        
        if (hasOpacity) {
            graphicsContext = [NSGraphicsContext currentContext];
            graphicsPort = (CGContextRef)[graphicsContext graphicsPort];
            [graphicsContext saveGraphicsState];
            CGContextSetAlpha(graphicsPort, [self effectiveOpacity]);
            CGContextBeginTransparencyLayer(graphicsPort, NULL);
        }
        
        for (id el in self.subelements) {
            [(MKElement *)el drawForWidget:self];
        }
        
        if (hasOpacity) {
            CGContextEndTransparencyLayer(graphicsPort);
            [graphicsContext restoreGraphicsState];
        }
    }
        
    BOOL isScreen = [NSGraphicsContext currentContextDrawingToScreen];
    if (isScreen && selected) {
        
        // TODO optimize: can calculate stroke width part 1x on zoom change
        NSRect hr = self.frame;
        NSBezierPath *p;
        
        // account for current scaling in view
        MKAppController *ac = (MKAppController *)[NSApp delegate];
        
        hr = [ac.docWindowController.drawView pixelAlignRect:hr withStroke:0];
        
        p = [NSBezierPath bezierPathWithRect:hr];
        [[NSColor colorWithDeviceWhite:0 alpha:0.1] setFill];
        [p setLineWidth:0];
        [p fill];
    }
}

- (NSImage *)asImage {
    float padding = 20; // white space added around image before resize
    
    // prepare canvas
    NSSize imgSize = NSInsetRect(self.frame, -padding, -padding).size;
    
    
    NSImage *img = [[NSImage alloc] initWithSize:imgSize];
    [img setFlipped:YES];
    
    // align draw bounds
    [self moveByDeltaX:-(self.frame.origin.x - padding)
                deltaY:-(self.frame.origin.y - padding)];
    
    // draw into image
    [img lockFocus];
    [self drawRect:self.frame withSelection:NO];
    [img unlockFocus];
    
    // resize to desired size
    //float width = targetSize.width;
    //float height = (self.bounds.size.height / self.bounds.size.width) * width;
    //[img setSize:NSMakeSize(width, height)];
    
    return img;
}

@end
