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

#import "MKTextElement.h"
#import "MKWidget.h"
#import "NSAttributedString+Metrics.h"
#import "MKTextMarkup.h"
#import "MKFont.h"
#import "MKWindowController.h"
#import "MKAppController.h"

static const float minFontSize = 6.f;
static const BOOL showDebug = NO;
static NSString *fontName = @"Helvetica Neue";

@interface MKTextElement ()
- (void)prepareTextAll;
- (void)prepareTextString;
- (void)prepareTextRect;
@end

@implementation MKTextElement
@synthesize text, textSize, margin, verticalAlignment, alignment, lineBreakMode;

- (id)init {
    self = [super init];
    
    if (self) {
        text = nil;
        textSize = 0;
        margin = MKMakeTextMargin(0, 0, 0, 0);
        verticalAlignment = MKTopVerticalTextAlignment;
        alignment = NSNaturalTextAlignment;
        lineBreakMode = [[NSParagraphStyle defaultParagraphStyle] lineBreakMode];
        textToDraw = [[NSMutableAttributedString alloc] init];
        self.color = nil;
    }
    
    return self;
}

- (id)initWithFrame:(NSRect)aRect 
            andText:(NSString *)someText
{
    self = [super initWithFrame:aRect];
    
    if (self) {
        text = someText;
    }
    
    return self;
}

- (void)prepareTextAll
{
    // font size
    fontSize = self.textSize ? self.textSize : self.root.fontSize;
    NSColor *col = self.color ? self.color : self.root.strokeColor;
    
    // scale font size if needed
    float sx = self.root.scaleXFactor;
    float sy = self.root.scaleYFactor;
    fontSize *= sx * sy;
    
    // enforce minimum font size
    fontSize = MAX(minFontSize, fontSize);
    fontSize *= 1;
    
    // font + metrics
    font = [MKFont fontWithName:fontName
                           size:fontSize];
    
    // NOTE these defintions are as per http://cl.ly/212Z3a141F0L1K1A400e
    //      in particular, note that line height includes leading
    float ascent = font.ascender;
    float descent = font.descender;
    leading = (ascent - descent) * 0.12; // i.e. 12% leading
    lineHeight = ascent - descent + leading;
    effectiveLineHeight = lineHeight - leading;
    
    // alignment
    effectiveAlignment =
        self.alignment != NSNaturalTextAlignment ? 
        self.alignment : 
        self.root.textAlignment;
    
    // para style
    par = [[NSMutableParagraphStyle alloc] init];
    
    // alignment
    [par setAlignment:effectiveAlignment];
    
    // line breaks
    [par setLineBreakMode:self.lineBreakMode];
    
    // vertical space
    // NOTE we subtract the leading here because NSParagraphStyle's concept of line height 
    //      excludes leading, contrary to this info. http://cl.ly/212Z3a141F0L1K1A400e
    // NOTE don't fiddle with this stuff, change the lineHeight/leading values above :)
    [par setMaximumLineHeight:effectiveLineHeight];
    [par setMinimumLineHeight:effectiveLineHeight];
    [par setLineSpacing:leading];
    [par setLineHeightMultiple:0]; // min/max enforces fixed line-height
    [par setParagraphSpacingBefore:0];
    [par setParagraphSpacing:0];
//    [par setTabStops:@[
//     [[NSTextTab alloc] initWithType:NSLeftTabStopType location:0],
//     [[NSTextTab alloc] initWithType:NSLeftTabStopType location:20],
//     [[NSTextTab alloc] initWithType:NSLeftTabStopType location:40]
//    ]];
    
    // attribs
    parAttrs = [[NSDictionary alloc] initWithObjectsAndKeys:
                col, NSForegroundColorAttributeName,
                par, NSParagraphStyleAttributeName,
                font, NSFontAttributeName,
                nil];
    
    // since this impacts everything...
    [self prepareTextString];
}

// NOTE this is reasonably expensive text layout, so we only
//      call this when one of the inputs it depends on changes
//      via KVO on ourself and the widget (see below)
- (void)prepareTextString
{
    // calc string to draw
    NSString *str = self.text ? self.text : self.root.text;
    
    // textilize
    textToDraw = [[NSMutableAttributedString alloc] initWithString:str
                                                        attributes:parAttrs];
    
    // apply global font traits
    [textToDraw applyFontTraits:self.root.fontStyleMask 
                          range:NSMakeRange(0, [textToDraw length])];
    
  //  [textToDraw applyFontTraits:NSFontWeightTrait range:<#(NSRange)#>
    
    // textilize
    [MKTextMarkup markup:textToDraw];
    
    // since this impacts rect...
    [self prepareTextRect];
}

- (void)prepareTextRect
{
    // bounds
    textRect = [self.path bounds];
    
    // calc bounding box for text
    NSSize bs = [textToDraw sizeWithWidth:textRect.size.width];
    
    // adjust for visible lines
    if (lineHeight - leading > textRect.size.height) {
        // 1 line is taller than the entire text rect so we limit to our 
        // rect, and shift the baseline up to attempt to center the 
        bs.height = textRect.size.height;
    } else {
        int visibleLines = floor(textRect.size.height / lineHeight);
        int totalLines = floor(bs.height / lineHeight);
        
        if (totalLines > visibleLines) {
            float visibleHeight = (visibleLines * lineHeight) - leading;
            bs.height = visibleHeight;
        }
    }
    
    // adjust target rect per vertical alignment
    float dY = 0;
    switch (self.verticalAlignment) {
        case MKMiddleVerticalTextAlignment:
            dY = (textRect.size.height - bs.height) / 2;
            break;
        case MKBottomVerticalTextAlignment:
            dY = textRect.size.height - bs.height;
            break;
        default:
            break;
    }
    textRect.origin.y += dY;
    textRect.size.height -= dY;
}

- (float)widthToFit
{
    NSSize bs = [textToDraw sizeWithHeight:[self.path bounds].size.height];
    return bs.width;
}

- (float)heightToFit
{
    NSSize bs = [textToDraw sizeWithWidth:FLT_MAX];
    return bs.height;
}

- (void)setRoot:(MKWidget *)widget
{
    [super setRoot:widget];
    
    if (self.textSize) {
        [self addObserver:self 
               forKeyPath:@"textSize" 
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld 
                  context:@"prepareTextAll"];
    } else {
        [widget addObserver:self 
                 forKeyPath:@"fontSize" 
                    options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld 
                    context:@"prepareTextAll"];
    }
    
    if (self.alignment == NSNaturalTextAlignment) {
        [widget addObserver:self 
                 forKeyPath:@"textAlignment" 
                    options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld 
                    context:@"prepareTextAll"];
    } else {
        [self addObserver:self 
               forKeyPath:@"aligment" 
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld 
                  context:@"prepareTextAll"];
    }
    
    [widget addObserver:self 
             forKeyPath:@"strokeColor" 
                options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld 
                context:@"prepareTextAll"];
    [self addObserver:self
             forKeyPath:@"color"
                options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                context:@"prepareTextAll"];
    
    if (self.text == nil) {
        [widget addObserver:self 
                 forKeyPath:@"text" 
                    options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld 
                    context:@"prepareTextString"];
    } else {
        [self addObserver:self 
               forKeyPath:@"text" 
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld 
                  context:@"prepareTextString"];
    }
    
    [widget addObserver:self 
             forKeyPath:@"fontStyleMask" 
                options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld 
                context:@"prepareTextString"];
    
    // OPTIMIZE if frame size changes it will trigger > 1 recalc of text
    [widget addObserver:self 
             forKeyPath:@"scaleXFactor" 
                options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                context:@"prepareTextAll"];
    [widget addObserver:self 
             forKeyPath:@"scaleYFactor" 
                options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld 
                context:@"prepareTextAll"];
    
    // OPTIMIZE only change on frame size, do something smarter for frame origin change
    [widget addObserver:self 
             forKeyPath:@"frame" 
                options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld 
                context:@"prepareTextRect"];
    
    [self prepareTextAll];
}

- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object 
                        change:(NSDictionary *)change 
                       context:(void *)context 
{
    if ([((NSString *)context) isEqualToString:@"prepareTextRect"]) {
        if ([[change valueForKey:NSKeyValueChangeOldKey] isNotEqualTo:[change valueForKey:NSKeyValueChangeNewKey]]) {
            [self prepareTextRect];
        }
    } else if ([((NSString *)context) isEqualToString:@"prepareTextString"]) {
        if ([[change valueForKey:NSKeyValueChangeOldKey] isNotEqualTo:[change valueForKey:NSKeyValueChangeNewKey]]) {
            [self prepareTextString];
        }
    } else if ([((NSString *)context) isEqualToString:@"prepareTextAll"]) {
        if ([[change valueForKey:NSKeyValueChangeOldKey] isNotEqualTo:[change valueForKey:NSKeyValueChangeNewKey]]) {
            [self prepareTextAll];
        }
        
    } else {
        [super observeValueForKeyPath:keyPath 
                             ofObject:object
                               change:change
                              context:context];
    }
}
@end

// OPTIMIZE
@implementation MKTextElement (MKElementQuartzDrawing)
- (void)drawForWidget:(MKWidget *)widget
{
    if (!self.visible)
        return;
    
    [textToDraw drawInRect:textRect];

    // draw children
    for (id <MKHierarchicalElement> el in self.subelements)
        [(MKElement *)el drawForWidget:widget];
}
@end
