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

#import "MKImageWidget.h"
#import "MKImageElement.h"

@implementation MKImageWidget
@synthesize imagePath, sketch, imgEl;

- (id)init
{
    self = [super init];
    
	if (self) {
        [self.properties setObject:[NSNumber numberWithBool:YES] 
                            forKey:@"sketch"];
        
        [self addObserver:self 
               forKeyPath:@"properties.sketch" 
                  options:(NSKeyValueObservingOptionNew) 
                  context:nil];
        
        NSRect r = NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height);
        
        // img
        imgEl = [[MKImageElement alloc] initWithFrame:r withStroke:1 withFill:0];
        [self addObserver:self 
               forKeyPath:@"imgEl.srcImage" 
                  options:NSKeyValueObservingOptionNew 
                  context:nil];
        
        // cross a
        MKElement *a = [[MKElement alloc] initWithFrame:NSInsetRect(r, 0, 0) withStroke:1 withFill:0];
        NSBezierPath *linePath = [NSBezierPath bezierPath];
        [linePath moveToPoint:NSMakePoint(0, 0)];
        [linePath lineToPoint:NSMakePoint(1, 1)];
        a.path = linePath;
        [[a pin:@"Top", @"Right", @"Bottom", @"Left", nil] flex:@"Width", @"Height", nil];
        [self addSubelement:a];
        
        // cross b
        MKElement *b = [[MKElement alloc] initWithFrame:NSInsetRect(r, 0, 0) withStroke:1 withFill:0];
        NSBezierPath *linePath2 = [NSBezierPath bezierPath];
        [linePath2 moveToPoint:NSMakePoint(1, 0)];
        [linePath2 lineToPoint:NSMakePoint(0, 1)];
        b.path = linePath2;
        [[b pin:@"Top", @"Right", @"Bottom", @"Left", nil] flex:@"Width", @"Height", nil];
        [self addSubelement:b];
        
        // box
        [[imgEl pin:@"Top", @"Right", @"Bottom", @"Left", nil] flex:@"Width", @"Height", nil];
        [self addSubelement:imgEl];
       
        // set sketch to yes by default
        self.sketch = YES;
	}
    
	return self;
}

// TODO use setNeedsDisplay:inRect here by figuring out which objects changed etc.
- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object 
                        change:(NSDictionary *)change 
                       context:(void *)context
{
    if (object == self && [keyPath isEqualToString:@"imgEl.srcImage"]) {
        NSSize elSize;
        int elStroke;
        
        if (self.imgEl.srcImage) {
            elSize = NSSizeFromCGSize([self.imgEl.srcImage extent].size);
            elStroke = 0;
        } else {
            elSize = [self defaultSize];
            elStroke = 1;
        }
        
        [self setSize:elSize];
        for (MKElement *el in subelements)
            el.stroke = elStroke;
        
    } else if (object == self && [keyPath isEqualToString:@"properties.sketch"]) {
        self.sketch = [(NSNumber *)[self.properties valueForKey:@"sketch"] boolValue];
        
    } else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object 
                               change:change 
                              context:context];
    }
}

- (void)setSketch:(BOOL)aSketch
{
    sketch = aSketch;
    self.imgEl.sketch = aSketch;
}

- (void)setImagePath:(NSURL *)anImagePath
{
    imagePath = anImagePath;
    self.imgEl.url = imagePath;
}

/* undo machinary */

- (NSDictionary *)keyPathsToObserveForUndo
{
    NSMutableDictionary *dict = [[super keyPathsToObserveForUndo] mutableCopy];
    [dict setValue:@"Sketch" forKey:@"properties.sketch"];
    return [NSDictionary dictionaryWithDictionary:dict];
}

/* NSCoding */

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
	[coder encodeObject:imgEl.srcImage forKey:@"imgEl.srcImage"];
}

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
    NSRect origFrame = [self frame];
    imgEl.srcImage = [coder decodeObjectForKey:@"imgEl.srcImage"];
    self.frame = origFrame; // since imgEl.srcImage= resets frame to original
	return self;
}

/* NSCopying */

- (id)copyWithZone:(NSZone *)zone
{
    MKImageWidget *copy = [super copyWithZone:zone];
    copy.imgEl.srcImage = self.imgEl.srcImage;
    copy.frame = self.frame; // since imgEl.srcImage= resets frame to original
    return (id)copy;
}

+ (void)load
{
    [self registerKind:self];
}
@end
