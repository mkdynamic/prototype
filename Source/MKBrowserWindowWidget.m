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

#import "MKBrowserWindowWidget.h"
#import "MKElement.h"
#import "MKTriangleElement.h"
#import "MKTextElement.h"

@implementation MKBrowserWindowWidget

@synthesize textTitle, textUrl;

- (id)init
{
    self = [super init];
    
	if (self) {
		minNaturalSize = NSMakeSize(200, 175);
		text = @"Prototype\nhttp://example.com";
    
        // corners
        NSRect r = NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height);
        float lineHeight = 45;
        float titleBarHeight = 10;
        float topHeight = lineHeight + titleBarHeight;
        float arrowSize = 20;
        
        // shadow
        NSRect f = NSOffsetRect(r, 6, 6);
        MKElement *shadowEl = [[MKElement alloc] initWithFrame:f withStroke:0 withFill:6];
        [[shadowEl pin] flex];
        [self addSubelement:shadowEl];
        
        // sketch window bg (gray)
        MKElement *bg = [[MKElement alloc] initWithFrame:r withStroke:0 withFill:3];
        [[bg pin:@"Top", @"Right", @"Bottom", @"Left", nil] flex:@"Width", @"Height", nil];
        [self addSubelement:bg];
        
        // sketch content bg (white)
        NSRect contentBGRect = r;
        contentBGRect.origin.y += topHeight;
        contentBGRect.size.height -= topHeight;
        MKElement *contentBG = [[MKElement alloc] initWithFrame:contentBGRect withStroke:0 withFill:1];
        [[contentBG pin:@"Top", @"Right", @"Bottom", @"Left", nil] flex:@"Width", @"Height", nil];
        [bg addSubelement:contentBG];
        
        // sketch window outline
        MKElement *outline = [[MKElement alloc] initWithFrame:r withStroke:1 withFill:0];
        [[outline pin:@"Top", @"Right", @"Bottom", @"Left", nil] flex:@"Width", @"Height", nil];
        [bg addSubelement:outline];
        
        // sketch top line
        NSRect lineRect = contentBGRect;
        lineRect.size.height = 0;
        MKElement *linePart = [[MKElement alloc] initWithFrame:lineRect withStroke:1 withFill:0];
        NSBezierPath *linePath = [NSBezierPath bezierPath];
        [linePath moveToPoint:NSMakePoint(1, 0)];
        [linePath lineToPoint:NSZeroPoint];
        linePart.path = linePath;
        [[linePart pin:@"Top", @"Right",  @"Left", nil] flex:@"Width", nil];
        [outline addSubelement:linePart];
        
        // sketch left arrow
        float arrowOffset = (lineHeight - arrowSize) / 2;
        NSRect leftArrowRect = NSMakeRect(r.origin.x + arrowOffset, r.origin.y + arrowOffset + titleBarHeight, arrowSize, arrowSize);
        MKTriangleElement *leftArrow = [[MKTriangleElement alloc] initWithFrame:leftArrowRect withStroke:1 withFill:1];
        leftArrow.direction = 3;
        [[leftArrow pin:@"Top", @"Left", nil] fix:@"Height", @"Width", nil];
        [outline addSubelement:leftArrow];
        
        // sketch left arrow
        NSRect rightArrowRect = NSOffsetRect(leftArrowRect, arrowSize + 5, 0);
        MKTriangleElement *rightArrow = [[MKTriangleElement alloc] initWithFrame:rightArrowRect withStroke:1 withFill:1];
        rightArrow.direction = 4;
        [[rightArrow pin:@"Top", @"Left", nil] fix:@"Height", @"Width", nil];
        [outline addSubelement:rightArrow];
        
        // sketch address bar
        float addressBarX = NSMaxX(rightArrowRect) + 10;
        NSRect addressBarRect = NSMakeRect(addressBarX, rightArrowRect.origin.y, r.size.width - addressBarX - arrowOffset, arrowSize);
        MKElement *addressBar = [[MKElement alloc] initWithFrame:addressBarRect withStroke:1 withFill:1];
        [[addressBar pin:@"Top", @"Left", @"Right", nil] flex:@"Width", nil];
        [outline addSubelement:addressBar];
        
        // address text
        NSRect urlElRect = {NSZeroPoint, addressBarRect.size};
        urlElRect = NSInsetRect(urlElRect, 5, 0);
        urlEl = [[MKTextElement alloc] initWithFrame:urlElRect];
        urlEl.text = @"http://example.com";
        urlEl.alignment = NSLeftTextAlignment;
        urlEl.verticalAlignment = MKMiddleVerticalTextAlignment;
        urlEl.lineBreakMode = NSLineBreakByTruncatingTail;
       // urlEl.textSize = 12.f;
        [[urlEl pin] flex];
        [addressBar addSubelement:urlEl];
        
        // browser title
        NSRect titleElRect = r;
        titleElRect.size.height = titleBarHeight + arrowOffset;
        titleEl = [[MKTextElement alloc] initWithFrame:titleElRect];
        titleEl.text = @"Prototype";
        titleEl.alignment = NSCenterTextAlignment;
        titleEl.verticalAlignment = MKMiddleVerticalTextAlignment;
        titleEl.lineBreakMode = NSLineBreakByTruncatingTail;
        //titleEl.textSize = 12.f;
        [[titleEl pin:@"Top", @"Right", @"Left", nil] flex:@"Width", nil];
        [bg addSubelement:titleEl];
	}
    
	return self;
}

- (NSSize)defaultSize
{
	return NSMakeSize(1024, 768);
}

- (BOOL)hasEditableText
{
    return YES;
}

+ (void)load
{
    [self registerKind:self];
}

- (void)setText:(NSString *)someText
{
    text = someText;
    
    NSArray *parts = [text componentsSeparatedByString:@"\n"];
    self.textTitle = [parts count] > 0 ? [parts objectAtIndex:0] : @"";
    self.textUrl = [parts count] > 1 ? [parts objectAtIndex:1] : @"";
}

- (void)setTextUrl:(NSString *)aTextUrl
{
    urlEl.text = textUrl = aTextUrl;
}

- (void)setTextTitle:(NSString *)aTextTitle
{
    titleEl.text = textTitle = aTextTitle;
}

+ (NSString *)filters
{
    return @"web";
}

@end
