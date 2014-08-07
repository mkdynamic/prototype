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

#import <Quartz/Quartz.h>
#import "MKImageElement.h"
#import "MKWidget.h"

@interface MKImageElement ()
- (void)regenerateImageFromSource;
- (CIImage *)sketchedImage:(CIImage *)img;
- (void)drawCIImage:(CIImage *)source
        intoNSImage:(NSImage *)target;
@end

@implementation MKImageElement
@synthesize url, sketch, srcImage;

- (id)init
{
    self = [super init];
    
	if (self) {
        self.sketch = YES;
	}
    
	return self;
}

- (void)setSketch:(BOOL)aSketch
{
    sketch = aSketch;
    [self regenerateImageFromSource];
}

- (void)setSrcImage:(CIImage *)anImage
{
    srcImage = anImage;
    [self regenerateImageFromSource];
}

- (void)setUrl:(NSURL *)aUrl
{
    url = aUrl;
    self.srcImage = [CIImage imageWithContentsOfURL:url];
}

- (void)drawForWidget:(MKWidget *)widget
{
    if (!self.visible)
        return;
    
    [image drawInRect:[self.path bounds]
             fromRect:NSZeroRect 
            operation:NSCompositeSourceOver 
             fraction:widget.opacity];
    
    [super drawForWidget:widget];
    
    for (id <MKHierarchicalElement> el in self.subelements)
        [(MKElement *)el drawForWidget:widget];
}

- (void)regenerateImageFromSource
{
    if (self.srcImage == nil)
        return;
    
    NSSize size = NSSizeFromCGSize([self.srcImage extent].size);
    image = [[NSImage alloc] initWithSize:size];
    [image setFlipped:YES];
    
    [self drawCIImage:self.sketch ? [self sketchedImage:self.srcImage] : self.srcImage 
          intoNSImage:image];
}

- (CIImage *)sketchedImage:(CIImage *)img
{
    // --- path 1 (monochrome inverted edges)
    CIImage *source = img;
    CIFilter *filter;
    CIImage *outputImage1;
    
    // edges
    filter = [CIFilter filterWithName:@"CIEdges"];
    [filter setDefaults];
    [filter setValue:source forKey:@"inputImage"];
    [filter setValue:[NSNumber numberWithFloat:2.0] forKey:@"inputIntensity"];
    outputImage1 = [filter valueForKey:@"outputImage"];
    
    // monochrome
    filter = [CIFilter filterWithName:@"CIColorMonochrome"];
    [filter setDefaults];
    [filter setValue:outputImage1 forKey:@"inputImage"];
    [filter setValue:[CIColor colorWithRed:0.5 green:0.5 blue:0.5] forKey:@"inputColor"];
    [filter setValue:[NSNumber numberWithFloat:1.0] forKey:@"inputIntensity"];
    outputImage1 = [filter valueForKey:@"outputImage"];
    
    // invert
    filter = [CIFilter filterWithName:@"CIColorInvert"];
    [filter setDefaults];
    [filter setValue:outputImage1 forKey:@"inputImage"];
    outputImage1 = [filter valueForKey:@"outputImage"];
    
    // --- path 2 (sketchy noise)
    CIImage *outputImage2;
    
    // tile
    NSURL *noiseURL = [[NSBundle mainBundle] URLForResource:@"o" withExtension:@"png"];
    CIImage *noise = [CIImage imageWithContentsOfURL:noiseURL];
    filter = [CIFilter filterWithName:@"CIAffineTile"];
    [filter setDefaults];
    [filter setValue:noise forKey:@"inputImage"];
    outputImage2 = [filter valueForKey:@"outputImage"];
    
    // motion blur
    filter = [CIFilter filterWithName:@"CIMotionBlur"];
    [filter setDefaults];
    [filter setValue:outputImage2 forKey:@"inputImage"];
    [filter setValue:[NSNumber numberWithFloat:10.0] forKey:@"inputRadius"];
    [filter setValue:[NSNumber numberWithFloat:M_PI / 4] forKey:@"inputAngle"];
    outputImage2 = [filter valueForKey:@"outputImage"];
    
    // addition with input        
    filter = [CIFilter filterWithName:@"CIAdditionCompositing"];
    [filter setDefaults];
    [filter setValue:source forKey:@"inputImage"];
    [filter setValue:outputImage2 forKey:@"inputBackgroundImage"];
    outputImage2 = [filter valueForKey:@"outputImage"];
    
    // color controls
    filter = [CIFilter filterWithName:@"CIColorControls"];
    [filter setDefaults];
    [filter setValue:outputImage2 forKey:@"inputImage"];
    [filter setValue:[NSNumber numberWithFloat:0.0] forKey:@"inputSaturation"];
    [filter setValue:[NSNumber numberWithFloat:-0.35] forKey:@"inputBrightness"];
    [filter setValue:[NSNumber numberWithFloat:1.25] forKey:@"inputContrast"];
    outputImage2 = [filter valueForKey:@"outputImage"];
    
    // --- composite 1 + 2
    filter = [CIFilter filterWithName:@"CIMinimumCompositing"];
    [filter setDefaults];
    [filter setValue:outputImage1 forKey:@"inputImage"];
    [filter setValue:outputImage2 forKey:@"inputBackgroundImage"];
    outputImage2 = [filter valueForKey:@"outputImage"];
    
    // --- done
    return outputImage2;
}

- (void)drawCIImage:(CIImage *)source 
        intoNSImage:(NSImage *)target 
{
    NSSize size = NSSizeFromCGSize([source extent].size);
    
    [image lockFocus];
    [source drawAtPoint:NSZeroPoint
               fromRect:NSMakeRect(0, 0, size.width, size.height)
              operation:NSCompositeCopy 
               fraction:1.0];
    [image unlockFocus];
}
@end
