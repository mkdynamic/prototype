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

#import "MKPropertiesView.h"
#import "MKPropertyView.h"

NSColor *MKLabelTextColor = nil;
NSColor *MKLabelTextColorDisabled = nil;
NSShadow *MKLabelTextShadow = nil;
float MKLabelFontSize = 10.0f;
NSString *MKLabelFontFamily = @"Lucida Grande";

@interface MKPropertiesView ()
- (void)layoutSubviews;
@end

@implementation MKPropertiesView
@synthesize strokeColorWell, fillColorWell;

+ (void)initialize
{
    if (!MKLabelTextColor) {
        MKLabelTextColor = [NSColor colorWithDeviceHue:0 
                                            saturation:0 
                                            brightness:0.25 
                                                 alpha:1];
    }
    
    if (!MKLabelTextColorDisabled) {
        MKLabelTextColorDisabled = [NSColor colorWithDeviceHue:0 
                                                    saturation:0 
                                                    brightness:0.75 
                                                         alpha:1];
    }
    
    if (!MKLabelTextShadow) {
        MKLabelTextShadow = [[NSShadow alloc] init];
        [MKLabelTextShadow setShadowOffset:NSMakeSize(0,-1)];
        [MKLabelTextShadow setShadowColor:[NSColor colorWithDeviceWhite:1 alpha:.75]];
        [MKLabelTextShadow setShadowBlurRadius:0];
    }
}

- (BOOL)isFlipped
{
	return YES;
}

- (void)addSubview:(NSView *)aView
{
    [super addSubview:aView];
    
    }

- (void)awakeFromNib
{
    for (NSView *aView in [self subviews]) {
        if ([aView isKindOfClass:[MKPropertyView class]]) {
            [aView setHidden:!((MKPropertyView *)aView).alwaysShow];
        }

    }
    
  //  [strokeColorWell bind:@"color" toObject:<#(id)#> withKeyPath:<#(NSString *)#> options://<#(NSDictionary *)#>
}
- (void)showPropertiesForWidgetKinds:(NSSet *)kinds
{
    NSSet *supportedClasses;
    int visibleOptions = 0;
    
    for (NSView *view in [self subviews]) {
        if ([view isKindOfClass:[MKPropertyView class]]) {
            supportedClasses = [NSSet setWithArray:[((MKPropertyView *)view).widgets componentsSeparatedByString:@","]];
            
            if ([kinds count] > 0 && ([supportedClasses containsObject:@"*"] || [kinds isSubsetOfSet:supportedClasses])) {
                [view setHidden:NO];
                visibleOptions++;
            } else {
                if (!((MKPropertyView *)view).alwaysShow) {
                    [view setHidden:YES];
                }
            }
        }
    }
    
    [self layoutSubviews];
}

- (void)layoutSubviews
{
    NSPoint p = NSZeroPoint;
    
    for (NSView *subview in [[self subviews] reverseObjectEnumerator]) {
        if (![subview isHidden]) {
            [subview setFrameOrigin:p];
            p.y += [subview frame].size.height;
        }
    }
    
    NSSize size = [self frame].size;
    size.height = p.y;
    [self setFrameSize:size];
}


@end
