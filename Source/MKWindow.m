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

#import "MKWindow.h"

static const float titleBarViewHeight = 36.0f;
static const float _trafficLightButtonsLeftMargin = 10.0f;

@implementation MKWindow
@synthesize titleBarView;

- (BOOL) canBecomeKeyWindow
{
    return YES;
}

- (void)becomeKeyWindow
{
    [super becomeKeyWindow];
}

- (void)resignKeyWindow
{
    [super resignKeyWindow];
}

- (void)setContentView:(NSView *)aView
{
    NSButton *closeButton = [NSWindow standardWindowButton:NSWindowCloseButton 
                                              forStyleMask:NSTitledWindowMask];
    
    NSView *frameView = aView;
    [closeButton setFrameOrigin:NSZeroPoint];
    [frameView addSubview:closeButton];
    [super setContentView:aView];
}

- (id)initWithContentRect:(NSRect)contentRect 
                styleMask:(NSUInteger)aStyle 
                  backing:(NSBackingStoreType)bufferingType 
                    defer:(BOOL)flag
{
    self = [super initWithContentRect:contentRect 
                            styleMask:aStyle   
                              backing:bufferingType 
                                defer:flag];
    
    if (self) {
    }
    
    return self;
}

- (id)initWithContentRect:(NSRect)contentRect 
                styleMask:(NSUInteger)aStyle 
                  backing:(NSBackingStoreType)bufferingType 
                    defer:(BOOL)flag screen:(NSScreen *)screen
{
    self = [super initWithContentRect:contentRect 
                            styleMask:aStyle 
                              backing:bufferingType 
                                defer:flag 
                               screen:screen];
    
    if (self) {
    }
    
    return self;
}
@end
