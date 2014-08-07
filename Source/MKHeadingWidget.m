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

#import "MKHeadingWidget.h"
#import "MKTextElement.h"

@interface MKHeadingWidget ()
- (void)autoFitFrame;
@end

@implementation MKHeadingWidget
- (id)init
{
    self = [super init];
    
	if (self) {
        text = [[self class] headingText];
        
        
        
        fontSize = [[self class] headingFontSize];
        
        el = [[MKTextElement alloc] initWithFrame:frame];
        //el.lineBreakMode = NSLineBreakByTruncatingTail;
        [[el pin] flex];
        [self addSubelement:el];
        
        NSRect f = frame;
        f.size.width = [el widthToFit];
        f.size.height = [el heightToFit];
        frame = frameBase = f;
        
        NSRect r = frame;
        r.origin = NSZeroPoint;
        el.frame = r;
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
    aFrame.size.height = [el heightToFit];
    aFrame.size.width = [el widthToFit];
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

- (void)setFontSize:(float)aFontSize
{
    [self willChangeValueForKey:@"fontSize"];
    fontSize = aFontSize;
    [self didChangeValueForKey:@"fontSize"];
    
    [self autoFitFrame];
}

- (void)setFontStyleMask:(NSUInteger)aFontStyleMask
{
    [self willChangeValueForKey:@"fontStyleMask"];
    fontStyleMask = aFontStyleMask;
    [self didChangeValueForKey:@"fontStyleMask"];
    
    [self autoFitFrame];
}

- (BOOL)hasEditableText
{
    return YES;
}

- (BOOL)useSingleLineEditableTextMode
{
    return YES;
}

- (BOOL)editOnAdd {
    return NO;
}

+ (float)headingFontSize {
    return 30.f;
}

+ (NSString *)headingText {
    return @"Heading";
}
@end
