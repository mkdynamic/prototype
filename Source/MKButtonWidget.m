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

#import "MKButtonWidget.h"
#import "MKRoundedRectElement.h"
#import "MKTextElement.h"

@interface MKButtonWidget ()

- (void)toggleState;

@end

@implementation MKButtonWidget

- (id)init
{
	if ((self = [super init])) {
        _els = [NSMutableDictionary dictionary];
        
        properties[@"state"] = @(NSOffState);
        for (NSString *keyPath in @[@"enabled", @"focused", @"properties.state"]) {
            [self addObserver:self
                   forKeyPath:keyPath
                      options:(NSKeyValueObservingOptionNew)
                      context:nil];
        }
        
        textAlignment = NSCenterTextAlignment;
        text = @"Button";
        
        NSRect r = NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height);
        NSRect f;
        
        // shadow (on)
        f = NSOffsetRect(r, -2, -2);
        f.size.width += 2;
        f.size.height += 2;
        MKRoundedRectElement *shadowOnEl = [[MKRoundedRectElement alloc] initWithFrame:f withStroke:0 withFill:5];
        shadowOnEl.radius = 0;
        [[shadowOnEl pin] flex];
        shadowOnEl.visible = NO;
        [self addSubelement:shadowOnEl];
        _els[@"shadowOn"] = shadowOnEl;
        
        // shadow (off)
        f = NSOffsetRect(r, 2, 2);
        MKRoundedRectElement *shadowOffEl = [[MKRoundedRectElement alloc] initWithFrame:f withStroke:0 withFill:5];
        shadowOffEl.radius = 0;
        [[shadowOffEl pin] flex];
        shadowOffEl.visible = YES;
        [self addSubelement:shadowOffEl];
        _els[@"shadowOff"] = shadowOffEl;
        
        // box
        f = r;
        MKRoundedRectElement *boxEl = [[MKRoundedRectElement alloc] initWithFrame:f withStroke:1 withFill:1];
        boxEl.radius = 0;
        [boxEl flex];
        [self addSubelement:boxEl];
        _els[@"box"] = boxEl;
        
        // text
        f = r;
        MKTextElement *textEl = [[MKTextElement alloc] initWithFrame:f];
        textEl.verticalAlignment = MKMiddleVerticalTextAlignment;
        textEl.lineBreakMode = NSLineBreakByClipping;
        [[textEl pin] flex];
        [self addSubelement:textEl];
        _els[@"text"] = textEl;
	}
	return self;
}

- (void)toggleState
{
    switch ([self.properties[@"state"] integerValue]) {
        case NSOffState:
            ((MKElement *)self.els[@"shadowOn"]).visible = NO;
            ((MKElement *)self.els[@"shadowOff"]).visible = YES;
            break;
        case NSOnState:
            ((MKElement *)self.els[@"shadowOn"]).visible = YES;
            ((MKElement *)self.els[@"shadowOff"]).visible = NO;
            break;
    }
    
    if (!self.enabled) {
        self.strokeColor = [NSColor grayColor];
    } else {
        self.strokeColor = self.focused ? [NSColor blueColor] : [NSColor blackColor];
    }
}

- (void)setFocused:(BOOL)focused
{
    [super setFocused:focused];
    [self toggleState];
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    [self toggleState];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
	[self toggleState];
}

- (BOOL)hasEditableText
{
    return YES;
}

- (NSSize)defaultSize
{
    return NSMakeSize(100, 30);
}

+ (void)load
{
    [self registerKind:self];
}

@end
