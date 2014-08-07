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

#import "NSAttributedString+Metrics.h"

@implementation NSAttributedString (Metrics)
- (NSSize)sizeWithSize:(NSSize)size
{
    // container
    NSTextContainer *container = [[[NSTextContainer alloc] initWithContainerSize:size] autorelease];
    
    // layout manager
    NSLayoutManager *layoutManager = [[[NSLayoutManager alloc] init] autorelease];
    [layoutManager addTextContainer:container];
    
    // text store
    NSTextStorage *store = [[[NSTextStorage alloc] initWithAttributedString:self] autorelease];
    [store addLayoutManager:layoutManager];
    
    // trigger drawing
    [container setLineFragmentPadding:0.0]; // this is important
    [layoutManager setUsesFontLeading:NO];
    (void) [layoutManager glyphRangeForTextContainer:container];
    
    // return size
    return [layoutManager usedRectForTextContainer:container].size;
}

- (NSSize)sizeWithWidth:(CGFloat)width
{
    return [self sizeWithSize:NSMakeSize(width, FLT_MAX)];
}

- (NSSize)sizeWithHeight:(CGFloat)height
{
    return [self sizeWithSize:NSMakeSize(FLT_MAX, height)];
}

- (CGFloat)heightWithWidth:(CGFloat)width
{
    return [self sizeWithWidth:width].height;
}

- (CGFloat)widthWithHeight:(CGFloat)height
{
    return [self sizeWithHeight:height].width;
}
@end
