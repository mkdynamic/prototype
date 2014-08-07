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

#import "MKRectangleWidget.h"
#import "MKRoundedRectElement.h"

@implementation MKRectangleWidget
- (id)init {
	if ((self = [super init])) {
        self.properties[@"cornerStyle"] = @0; // square = 0, round = 1
        
        [self addObserver:self
               forKeyPath:@"properties.cornerStyle"
                  options:(NSKeyValueObservingOptionNew)
                  context:nil];
        
        NSRect r = NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height);
        
        self.el = [[MKRoundedRectElement alloc] initWithFrame:r withStroke:1 withFill:1];
        self.el.radius = 0.0f;
        [[self.el pin:@"Top", @"Right", @"Bottom", @"Left", nil] flex:@"Width", @"Height", nil];
        [self addSubelement:self.el];
    }
    
	return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
	self.el.radius = [[self.properties valueForKey:@"cornerStyle"] isEqualTo:@0] ? 0.0f : 10.0f;
    self.el.path = [self.el defaultPath];
}

- (NSDictionary *)keyPathsToObserveForUndo
{
    NSMutableDictionary *dict = [[super keyPathsToObserveForUndo] mutableCopy];
    dict[@"properties.cornerStyle"] = @"Change Corner Style";
    return [NSDictionary dictionaryWithDictionary:dict];
}

+ (void)load
{
    [self registerKind:self];
}
@end
