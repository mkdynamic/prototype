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

#import "MKIPhoneWidget.h"
#import "MKElement.h"
#import "MKRoundedRectElement.h"
#import "MKImageElement.h"

NSRect NSOriginRect(NSRect rect) {
    NSRect r;
    r.origin = NSZeroPoint;
    r.size = rect.size;
    return r;
}

@implementation MKIPhoneWidget
// TODO use setNeedsDisplay:inRect here by figuring out which objects changed etc.
- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object 
                        change:(NSDictionary *)change 
                       context:(void *)context
{
	barEl.visible = [(NSNumber *)[self.properties valueForKey:@"showBar"] boolValue];
}

- (id)init
{
    self = [super init];
    
	if (self) {
        [self.properties setObject:[NSNumber numberWithBool:YES] forKey:@"showBar"];
        
        [self addObserver:self 
               forKeyPath:@"properties.showBar" 
                  options:(NSKeyValueObservingOptionNew) 
                  context:nil];
        
		//self.minNaturalSize = NSMakeSize(233, 450);
        //self.maxNaturalSize = NSMakeSize(233, 450);
        self.lockAspectRatio = YES;
		self.text = @"Prototype";
        
        // case
        NSRect caseRect = NSOriginRect(self.frame);
        MKRoundedRectElement *caseEl = [[MKRoundedRectElement alloc] initWithFrame:caseRect
                                                                        withStroke:0
                                                                          withFill:4];
        [[caseEl pin:@"Top", @"Right", @"Bottom", @"Left", nil] flex:@"Width", @"Height", nil];
        caseEl.radius = 35.f;
        [self addSubelement:caseEl];
        
        // screen
        NSRect screenRect = NSMakeRect(10, 75, caseRect.size.width - 20, caseRect.size.height - 150);
        MKElement *screenEl = [[MKElement alloc] initWithFrame:screenRect
                                                    withStroke:0 
                                                      withFill:2];
        [screenEl flex:@"Width", @"Height", nil];
        [caseEl addSubelement:screenEl];
        
        // bar
        NSRect barRect = NSMakeRect(0, 0, screenRect.size.width, 16);
        barEl = [[MKElement alloc] initWithFrame:barRect
                                      withStroke:0 
                                        withFill:3];
        [[barEl pin:@"Top", @"Left", @"Right",nil] flex:@"Width", @"Height", nil];
        [screenEl addSubelement:barEl];
	}
    
	return self;
}

- (NSSize)defaultSize
{
	return NSMakeSize(312, 607);
}

/* undo machinary */

- (NSDictionary *)keyPathsToObserveForUndo
{
    NSMutableDictionary *dict = [[super keyPathsToObserveForUndo] mutableCopy];
    
    [dict setValue:@"Show/Hide Bar" forKey:@"properties.showBar"];
    
    return [NSDictionary dictionaryWithDictionary:dict];
}

+ (void)load
{
    [self registerKind:self];
}

+ (NSString *)filters
{
    return @"ios";
}
@end
