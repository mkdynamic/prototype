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

#import "MKVerticalSliderWidget.h"
#import "MKElement.h"

static const float knobRadius = 7;

@interface MKVerticalSliderWidget ()
- (void)updateKnobPosition;
@end

@implementation MKVerticalSliderWidget
- (id)init
{
    self = [super init];
    
	if (self) {
        properties[@"value"] = @(0.5);
        for (NSString *keyPath in @[@"properties.value"]) {
            [self addObserver:self
                   forKeyPath:keyPath
                      options:(NSKeyValueObservingOptionNew)
                      context:nil];
        }
        
        fixedWidth = 0.1;
        NSRect r = {.size = NSMakeSize(0, self.frame.size.height)};
        NSRect f;
        
        // line
        f = r;
        MKElement *el = [[MKElement alloc] initWithFrame:f withStroke:1 withFill:0];
        NSBezierPath *p = [NSBezierPath bezierPath];
        [p moveToPoint:NSZeroPoint];
        [p lineToPoint:NSMakePoint(0, 1)];
        el.path = p;
        [[el pin:@"Top", @"Bottom", nil] flex:@"Height", nil];
        [self addSubelement:el];
        
        // knob
        float value = [self.properties[@"value"] floatValue];
        f = NSMakeRect(-knobRadius, (1 - value) * self.frame.size.height - knobRadius, knobRadius * 2, knobRadius * 2);
        self.knobEl = [[MKElement alloc] initWithFrame:f withStroke:1 withFill:1];
        self.knobEl.path = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(0, 0, 1, 1)];;
        [self addSubelement:self.knobEl];
    }
    
	return self;
}

- (void)updateKnobPosition
{
    float value = [self.properties[@"value"] floatValue];
    NSLog(@"%f", value);
    NSRect f = self.knobEl.frame;
    f.origin.y = (1 - value) * self.frame.size.height - knobRadius;
    self.knobEl.frame = f;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    [self updateKnobPosition];
}

- (NSSize)defaultSize
{
    return NSMakeSize(fixedWidth, 200);
}

+ (void)load
{
    [self registerKind:self];
}
@end
