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

#import <Cocoa/Cocoa.h>

@interface MKZoomView : NSView {
@private
    float scale;
}

@property float scale;
@property (readonly) float minimumScale;
@property (readonly) float maximumScale;

- (IBAction)zoomIn:(id)sender;
- (IBAction)zoomOut:(id)sender;
- (IBAction)zoomToActualSize:(id)sender;
- (IBAction)zoomFitInWindow:(id)sender;

- (void)zoomViewByFactor:(float)factor;
- (void)zoomViewToAbsoluteScale:(float)scale;
- (void)zoomViewToFitRect:(NSRect)aRect;
- (void)zoomViewToRect:(NSRect)aRect;
- (void)zoomViewToPaddedRect:(NSRect)aRect;
- (void)zoomViewByFactor:(float)factor andCentrePoint:(NSPoint)p;
- (void)zoomWithScrollWheelDelta:(float) delta toCentrePoint:(NSPoint)cp;

- (NSPoint)centredPointInDocView;
- (void)scrollPointToCentre:(NSPoint)aPoint;

- (float)minimumScale;
- (float)maximumScale;

- (void)performZoom:(float)aScale;

@end
