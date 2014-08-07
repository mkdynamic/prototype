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

#import "MKWindowDragView.h"
#import "MKAppController.h"

// NOTE The click to drag, unless you hit anything code is mostly lifted from Chrome:
// http://codereview.chromium.org/9230001/diff/6001/chrome/browser/ui/cocoa/tabs/tab_strip_controller.mm

@interface MKWindowDragView ()
- (void)trackClickForWindowMove:(NSEvent *)event;
@end

@implementation MKWindowDragView

- (BOOL)mouseDownCanMoveWindow
{
    return NO;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

- (void)trackClickForWindowMove:(NSEvent*)event {
    NSWindow *window = [self window];
    NSPoint frameOrigin = [window frame].origin;
    NSPoint lastEventLoc = [window convertBaseToScreen:[event locationInWindow]];
    
    while ((event = [NSApp nextEventMatchingMask:NSLeftMouseDownMask | NSLeftMouseDraggedMask | NSLeftMouseUpMask
                                       untilDate:[NSDate distantFuture]
                                          inMode:NSEventTrackingRunLoopMode
                                         dequeue:YES]) && [event type] != NSLeftMouseUp) {
        NSPoint now = [window convertBaseToScreen:[event locationInWindow]];
        frameOrigin.x += now.x - lastEventLoc.x;
        frameOrigin.y += now.y - lastEventLoc.y;
        [window setFrameOrigin:frameOrigin];
        lastEventLoc = now;
    }
} 

- (void)mouseDown:(NSEvent *)theEvent
{
    if (!([[self window] styleMask] & NSFullScreenWindowMask)) {
        [self trackClickForWindowMove:theEvent];
        return;
    }
    
    [super mouseDown:theEvent];
}

//- (void)mouseUp:(NSEvent *)theEvent 
//{
//    if ([theEvent clickCount] == 2) {
//        // Get settings from "System Preferences" >  "Appearance" > "Double-click on windows title bar to minimize"
//        NSString *const MDAppleMiniaturizeOnDoubleClickKey = @"AppleMiniaturizeOnDoubleClick";
//        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//        [userDefaults addSuiteNamed:NSGlobalDomain];
//        BOOL shouldMiniaturize = [[userDefaults objectForKey:MDAppleMiniaturizeOnDoubleClickKey] boolValue];
//        if (shouldMiniaturize) {
//            [[self window] miniaturize:self];
//        }
//    }
//}

@end
