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

#import "MKDropDownSelectWidget.h"
#import "MKElement.h"
#import "MKTriangleElement.h"
#import "MKTextElement.h"

@implementation MKDropDownSelectWidget

- (id)init {
	if ((self = [super init])) {
        fixedHeight = 20;
        self.minNaturalSize = NSMakeSize(50, 20);
        self.maxNaturalSize = NSMakeSize(400, FLT_MAX);
        self.text = @"Combo";
        
        // some common vars
        NSRect r = NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height);
        float toggleWidth = r.size.height;
        float arrowSize = toggleWidth * 0.4;
        
        // bg
        MKElement *bgEl = [[MKElement alloc] initWithFrame:r withStroke:0 withFill:1];
        [[bgEl pin:@"Top", @"Right", @"Bottom", @"Left", nil] flex:@"Width", @"Height", nil];
        [self addSubelement:bgEl];
        
        // text
        NSRect textRect = NSMakeRect(0, 0, r.size.width - toggleWidth, r.size.height);
        textRect.origin.x += 5;
        textRect.size.width -= 5;
        MKTextElement *textEl = [[MKTextElement alloc] initWithFrame:textRect];
        //textEl.text = @"Select an option";
        textEl.verticalAlignment = MKMiddleVerticalTextAlignment;
        textEl.alignment = NSLeftTextAlignment;
        textEl.lineBreakMode = NSLineBreakByClipping;
        textAlignment = NSCenterTextAlignment;
        [[textEl pin] flex];
        [bgEl addSubelement:textEl];
        
        // arrow
        NSRect arrowRect = NSMakeRect(r.size.width - toggleWidth + ((toggleWidth - arrowSize) / 2), (r.size.height - arrowSize) / 2, arrowSize, arrowSize);
        MKTriangleElement *arrowEl = [[MKTriangleElement alloc] initWithFrame:arrowRect withStroke:0 withFill:5];
        arrowEl.direction = 2;
        [[arrowEl pin:@"Right", nil] fix];
        [bgEl addSubelement:arrowEl];
        
        // line
        NSRect lineRect = NSMakeRect(r.size.width - toggleWidth, 0, 0, r.size.height);
        MKElement *lineEl = [[MKElement alloc] initWithFrame:lineRect withStroke:1 withFill:0];
        NSBezierPath *linePath = [NSBezierPath bezierPath];
        [linePath moveToPoint:NSMakePoint(0, 0)];
        [linePath lineToPoint:NSMakePoint(0, 1)];
        
        lineEl.path = linePath;
        [[lineEl pin:@"Top", @"Right", @"Bottom", nil] flex:@"Height", nil];
        [bgEl addSubelement:lineEl];
        
        MKElement *borderEl = [[MKElement alloc] initWithFrame:r withStroke:1 withFill:0];
        [[borderEl pin:@"Top", @"Right", @"Bottom", @"Left", nil] flex:@"Width", @"Height", nil];
        [bgEl addSubelement:borderEl];
	}
	return self;
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
