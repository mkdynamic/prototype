//
//  LTPixelAlign.m
//
//  Created by Jacob Xiao on 10/21/09.
//  Copyright 2009 Like Thought.

/*
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files
 (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge,
 publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to
 do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
 IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "LTPixelAlign.h"

@implementation NSView (LTPixelAlign)

- (CGFloat)pixelAlignStroke:(CGFloat)stroke
{
	NSSize strokeSize = NSMakeSize(stroke, 0.0);
	strokeSize = [self convertSizeToBase:strokeSize];
	
	if (strokeSize.width < 1.0)
		strokeSize.width = ceilf(strokeSize.width);
	else
		strokeSize.width = roundf(strokeSize.width);
	
	strokeSize = [self convertSizeFromBase:strokeSize];
	return strokeSize.width;
}

- (NSPoint)pixelAlignPoint:(NSPoint)point withStroke:(CGFloat)stroke
{
	stroke = [self pixelAlignPixelizedHalfStroke:stroke];
	point = [self convertPointToBase:point];
	
	point.x = roundf(point.x - stroke) + stroke;
	point.y = roundf(point.y - stroke) + stroke;
	
	point = [self convertPointFromBase:point];
	return point;
}

- (NSRect)pixelAlignRect:(NSRect)rect withStroke:(CGFloat)stroke
{
	stroke = [self pixelAlignPixelizedHalfStroke:stroke];
	rect = [self convertRectToBase:rect];
	
	rect.origin.x = roundf(rect.origin.x - stroke) + stroke;
	rect.origin.y = roundf(rect.origin.y - stroke) + stroke;
	rect.size.width = roundf(rect.size.width);
	rect.size.height = roundf(rect.size.height);
	
	rect = [self convertRectFromBase:rect];
	return rect;
}

- (CGFloat)pixelAlignPixelizedHalfStroke:(CGFloat)stroke
{
	NSSize strokeSize = NSMakeSize(stroke, 0.0);
	strokeSize = [self convertSizeToBase:strokeSize];
	stroke = strokeSize.width;
	stroke = stroke < 1 ? ceilf(stroke) : roundf(stroke);
    
    if (fmod(stroke, 2) > 0) stroke *= 0.5; // half unless odd
	
	return stroke;
}

@end
