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

#import "MKSearchInputWidget.h"
#import "MKElement.h"
#import "MKTextElement.h"
#import "MKImageElement.h"

@implementation MKSearchInputWidget
- (id)init {
	if ((self = [super init])) {
        fixedHeight = 20;
        self.minNaturalSize = NSMakeSize(50, 20);
        self.maxNaturalSize = NSMakeSize(400, FLT_MAX);
        textAlignment = NSLeftTextAlignment;
        self.text = @"Search";
        
        // some common vars
        NSRect r = NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height);
        
        float capSize = fixedHeight / 2;
        
        NSRect f;
        NSBezierPath *b;
        MKElement *el;
        
        // middle lines
        f = NSInsetRect(r, capSize - 1, 0);
        el = [[MKElement alloc] initWithFrame:f withStroke:0 withFill:1];
        [[el pin] flex];
        [self addSubelement:el];
        
        // left cap line
        f = r;
        f.size.width = capSize;
        el = [[MKElement alloc] initWithFrame:f withStroke:0 withFill:1];
        b = [NSBezierPath bezierPath];
        [b appendBezierPathWithArcWithCenter:NSMakePoint(0.5, 0.5) radius:0.5 startAngle:90.0 endAngle:180.0];
        [b appendBezierPathWithArcWithCenter:NSMakePoint(0.5, 0.5) radius:0.5 startAngle:180.0 endAngle:270.0];
        el.path = b;
        [[el pin:@"Left", @"Top", @"Bottom", nil] flex:@"Height", nil];
        [self addSubelement:el];
        
        // right cap line
        f = r;
        f.size.width = capSize;
        f.origin.x = r.size.width - capSize;
        el = [[MKElement alloc] initWithFrame:f withStroke:0 withFill:1];
        b = [NSBezierPath bezierPath];
        [b appendBezierPathWithArcWithCenter:NSMakePoint(0.5, 0.5) radius:0.5 startAngle:270.0 endAngle:0.0];
        [b appendBezierPathWithArcWithCenter:NSMakePoint(0.5, 0.5) radius:0.5 startAngle:0.0 endAngle:90.0];
        el.path = b;
        [[el pin:@"Right", @"Top", @"Bottom", nil] flex:@"Height", nil];
        [self addSubelement:el];
        
        // middle bg
        f = NSInsetRect(r, capSize, 0);
        el = [[MKElement alloc] initWithFrame:f withStroke:1 withFill:0];
        b = [NSBezierPath bezierPath];
        [b moveToPoint:NSMakePoint(0, 0)];
        [b lineToPoint:NSMakePoint(1, 0)];
        [b moveToPoint:NSMakePoint(1, 1)];
        [b lineToPoint:NSMakePoint(0, 1)];
        el.path = b;
        [[el pin] flex];
        [self addSubelement:el];
        
        // left cap bg
        f = r;
        f.size.width = capSize;
        el = [[MKElement alloc] initWithFrame:f withStroke:1 withFill:0];
        b = [NSBezierPath bezierPath];
        [b appendBezierPathWithArcWithCenter:NSMakePoint(0.5, 0.5) radius:0.5 startAngle:90.0 endAngle:180.0];
        [b appendBezierPathWithArcWithCenter:NSMakePoint(0.5, 0.5) radius:0.5 startAngle:180.0 endAngle:270.0];
        el.path = b;
        [[el pin:@"Left", @"Top", @"Bottom", nil] flex:@"Height", nil];
        [self addSubelement:el];
        
        // right cap bg
        f = r;
        f.size.width = capSize;
        f.origin.x = r.size.width - capSize;
        el = [[MKElement alloc] initWithFrame:f withStroke:1 withFill:0];
        b = [NSBezierPath bezierPath];
        [b appendBezierPathWithArcWithCenter:NSMakePoint(0.5, 0.5) radius:0.5 startAngle:270.0 endAngle:0.0];
        [b appendBezierPathWithArcWithCenter:NSMakePoint(0.5, 0.5) radius:0.5 startAngle:0.0 endAngle:90.0];
        el.path = b;
        [[el pin:@"Right", @"Top", @"Bottom", nil] flex:@"Height", nil];
        [self addSubelement:el];
        
        // mag glass
        f = r;
        f.size.width = f.size.height;
        f = NSInsetRect(f, 2, 2);
        f.origin.x += 2;
        NSString *imagePath = [[NSBundle mainBundle] pathForImageResource:@"icon_search.png"];
        MKImageElement *magEl = [[MKImageElement alloc] initWithFrame:f withStroke:0 withFill:0];
        magEl.url = [NSURL fileURLWithPath:imagePath];
        magEl.sketch = NO;
        [[magEl pin:@"Left", nil] fix];
        [self addSubelement:magEl];
        
        // text
        f = r;
        f.origin.x += capSize + 10;
        f.size.width -= capSize + 12;
        MKTextElement *textEl = [[MKTextElement alloc] initWithFrame:f];
        textEl.verticalAlignment = MKMiddleVerticalTextAlignment;
        textEl.lineBreakMode = NSLineBreakByClipping;
        textEl.alignment = NSNaturalTextAlignment;
        textEl.color = [NSColor grayColor];
        
        [[textEl pin] flex];
        [self addSubelement:textEl];
	}
	return self;
}

- (NSSize)defaultSize {
    return NSMakeSize(200, 20);
}

- (BOOL)hasEditableText {
    return YES;
}

- (BOOL)useSingleLineEditableTextMode
{
    return YES;
}

+ (void)load
{
    [self registerKind:self];
}
@end
