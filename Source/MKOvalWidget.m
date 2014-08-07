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

#import "MKOvalWidget.h"
#import "MKElement.h"

@implementation MKOvalWidget
- (id)init {
    self = [super init];
	if (self) {
        NSRect r = NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height);
        
        // box
        MKElement *bgEl = [[MKElement alloc] initWithFrame:r withStroke:1 withFill:1];
        [[bgEl pin:@"Top", @"Right", @"Bottom", @"Left", nil] flex:@"Width", @"Height", nil];
        bgEl.path = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(0, 0, 1, 1)];
        [self addSubelement:bgEl];
    }
    
	return self;
}

+ (void)load
{
    [self registerKind:self];
}

+ (NSString *)filters
{
    return @"ios mac web";
}
@end
