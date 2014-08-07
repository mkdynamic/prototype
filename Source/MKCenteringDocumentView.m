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

#import "MKCenteringDocumentView.h"

static const float shadowSize = 9.0f;

@interface MKCenteringDocumentView ()

- (void)documentViewFrameChangedNotification:(NSNotification *)note;
- (void)positionDocumentView;

@end

@implementation MKCenteringDocumentView

@synthesize documentView;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    }
    
    return self;
}

- (BOOL)isFlipped
{
    return YES;
}

- (void)setDocumentView:(NSView *)aView
{
    NSNotificationCenter *noteCenter = [NSNotificationCenter defaultCenter];
    
    // abandon existing doc view if set
    if (documentView != nil) {
        [noteCenter removeObserver:self
                              name:NSViewFrameDidChangeNotification
                            object:documentView];
        [documentView removeFromSuperview];
        documentView = nil;
    }
    
    // adopt new doc view
    documentView = aView;
    [self addSubview:documentView];
    [documentView setAutoresizingMask:NSViewNotSizable];
    [noteCenter addObserver:self 
                   selector:@selector(documentViewFrameChangedNotification:) 
                       name:NSViewFrameDidChangeNotification
                     object:documentView];
    
    [self positionDocumentView];
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldSize
{
    [super resizeSubviewsWithOldSize:oldSize];
    [self positionDocumentView];
}

- (void)documentViewFrameChangedNotification:(NSNotification *)note
{
    [self positionDocumentView];
}

// via https://github.com/omnigroup/OmniGroup/blob/master/Frameworks/OmniAppKit/Widgets.subproj/OADocumentPositioningView.m
- (void)positionDocumentView
{
    NSView *superview = [self superview];
    NSSize contentSize = [superview frame].size;
    
    NSRect oldDocumentFrame = [self.documentView frame];
    NSRect newDocumentFrame = oldDocumentFrame;
    NSRect oldFrame = [self frame];
    NSRect newFrame = oldFrame;
    
    // ensure our size is the greater of the scroll view content size or document view size
    newFrame.size.width = MAX(oldDocumentFrame.size.width, contentSize.width);
    newFrame.size.height = MAX(oldDocumentFrame.size.height, contentSize.height);
    if (!NSEqualRects(newFrame, oldFrame)) {
        [self setFrameSize:newFrame.size];
        [superview setNeedsDisplayInRect:NSUnionRect(oldFrame, newFrame)];
    }
    
    // set document frame to center it
    newDocumentFrame.origin.x = floor((newFrame.size.width - newDocumentFrame.size.width) / 2.0f);
    newDocumentFrame.origin.y = floor((newFrame.size.height - newDocumentFrame.size.height) / 2.0f);
    if (!NSEqualPoints(newDocumentFrame.origin, oldDocumentFrame.origin)) {
        [documentView setFrameOrigin:newDocumentFrame.origin];
        [self setNeedsDisplayInRect:NSUnionRect(NSInsetRect(oldDocumentFrame, -50, -50), NSInsetRect(newDocumentFrame, -50, -50))];
    }
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect bb = [self.documentView frame];
    
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:bb];
    
    NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
    [shadow setShadowColor:[NSColor colorWithDeviceWhite:0 alpha:0.75]];
    [shadow setShadowBlurRadius:shadowSize];
    [shadow setShadowOffset:NSMakeSize(0, -(shadowSize / 3))];
    
    [NSGraphicsContext saveGraphicsState];
    [shadow set];
    [path fill];
    [NSGraphicsContext restoreGraphicsState];
}

@end
