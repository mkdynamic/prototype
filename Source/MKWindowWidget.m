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

#import "MKWindowWidget.h"
#import "MKElement.h"
#import "MKTextElement.h"

@implementation MKWindowWidget
- (id)init {
	if ((self = [super init])) {
        _els = [NSMutableDictionary dictionary];
        text = @"Window";
        textAlignment = NSCenterTextAlignment;
        minNaturalSize = NSMakeSize(135, 100);
        
        NSRect r = NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height);
        NSRect f;
        float titleHeight = 23;
        
        // shadow
        f = NSOffsetRect(r, 6, 6);
        MKElement *shadowEl = [[MKElement alloc] initWithFrame:f withStroke:0 withFill:6];
        [[shadowEl pin] flex];
        [self addSubelement:shadowEl];
        
        // white bg
        f = r;
        MKElement *bgEl = [[MKElement alloc] initWithFrame:f withStroke:0 withFill:1];
        [[bgEl pin] flex];
        [self addSubelement:bgEl];
        
        // title bg
        f = r;
        f.size.height = titleHeight;
        MKElement *titleBgEl = [[MKElement alloc] initWithFrame:f withStroke:0 withFill:3];
        [[titleBgEl pin:@"Left", @"Top", @"Right", nil] flex:@"Width", nil];
        [self addSubelement:titleBgEl];
        
        // title line
        f = r;
        f.size.height = 1;
        f.origin.y = titleHeight;
        MKElement *titleLineEl = [[MKElement alloc] initWithFrame:f withStroke:1 withFill:0];
        NSBezierPath *b = [NSBezierPath bezierPath];
        [b moveToPoint:NSZeroPoint];
        [b lineToPoint:NSMakePoint(1, 0)];
        titleLineEl.path = b;
        [[titleLineEl pin] flex];
        [self addSubelement:titleLineEl];
        
        // title text
        f = titleBgEl.frame;
        MKTextElement *titleTextEl = [[MKTextElement alloc] initWithFrame:f];
        titleTextEl.verticalAlignment = MKMiddleVerticalTextAlignment;
        titleTextEl.lineBreakMode = NSLineBreakByClipping;
        [[titleTextEl pin:@"Left", @"Top", @"Right", nil] flex:@"Width", nil];
        [self addSubelement:titleTextEl];
        
        // border
        f = r;
        MKElement *borderEl = [[MKElement alloc] initWithFrame:f withStroke:1 withFill:0];
        [[borderEl pin] flex];
        [self addSubelement:borderEl];
	}
	return self;
}

- (BOOL)hasEditableText
{
    return YES;
}

- (BOOL)useSingleLineEditableTextMode
{
    return YES;
}

- (NSSize)defaultSize
{
    return NSMakeSize(640, 480);
}

+ (void)load
{
    [self registerKind:self];
}
@end
