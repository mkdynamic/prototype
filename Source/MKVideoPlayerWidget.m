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

#import "MKVideoPlayerWidget.h"
#import "MKElement.h"
#import "MKTriangleElement.h"
#import "MKRoundedRectElement.h"

@implementation MKVideoPlayerWidget
- (id)init {
	if ((self = [super init])) {
        minNaturalSize = NSMakeSize(213, 130); // 1/3rd default size
        NSRect r = NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height);
        NSRect f;
        MKElement *el;
        float playButtonWidth = 30;
        float playButtonHeight = 30;
        float playButtonBoxPadding = 5;
        
        // box bg (fuzzed)
        f = r;
        f.size.width += 1.f;
        f.origin.y -= 1.f;
        f.size.height += 2.f;
        f.origin.x += 1.f;
        el = [[MKElement alloc] initWithFrame:f withStroke:0 withFill:3];
        [[el pin] flex];
        [self addSubelement:el];
        
        // box
        f = r;
        el = [[MKElement alloc] initWithFrame:f withStroke:1 withFill:0];
        [[el pin] flex];
        [self addSubelement:el];
        
        // play box
        f = NSInsetRect(r, (r.size.width - playButtonWidth) / 2, (r.size.height - playButtonHeight) / 2);
        f = NSInsetRect(f, -playButtonBoxPadding * 6, -playButtonBoxPadding * 2);
        MKRoundedRectElement *playBoxEl = [[MKRoundedRectElement alloc] initWithFrame:f withStroke:1 withFill:0];
        playBoxEl.radius = playButtonBoxPadding;
        //[self addSubelement:playBoxEl];
        
        // play icon
        f = NSInsetRect(r, (r.size.width - playButtonWidth) / 2, (r.size.height - playButtonHeight) / 2);
        MKTriangleElement *playIconEl = [[MKTriangleElement alloc] initWithFrame:f withStroke:1 withFill:2];
        [self addSubelement:playIconEl];
	}
	return self;
}

- (NSSize)defaultSize {
    return NSMakeSize(640, 390); // size of vid. on youtube
}

+ (void)load
{
    [self registerKind:self];
}

@end
