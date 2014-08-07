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

#import "MKTriangleElement.h"

@implementation MKTriangleElement

@synthesize direction;

- (NSBezierPath *)defaultPath {
	NSBezierPath *trianglePath = [NSBezierPath bezierPath];
	NSPoint trianglePoints[3];
	
	switch (direction) {
		case 1: // upwards
			trianglePoints[0] = NSMakePoint(0.5, 0);
			trianglePoints[1] = NSMakePoint(1, 1);
			trianglePoints[2] = NSMakePoint(0, 1);
			break;
		case 2: // downwards
			trianglePoints[0] = NSZeroPoint;
			trianglePoints[1] = NSMakePoint(1, 0);
			trianglePoints[2] = NSMakePoint(0.5, 1);
			break;
		case 3: // leftwards
			trianglePoints[0] = NSMakePoint(1, 0);
			trianglePoints[1] = NSMakePoint(1, 1);
			trianglePoints[2] = NSMakePoint(0, 0.5);
			break;
		default: // rightwards
			trianglePoints[0] = NSZeroPoint;
			trianglePoints[1] = NSMakePoint(1, 0.5);
			trianglePoints[2] = NSMakePoint(0, 1);
			break;
	}
	
	[trianglePath appendBezierPathWithPoints:trianglePoints count:3];
	[trianglePath closePath];
	
	return trianglePath;
}

@end
