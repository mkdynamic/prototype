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

#import "MKRadioWidget.h"
#import "MKTextElement.h"
#import "MKElement.h"
#import "MKImageElement.h"

static const float boxSize = 13;
static const float padding = 5;
static const float leftOffset = boxSize + padding;

@implementation MKRadioWidget
- (id)init {
	if ((self = [super init])) {
        fixedHeight = 20;
        self.minNaturalSize = NSMakeSize(50, 20);
        self.maxNaturalSize = NSMakeSize(400, FLT_MAX);
        text = @"Radio"; // avoid prop. since we mess with setter
        
        properties[@"state"] = @0; // 0 = unchecked, 1 = checked
        [self addObserver:self
               forKeyPath:@"properties.state"
                  options:(NSKeyValueObservingOptionNew)
                  context:nil];
        
        // some common vars
        NSRect r = NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height);
        
        // text
        NSRect textRect = NSMakeRect(leftOffset, 0, r.size.width - leftOffset, r.size.height);
        self.textEl = [[MKTextElement alloc] initWithFrame:textRect];
        self.textEl.verticalAlignment = MKMiddleVerticalTextAlignment;
        self.textEl.lineBreakMode = NSLineBreakByClipping;
        [[self.textEl pin] flex];
        [self addSubelement:self.textEl];
        
        // box
        float offset = (r.size.height - boxSize) / 2;
        NSRect boxRect = NSMakeRect(0, offset, boxSize, boxSize);
        MKElement *boxEl = [[MKElement alloc] initWithFrame:boxRect withStroke:1 withFill:1];
        boxEl.path = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(0, 0, 1, 1)];
        [[boxEl pin:@"Left", nil] fix];
        [self addSubelement:boxEl];
        self.outerEl = boxEl;
        
        // check
        NSRect checkRect = NSInsetRect(boxRect, 4, 4);
        self.checkEl = [[MKElement alloc] initWithFrame:checkRect withStroke:0 withFill:4];
        self.checkEl.path = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(0, 0, 1, 1)];
        [[self.checkEl pin:@"Left", nil] fix];
        self.checkEl.visible = [self.properties[@"state"]  isEqual: @1];
        [self addSubelement:self.checkEl];
        
        // auto size to fit text
        NSRect f = frame;
        f.size.width = [self.textEl widthToFit] + leftOffset;
        frame = frameBase = f;
        
        // recalc width of textRect
        textRect.size.width = f.size.width - leftOffset;
        self.textEl.frame = textRect;
	}
	return self;
}

- (BOOL)resizable
{
    return NO;
}

- (void)autoFitFrame {
    self.frame = self.frame;
}

- (void)setFrame:(NSRect)aFrame
{
    aFrame.size.width = [self.textEl widthToFit] + leftOffset;
    aFrame.size = [self constrainedSize:aFrame.size];
    [super setFrame:aFrame];
}

- (void)setText:(NSString *)someText
{
    [self willChangeValueForKey:@"text"];
    text = someText;
    [self didChangeValueForKey:@"text"];
    
    [self autoFitFrame];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
	self.checkEl.visible = [self.properties[@"state"] isEqualTo:@1] || [self.properties[@"state"] isEqualTo:@2] || [self.properties[@"state"] isEqualTo:@3];
    
    if ([self.properties[@"state"] isEqualTo:@1]) {
        self.checkEl.fill = 4;
        self.outerEl.stroke = 1;
    } else if ([self.properties[@"state"] isEqualTo:@2]) {
        self.checkEl.fill = 3;
        self.outerEl.stroke = 3;
    } else if ([self.properties[@"state"] isEqualTo:@3]) {
        self.checkEl.fill = 3;
        self.outerEl.stroke = 1;
    }
}

- (NSDictionary *)keyPathsToObserveForUndo
{
    NSMutableDictionary *dict = [[super keyPathsToObserveForUndo] mutableCopy];
    dict[@"properties.state"] = @"Change Radio State";
    return [NSDictionary dictionaryWithDictionary:dict];
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

+ (NSString *)filters
{
    return @"mac web";
}
@end
