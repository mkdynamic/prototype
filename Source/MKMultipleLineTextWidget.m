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

#import "MKMultipleLineTextWidget.h"
#import "MKTextElement.h"
#import "MKElement.h"

@implementation MKMultipleLineTextWidget
- (id)init
{
    self = [super init];
    
	if (self) {
        text = @"A wonderful paragraph of text, awesome and interesting some may say.";
        
        NSRect r = {NSZeroPoint, self.frame.size};
        
       // MKElement *b = [[MKElement alloc] initWithFrame:r withStroke:100 withFill:0];
        //[[b pin] flex];
      //  [self addSubelement:b];
        
        
        MKTextElement *el = [[MKTextElement alloc] initWithFrame:r];
//        el.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [[el pin] flex];
        [self addSubelement:el];
    }
    
	return self;
}

- (NSSize)defaultSize
{
    return NSMakeSize(225, 200);
}

- (BOOL)hasEditableText
{
    return YES;
}

- (BOOL)editOnAdd {
    return NO;
}

+ (void)load
{
    [self registerKind:self];
}
@end
