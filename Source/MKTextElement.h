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

#import "MKElement.h"

typedef struct {
    CGFloat top;
    CGFloat right;
    CGFloat bottom;
    CGFloat left;
} MKTextMargin;

NS_INLINE MKTextMargin MKMakeTextMargin(CGFloat top, CGFloat right, CGFloat bottom, CGFloat left) {
    MKTextMargin m;
    m.top = top;
    m.right = right;
    m.bottom = bottom;
    m.left = left;
    return m;
}

typedef enum NSUInteger {
    MKTopVerticalTextAlignment = 0,
    MKMiddleVerticalTextAlignment = 1,
    MKBottomVerticalTextAlignment = 2
} MKVerticalTextAlignment;

@interface MKTextElement : MKElement {
@private
	NSString *text;
    float textSize;
    MKTextMargin margin;
    MKVerticalTextAlignment verticalAlignment;
    NSTextAlignment alignment;
    NSLineBreakMode lineBreakMode;
    NSMutableAttributedString *textToDraw;
    
    // font metrics
    float fontSize;
    NSFont *font;
    float leading;
    float effectiveLineHeight;
    float lineHeight;
    NSMutableParagraphStyle *par;
    NSRect textRect;
    NSDictionary *parAttrs;
    NSTextAlignment effectiveAlignment;
}

@property (copy) NSString *text;
@property float textSize;
@property MKTextMargin margin;
@property MKVerticalTextAlignment verticalAlignment;
@property NSTextAlignment alignment;
@property NSLineBreakMode lineBreakMode;
@property (copy) NSColor *color;

- (id)initWithFrame:(NSRect)aRect andText:(NSString *)someText;
- (float)widthToFit;
- (float)heightToFit;
@end
