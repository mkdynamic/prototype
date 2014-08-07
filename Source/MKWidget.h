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
@class MKWidgetElement;
@class MKElement;

extern const float MKWidgetMinUngroupedWidth;
extern const float MKWidgetMinUngroupedHeight;
extern const float MKWidgetHandleSize;

typedef enum _MKStokeStyle {
    MKStrokeStyleNone = 1,
    MKStrokeStyleDashed = 2,
    MKStrokeStyleSolid = 3
} MKStrokeStyle;

typedef enum _MKStrokeCornerStyle {
    MKStrokeCornerStyleSquare = 1,
    MKStrokeCornerStyleRounded = 2
} MKStrokeCornerStyle;

@interface MKWidget : NSObject <NSCopying, NSCoding, MKHierarchicalElement> {
@protected
    NSRect frameBase;
	float strokeWidth;
    BOOL _enabled;
    BOOL _focused;
	int _dragState;
	NSPoint _anchor;
	NSSize minNaturalSize;
	NSSize maxNaturalSize;
    MKWidgetElement *widgetElement;
    float fixedWidth;
    float fixedHeight;
    BOOL lockAspectRatio;
    NSString *debug;
    NSMutableArray *subelements;
    
    //
    // user properties (i.e. should save them)
    //
    
    // frame
    NSRect frame;
    
    // text
    NSString *text;
    
    // fill
	NSColor *fillColor;
    BOOL sidebar;
    
    // stroke
    NSColor *strokeColor;
    MKStrokeStyle strokeStyle; // none = 1, dotted = 2, solid = 3
    MKStrokeCornerStyle strokeCornerStyle; // square = 1, rounded = 2
    
    // font
    float fontSize;
    NSUInteger fontStyleMask; // italic = 1 (NSItalicFontMask), bold = 2 (NSBoldFontMask)
    NSTextAlignment textAlignment; 
    
    // opacity
    float opacity;
    
    // custom properties
    NSMutableDictionary *properties;
    
    float scaleXFactor;
    float scaleYFactor;
    NSPoint scaleFactorOrigin;
}

//

@property NSRect frame;
@property (copy) NSString *text;
@property (copy) NSColor *fillColor;
@property (copy) NSColor *strokeColor;
@property MKStrokeStyle strokeStyle;
@property MKStrokeCornerStyle strokeCornerStyle;
@property float fontSize;
@property NSUInteger fontStyleMask;
@property NSTextAlignment textAlignment;
@property float opacity;
@property (copy) NSMutableDictionary *properties;
@property BOOL enabled;
@property BOOL focused;

@property BOOL sidebar;
@property (copy) NSMutableArray *subelements;
@property (copy) NSString *debug;
@property NSRect frameBase;
@property float strokeWidth;
@property NSSize minNaturalSize;
@property NSSize maxNaturalSize;
@property (assign) MKWidgetElement *widgetElement;
@property float fixedWidth;
@property float fixedHeight;
@property BOOL lockAspectRatio;
@property (assign) MKWidget *root;
@property float scaleXFactor;
@property float scaleYFactor;
@property NSPoint scaleFactorOrigin;


/* element hierarchy */

- (void)addSubelement:(id <MKHierarchicalElement>)element;

/* geometry */

- (void)resizeSubelementsWithOldSize:(NSSize)oldSize;

/* geometry */

- (BOOL)isFixedWidth;
- (BOOL)isFixedHeight;
- (BOOL)resizable;
- (NSSize)minSize;
- (NSSize)maxSize;
- (NSRect)drawFrame;
- (void)setLocation:(NSPoint)loc;
- (void)setSize:(NSSize)size;
- (BOOL)containsPoint:(NSPoint)pt;
- (NSRect)newFrameFromFrame:(NSRect)old 
                  forHandle:(int)whichOne 
                  withPoint:(NSPoint)p 
       withFixedAspectRatio:(BOOL)fixedAspectRatio 
            withAspectRatio:(float)aspectRatio;
- (NSSize)defaultSize;
- (NSSize)constrainedSize:(NSSize)size;
- (NSRect)constrainedFrame:(NSRect)aFrame;
- (void)moveByDeltaX:(float)deltaX 
              deltaY:(float)deltaY;
+ (NSRect)widgetsFrame:(NSArray *)widgets;

/* selection */

- (void)drawHandlesForHover:(BOOL)hover;
- (void)drawAHandle:(int)whichOne 
           forHover:(BOOL)hover;
- (int)handleAtPoint:(NSPoint)pt;
- (NSRect)handleRect:(int)whichOne;

/* misc */

- (BOOL)isGrouped;

/* NSCoding */

- (void)encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)coder;

/* undo machinary */

- (NSDictionary *)keyPathsToObserveForUndo;

/* text */

- (BOOL)hasEditableText;
- (BOOL)useSingleLineEditableTextMode;
- (BOOL)editOnAdd;

/* effective opacity */

- (float)effectiveOpacity;

/* kinds */

+ (void)registerKind:(Class)kind;
+ (NSArray *)kinds;
+ (NSString *)filters;
+ (NSString *)keywords;

@end

// quartz specific stuff

@interface MKWidget (MKWidgetQuartzDrawing)

- (void)drawRect:(NSRect)rect withSelection:(BOOL)selected;
- (NSImage *)asImage;

@end

