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

#import <Cocoa/Cocoa.h>
#import "MKHierarchicalElement.h"
@class MKWidget;

@interface MKElement : NSObject <MKHierarchicalElement> {
@protected
    int stroke;
	int fill;
	NSRect frame;
	NSBezierPath *path;
    BOOL debug;
    
    uint seed;
    
    BOOL visible;
    
    id <MKHierarchicalElement> superelement;
    NSMutableArray *subelements;
    
    NSUInteger autoresizingMask;
    
    NSRect frameBase;
    BOOL atMinSize;
    
    MKWidget *root;
}

@property BOOL visible;
@property int stroke;
@property int fill;
@property NSRect frame;
@property (copy) NSBezierPath *path;
@property BOOL debug;
@property id <MKHierarchicalElement> superelement;
@property (copy) NSMutableArray *subelements;
@property NSUInteger autoresizingMask;
@property NSRect frameBase;
@property (assign) MKWidget *root;

- (id)initWithFrame:(NSRect)aRect;
- (id)initWithFrame:(NSRect)aRect 
         withStroke:(int)aStroke 
           withFill:(int)aFill;

- (NSBezierPath *)defaultPath;

/* element hierarchy */

- (void)addSubelement:(id <MKHierarchicalElement>)element;

/* geometry */

- (void)resizeSubelementsWithOldSize:(NSSize)oldSize;
- (void)resizeWithOldSuperelementSize:(NSSize)oldSize;

/* autoresizing */

- (MKElement *)pinLeft;
- (MKElement *)unpinLeft;
- (MKElement *)pinRight;
- (MKElement *)unpinRight;
- (MKElement *)pinTop;
- (MKElement *)unpinTop;
- (MKElement *)pinBottom;
- (MKElement *)unpinBottom;
- (MKElement *)fixWidth;
- (MKElement *)flexWidth;
- (MKElement *)fixHeight;
- (MKElement *)flexHeight;
- (MKElement *)pin:(NSString *)edge, ...;
- (MKElement *)unpin:(NSString *)edge, ...;
- (MKElement *)fix:(NSString *)dimension, ...;
- (MKElement *)flex:(NSString *)dimension, ...;
- (MKElement *)pin;
- (MKElement *)fix;
- (MKElement *)flex;

@end

// quartz specific code

@interface MKElement (MKElementQuartzDrawing)

- (void)drawForWidget:(MKWidget *)widget;
- (NSBezierPath *)sketchedFitPathForWidget:(MKWidget *)widget;
+ (void)sketchToBezierPath:(NSBezierPath *)path 
                 fromPoint:(NSPoint)orig
                   toPoint:(NSPoint)dest
                  withSeed:(uint)seed;

@end
