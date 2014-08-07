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

#import "MKSingleLineTextInputWidget.h"
#import "MKElement.h"
#import "MKTextElement.h"

@implementation MKSingleLineTextInputWidget
- (id)init {
	if ((self = [super init])) {
        fixedHeight = 20;
        self.minNaturalSize = NSMakeSize(50, 20);
        self.maxNaturalSize = NSMakeSize(400, FLT_MAX);
        self.textAlignment = NSLeftTextAlignment;
        self.text = @"Text Input";
        
        // some common vars
        NSRect r = NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height);
        
        // bg
        MKElement *bgEl = [[MKElement alloc] initWithFrame:r withStroke:1 withFill:1];
        [[bgEl pin:@"Top", @"Right", @"Bottom", @"Left", nil] flex:@"Width", @"Height", nil];
        [self addSubelement:bgEl];
        
        // text
        NSRect textRect = NSMakeRect(0, 0, r.size.width, r.size.height);
        textRect.origin.x += 5;
        textRect.size.width -= 5;
        MKTextElement *textEl = [[MKTextElement alloc] initWithFrame:textRect];
        //textEl.text = @"";
        textEl.verticalAlignment = MKMiddleVerticalTextAlignment;
        textEl.alignment = self.textAlignment;
        textEl.lineBreakMode = NSLineBreakByClipping;
        textAlignment = NSCenterTextAlignment;
        [[textEl pin] flex];
        [bgEl addSubelement:textEl];
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

+ (NSString *)filters
{
    return @"mac web";
}
@end
