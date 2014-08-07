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

#import "MKCheckboxWidget.h"
#import "MKTextElement.h"
#import "MKRoundedRectElement.h"
#import "MKImageElement.h"

static const float boxSize = 12;
static const float padding = 5;
static const float leftOffset = boxSize + padding;

@interface MKCheckboxWidget ()

- (void)toggleCheckElement;

@end

@implementation MKCheckboxWidget

- (id)init
{
	if ((self = [super init])) {
        fixedHeight = 20;
        self.minNaturalSize = NSMakeSize(50, 20);
        self.maxNaturalSize = NSMakeSize(400, FLT_MAX);
        text = @"Checkbox"; // avoid prop. since we mess with setter
        
        properties[@"state"] = @(NSOffState);
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
        self.boxEl = [[MKRoundedRectElement alloc] initWithFrame:boxRect withStroke:1 withFill:1];
        self.boxEl.radius = 1;
        [[self.boxEl pin:@"Left", nil] fix];
        [self addSubelement:self.boxEl];
        
        // check (on state)
        NSRect checkRect = NSMakeRect(-1, -2, r.size.height - 2, r.size.height - 2);
        NSString *imagePath = [[NSBundle mainBundle] pathForImageResource:@"icon_tick.png"];
        self.checkOnEl = [[MKImageElement alloc] initWithFrame:checkRect withStroke:0 withFill:0];
        self.checkOnEl.url = [NSURL fileURLWithPath:imagePath];
        self.checkOnEl.sketch = NO;
        [[self.checkOnEl pin:@"Left", nil] fix];
        [self addSubelement:self.checkOnEl];
        
        // check (mixed state)
        checkRect = NSInsetRect(boxRect, 2, 4);
        self.checkMixedEl = [[MKElement alloc] initWithFrame:checkRect withStroke:0 withFill:4];
        [[self.checkMixedEl pin:@"Left", nil] fix];
        [self addSubelement:self.checkMixedEl];
        
        // setup initial state
        [self toggleCheckElement];
        self.enabled = self.enabled;
        
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

- (void)toggleCheckElement
{
    switch ([self.properties[@"state"] integerValue]) {
        case NSMixedState:
            self.checkMixedEl.visible = YES;
            self.checkOnEl.visible = NO;
            break;
        case NSOnState:
            self.checkMixedEl.visible = NO;
            self.checkOnEl.visible = YES;
            break;
        case NSOffState:
            self.checkMixedEl.visible = NO;
            self.checkOnEl.visible = NO;
        default:
            break;
    }
}

- (void)setEnabled:(BOOL)isEnabled
{
    [super setEnabled:isEnabled];
    
    if (!isEnabled) {
        self.checkMixedEl.fill = 3;
       // self.checkOnEl.fill = 3;
        self.boxEl.stroke = 3;
        self.textEl.color = [NSColor grayColor];
        
    } else {
        self.checkMixedEl.fill = 4;
      //  self.checkOnEl.fill = 4;
        self.boxEl.stroke = 1;
        self.textEl.color = nil;
    }
}

- (BOOL)resizable
{
    return NO;
}

- (void)autoFitFrame
{
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
	[self toggleCheckElement];
}

- (NSDictionary *)keyPathsToObserveForUndo
{
    NSMutableDictionary *dict = [[super keyPathsToObserveForUndo] mutableCopy];
    dict[@"properties.state"] = @"Change Checkbox State";
    return [NSDictionary dictionaryWithDictionary:dict];
}

- (NSSize)defaultSize
{
    return NSMakeSize(200, 20);
}

- (BOOL)hasEditableText
{
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
