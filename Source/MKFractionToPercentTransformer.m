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

#import "MKFractionToPercentTransformer.h"

@implementation MKFractionToPercentTransformer

+ (Class)transformedValueClass {
    return [NSNumber class];
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

- (id)transformedValue:(id)value {
    float scaleInputValue;
    float zoomOutputValue;
    
    if (value == nil) return nil;
    
    if ([value respondsToSelector:@selector(floatValue)]) {
        scaleInputValue = [value floatValue];
    } else {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Value (%@) does not respond to -floatValue.", [value class]];
    }
    
    zoomOutputValue = scaleInputValue * 100;
    
    return [NSNumber numberWithFloat:zoomOutputValue];
}

- (id)reverseTransformedValue:(id)value {
    float zoomInputValue;
    float scaleOutputValue;
    
    if (value == nil) return nil;
    
    if ([value respondsToSelector:@selector(floatValue)]) {
        zoomInputValue = [value floatValue];
    } else {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Value (%@) does not respond to -floatValue.", [value class]];
    }
    
    scaleOutputValue = zoomInputValue / 100;
    
    return [NSNumber numberWithFloat:scaleOutputValue];
}

@end
