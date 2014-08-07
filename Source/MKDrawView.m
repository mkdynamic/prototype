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

#import "MKDrawView.h"
#import "MKOvalWidget.h"
#import "MKBrowserWindowWidget.h"
#import "MKDocument.h"
#import "MKToolsController.h"
#import "MKElement.h"
#import "MKAppController.h"
#import "MKWidgetToolView.h"
#import "LTPixelAlign.h"

NSRect NSRectFromTwoPoints(NSPoint a, NSPoint b)
{
	NSRect r;
	
	r.origin.x = fminf(a.x, b.x);
	r.origin.y = fminf(a.y, b.y);
	
	r.size.width = fabsf(a.x - b.x);
	r.size.height = fabsf(a.y - b.y);
	
	return r;
}

typedef enum uint
{
    MKSnappableObjectEdgeCoordinate = 0,
    MKSnappableObjectAdjacentCoordinate = 1,
    MKSnappableGridCoordinate = 2,
    MKSnappableOriginalCoordinate = 3
} MKSnappableCoordinateType;

static const float MKSnappableCoordinateTolerances[4] = {
    3,
    3,
    3,
    0.0 // meaningless
};

typedef struct
{
    CGFloat coordinate;
    MKSnappableCoordinateType type;
    BOOL mid;
    float delta;
} MKSnappableCoordinate;

MKSnappableCoordinate MKMakeSnappableCoordinate(CGFloat coordinate, MKSnappableCoordinateType type, BOOL mid)
{
    MKSnappableCoordinate sc;
    sc.coordinate = coordinate;
    sc.type = type;
    sc.mid = mid;
    sc.delta = 0;
    return sc;
}

float getSnappingTolerance(MKSnappableCoordinateType type, BOOL snapToGrid, BOOL snapToSmartGuides)
{
    float tolerance;
    
    switch (type) {
        case MKSnappableGridCoordinate:
            tolerance = snapToGrid ? MKSnappableCoordinateTolerances[type] : 0;
            break;
        case MKSnappableObjectEdgeCoordinate:
        case MKSnappableObjectAdjacentCoordinate:
            tolerance = snapToSmartGuides ? MKSnappableCoordinateTolerances[type] : 0;
            break;
        default:
            tolerance = MKSnappableCoordinateTolerances[type];
            break;
    }
    
    return tolerance;
}

static const float printPadding = 10.0;

@interface MKDrawView ()

@property NSPoint dragStartPoint;
@property NSPoint mouseDownPoint;
@property NSPoint marqueeStartPoint;
@property NSInteger dragState;

/* mouse */

- (NSInteger)indexOfTopMostUnselectedWidgetOutsideSelectionAtPoint:(NSPoint)aPoint;
- (void)updateMarquee:(NSPoint)newPoint;

/* snapping */

- (void)addObjectSmartXStops:(NSMutableArray *)xStops 
                   andYStops:(NSMutableArray *)yStops;
- (void)addGridSmartXStops:(NSMutableArray *)xStops 
                 andYStops:(NSMutableArray *)yStops;
- (NSArray *)snappedCoordinatesFor:(float)orig 
                         withSnaps:(NSArray *)snaps 
                         andOffset:(float)offset 
                  bySnappingToGrid:(BOOL)snapToGrid 
          andSnappingToSmartGuides:(BOOL)snapToSmartGuides 
                             asMid:(BOOL)mid;
- (NSArray *)incidentalCoordinates:(NSArray *)snappedCoordinates
                    withTargetDiff:(float)diff;
- (MKSnappableCoordinate)closestSnappedCoordinate:(NSArray *)snappedCoordinates;

/* draw subroutines */

- (void)drawBackground:(NSRect)dirtyRect;
- (void)drawWidgets:(NSRect)dirtyRect;
- (void)drawHandles:(NSRect)dirtyRect;
- (void)drawGrid:(NSRect)dirtyRect;
- (void)drawSmartGuides:(NSRect)dirtyRect;
- (void)drawMarquee:(NSRect)dirtyRect;

/* printing */

- (float)scaleFactorForPrinting;
- (NSRect)unscaledRectForPrinting;

@end

@implementation MKDrawView

@dynamic dataSource;

@synthesize dragStartPoint, mouseDownPoint, marqueeStartPoint, 
            dragState, isFixedResizeAspectRatio, preventHoverHandles;

- (id)initWithFrame:(NSRect)frameRect 
{
    self = [super initWithFrame:frameRect];
	if (self) {
        self.outputMode = 0;
		self.dragState = 0;
        self.isFixedResizeAspectRatio = NO;
        editingWidget = NO;
        hoverWidget = nil;
        selectedWidgetsAtMarqueeStart = [NSArray array];
        deferredSetSelection = nil;
        deferredAddSelection = nil;
        deferredRemoveSelection = nil;
        didMouseDragWidgets = NO;
        gridSize = 20;
        snapLinesX = [NSArray array];
        snapLinesY = [NSArray array];
        self.preventHoverHandles = NO;
        
        [self addTrackingArea:
        [[NSTrackingArea alloc] initWithRect:[self frame]
                                     options:(NSTrackingMouseMoved | 
                                              NSTrackingActiveInKeyWindow |
                                              NSTrackingMouseEnteredAndExited | 
                                              NSTrackingInVisibleRect)
                                       owner:self
                                    userInfo:nil]];
        
        [self registerForDraggedTypes:[NSArray arrayWithObject:@"widget"]];
	}
	return self;
}

- (BOOL)isFlipped
{
	return YES;
}

- (BOOL)isOpaque
{
	return YES;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

- (BOOL)acceptsFirstResponder
{
    // allows us to tab here (from search etc.)
    return YES;
}

/* dragging */

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    MKWidgetToolView *s = (MKWidgetToolView *)[sender draggingSource];
    
    // add the widget
    MKWidget *widget = [(MKWidget *)[NSClassFromString(s.kind) alloc] init];
    NSPoint pt = [self convertPoint:[sender draggingLocation] fromView:nil];
    pt.x -= widget.frame.size.width / 2;
    pt.y -= widget.frame.size.height / 2;
    pt.x = roundf(pt.x);
    pt.y = roundf(pt.y);
    [widget setLocation:pt];
    [[self dataSource] addObject:widget];
    
    // focus draw view (helps with delete)
    [[self window] makeFirstResponder:self];
    
    // edit immediately
    if ([widget editOnAdd]) {
        // TODO minor: should fade the drag image out immediately in this case
        textEditingWidget = widget;
        editingWidget = YES;
        [self textEditingStart];
    }
    
    // YAY!
    return YES;
}

- (void)awakeFromNib
{
    // this helps track selection properly when cursor goes over other windows
    [[self window] setAcceptsMouseMovedEvents:YES];
    
    // listen to user settings we care about
    NSUserDefaultsController *userDefaultsController = [NSUserDefaultsController sharedUserDefaultsController];
    [userDefaultsController addObserver:self forKeyPath:@"values.showGrid" options:NSKeyValueObservingOptionNew context:NULL];
    [userDefaultsController addObserver:self forKeyPath:@"values.snapToGrid" options:NSKeyValueObservingOptionNew context:NULL];
    [userDefaultsController addObserver:self forKeyPath:@"values.showSmartGuides" options:NSKeyValueObservingOptionNew context:NULL];
    [userDefaultsController addObserver:self forKeyPath:@"values.snapToSmartGuides" options:NSKeyValueObservingOptionNew context:NULL];
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    return NSDragOperationCopy;
}

/* printing */

- (BOOL)knowsPageRange:(NSRangePointer)range
{
    range->location = 1;
    range->length = 1;
    return YES;
}

- (NSRect)rectForPage:(NSInteger)page
{
    NSRect unscaledRect = [self unscaledRectForPrinting];
    float scaleFactor = [self scaleFactorForPrinting];
    return NSMakeRect(0, 0, unscaledRect.size.width * scaleFactor, unscaledRect.size.height * scaleFactor);
}

- (NSPoint)locationOfPrintRect:(NSRect)printRect
{
    NSPrintOperation *op = [NSPrintOperation currentOperation];
    NSPrintInfo *printInfo = [op printInfo];
    
    NSSize paperSize = [printInfo paperSize];
    
    NSSize printableAreaSize = paperSize;
    printableAreaSize.width -= [printInfo leftMargin] + [printInfo rightMargin];
    printableAreaSize.height -= [printInfo topMargin] + [printInfo bottomMargin];
    
    NSPoint location = NSMakePoint([printInfo leftMargin], [printInfo bottomMargin]);
    
    if ([printInfo isHorizontallyCentered]) {
        location.x += (printableAreaSize.width - printRect.size.width) / 2;
    }
    
    if ([printInfo isVerticallyCentered]) {
        location.y += (printableAreaSize.height - printRect.size.height) / 2;
    }
    
    return location;
}

- (float)scaleFactorForPrinting
{
    NSPrintOperation *op = [NSPrintOperation currentOperation];
    NSPrintInfo *printInfo = [op printInfo];
    
    NSSize printSize = [printInfo paperSize];
    printSize.width -= [printInfo leftMargin] + [printInfo rightMargin];
    printSize.height -= [printInfo topMargin] + [printInfo bottomMargin];
    
    NSRect unscaledRect = [self unscaledRectForPrinting];
    
    float scaleFactor;
    float sourceAspectRatio = unscaledRect.size.width / unscaledRect.size.height;
    float targetAspectRatio = printSize.width / printSize.height;
    if (sourceAspectRatio > targetAspectRatio) {
        scaleFactor = printSize.width / unscaledRect.size.width;
    } else {
        scaleFactor = printSize.height / unscaledRect.size.height;
    }
    
    return scaleFactor;
}

- (NSRect)unscaledRectForPrinting
{
    NSPrintOperation *op = [NSPrintOperation currentOperation];
    NSPrintInfo *printInfo = [op printInfo];
    NSRect widgetsRect;
    
    if ([printInfo isSelectionOnly]) {
        widgetsRect = [MKWidget widgetsFrame:self.dataSource.selectedObjects];
    } else {
        widgetsRect = [MKWidget widgetsFrame:self.dataSource.arrangedObjects];
    }
    
    return NSInsetRect(widgetsRect, -printPadding, -printPadding);
}

/* export */

- (NSData *)pdfData
{
    NSRect bounds = NSInsetRect([MKWidget widgetsFrame:self.dataSource.arrangedObjects], -printPadding, -printPadding);
    NSData *data = [self dataWithPDFInsideRect:bounds];
    return data;
}

- (NSData *)imageData:(CFStringRef)type
{
    NSRect bounds = NSInsetRect([MKWidget widgetsFrame:self.dataSource.arrangedObjects], -printPadding, -printPadding);
    NSData *data = [self dataWithPDFInsideRect:bounds];
    NSPDFImageRep *pdfImageRep = [NSPDFImageRep imageRepWithData:data];
    [pdfImageRep setCurrentPage:0];
    NSImage *imageRep = [[NSImage alloc] init];
    [imageRep addRepresentation:pdfImageRep];
    NSBitmapImageRep *bitmapImageRep = [NSBitmapImageRep imageRepWithData:[imageRep TIFFRepresentation]];
    NSData *imgData;
    
    if (type == kUTTypePNG) {
        imgData = [bitmapImageRep representationUsingType:NSPNGFileType
                                               properties:nil];
    } else if (type == kUTTypeTIFF) {
        imgData = [bitmapImageRep representationUsingType:NSTIFFFileType
                                               properties:nil];
    } else if (type == kUTTypeJPEG) {
        imgData = [bitmapImageRep representationUsingType:NSJPEGFileType
                                               properties:@{NSImageCompressionFactor: @(0.75)}];
    } else if (type == kUTTypeGIF) {
        imgData = [bitmapImageRep representationUsingType:NSGIFFileType
                                               properties:nil];
    }
    
    return imgData;
}

/* drawing */

- (void)drawRect:(NSRect)dirtyRect
{
    [NSGraphicsContext saveGraphicsState];
    
    
    switch (self.outputMode) {
        case 0: { // screen
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            
            [self drawBackground:dirtyRect];
            [self drawWidgets:dirtyRect];
            [self drawHandles:dirtyRect];
            if ([userDefaults boolForKey:@"showGrid"]) [self drawGrid:dirtyRect];
            if ([userDefaults boolForKey:@"showSmartGuides"]) [self drawSmartGuides:dirtyRect];
            [self drawMarquee:dirtyRect];
            
            break;
        }
            
        case 1: { // print
            NSRect unscaledRect = [self unscaledRectForPrinting];
            float scaleFactor = [self scaleFactorForPrinting];
            
            NSAffineTransform *transform = [NSAffineTransform transform];
            [transform translateXBy:-unscaledRect.origin.x * scaleFactor yBy:-unscaledRect.origin.y * scaleFactor];
            [transform scaleBy:scaleFactor];
            [transform concat];
            
            [self drawWidgets:NSMakeRect(0, 0, 99999, 99999)];
            
            //[transform invert];
            //[transform concat];
            
            break;
        }
            
        case 2: { // file (pdf)
            [self drawWidgets:NSMakeRect(0, 0, 99999, 99999)];
            
            break;
        }
            
        default:
            break;
    }
    
    [NSGraphicsContext restoreGraphicsState];
}

- (void)drawHandles:(NSRect)dirtyRect
{
    NSArray *drawList = [[self dataSource] arrangedObjects];
	NSArray *selection = [[self dataSource] selectedObjects];
	MKWidget *widget;
    
    if (!didMouseDragWidgets) {
        // draw handles last always, so they go on top
        for (widget in drawList) {
            if (NSIntersectsRect(dirtyRect, [widget drawFrame])) {
                if ([selection containsObject:widget]) {
                    [widget drawHandlesForHover:NO];
                }
            }
        }
        
        // hover handles
        if (hoverWidget && [drawList containsObject:hoverWidget]) {
            if (!self.preventHoverHandles && ![selection containsObject:hoverWidget]) {
                if (NSIntersectsRect(dirtyRect, [hoverWidget drawFrame])) {
                    [hoverWidget drawHandlesForHover:YES];
                }
            }
        } else {
            // hover widget was removed
            hoverWidget = nil;
        }
    }
    
}
- (void)drawWidgets:(NSRect)dirtyRect
{
	NSArray *drawList = [[self dataSource] arrangedObjects];
	NSArray *selection = [[self dataSource] selectedObjects];
	MKWidget *widget;
    
	for (widget in drawList) {
		[widget drawRect:dirtyRect 
           withSelection:[selection 
                          containsObject:widget]];
	}
}

- (void)drawBackground:(NSRect)dirtyRect
{
    [[NSColor whiteColor] setFill];
    
    NSRectFill(dirtyRect);
}

- (void)drawSmartGuides:(NSRect)dirtyRect
{
    float sl = [self pixelAlignStroke:1 / self.scale];
    NSBezierPath *sp;
    NSBezierPath *sp2;
    CGFloat spat[2];
    spat[0] = sl * 3;
    spat[1] = sl * 3;
    NSPoint sp0;
    NSSize canvasSize = [self bounds].size;
    MKSnappableCoordinate sc;
    
    for (NSValue *v in snapLinesX) {
        [v getValue:&sc];
        float snapLineX = sc.coordinate;
        
        [[NSColor magentaColor] setStroke];
        
        sp = [NSBezierPath bezierPath];
        
        sp0 = [self pixelAlignPoint:NSMakePoint(snapLineX, 0) withStroke:sl];
        [sp moveToPoint:sp0];
        [sp lineToPoint:[self pixelAlignPoint:NSMakePoint(snapLineX, canvasSize.height) withStroke:sl]];
        
        [sp setLineWidth:sl];
        [sp setLineDash:spat count:2 phase:sp0.x];
        [sp setLineCapStyle:NSButtLineCapStyle];
        
        [sp stroke];
        
        [[NSColor whiteColor] setStroke];
        sp2 = [NSBezierPath bezierPath];
        
        sp0 = [self pixelAlignPoint:NSMakePoint(snapLineX, 0) withStroke:sl];
        [sp2 moveToPoint:sp0];
        [sp2 lineToPoint:[self pixelAlignPoint:NSMakePoint(snapLineX, canvasSize.height) withStroke:sl]];
        
        [sp2 setLineWidth:sl];
        [sp2 setLineDash:spat count:2 phase:sp0.x + spat[0]];
        [sp2 setLineCapStyle:NSButtLineCapStyle];
        
        [sp2 stroke];
    }
    
	for (NSValue *v in snapLinesY) {
        [v getValue:&sc];
        float snapLineY = sc.coordinate;
        
        [[NSColor magentaColor] setStroke];
        sp = [NSBezierPath bezierPath];
        
        sp0 = [self pixelAlignPoint:NSMakePoint(0, snapLineY) withStroke:sl];
        [sp moveToPoint:sp0];
        [sp lineToPoint:[self pixelAlignPoint:NSMakePoint(canvasSize.width, snapLineY) withStroke:sl]];
        
        [sp setLineWidth:sl];
        [sp setLineDash:spat count:2 phase:sp0.y];
        [sp setLineCapStyle:NSButtLineCapStyle];
        
        [sp stroke];
        
        [[NSColor whiteColor] setStroke];
        sp2 = [NSBezierPath bezierPath];
        
        sp0 = [self pixelAlignPoint:NSMakePoint(0, snapLineY) withStroke:sl];
        [sp2 moveToPoint:sp0];
        [sp2 lineToPoint:[self pixelAlignPoint:NSMakePoint(canvasSize.width, snapLineY) withStroke:sl]];
        
        [sp2 setLineWidth:sl];
        [sp2 setLineDash:spat count:2 phase:sp0.y + spat[0]];
        [sp2 setLineCapStyle:NSButtLineCapStyle];
        
        [sp2 stroke];
    }
}

- (void)drawGrid:(NSRect)dirtyRect
{
    float g;
    float gs = gridSize;
    
    // FIXME this is a hacky way to avoid drawing lines too close together (more than 10 pix)
    if (gs * self.scale < 10) {
        gs *= 2;
    }
    
    float gl = [self pixelAlignStroke:1 / self.scale];
    
    NSSize canvasSize = [self bounds].size;
    NSPoint gp0;
    NSPoint gp1;
    NSBezierPath *gbp;
    CGFloat pat[2];
    pat[0] = gl;
    pat[1] = gl;
    
    [[NSColor colorWithDeviceWhite:0.0 alpha:0.15] setStroke];
    
    for (g = gs; g < canvasSize.width; g += gs) {
        gp0 = [self pixelAlignPoint:NSMakePoint(g, 0) withStroke:gl];
        gp1 = [self pixelAlignPoint:NSMakePoint(g, canvasSize.height) withStroke:gl];
        
        gbp = [NSBezierPath bezierPath];
        [gbp moveToPoint:gp0];
        [gbp lineToPoint:gp1];
        [gbp setLineWidth:gl];
        [gbp setLineDash:pat count:2 phase:gp0.y];
        [gbp setLineCapStyle:NSButtLineCapStyle];
        [gbp stroke];
    }
    
    for (g = gs; g < canvasSize.height; g += gs) {
        gp0 = [self pixelAlignPoint:NSMakePoint(0, g) withStroke:gl];
        gp1 = [self pixelAlignPoint:NSMakePoint(canvasSize.width, g) withStroke:gl];
        
        gbp = [NSBezierPath bezierPath];
        [gbp moveToPoint:gp0];
        [gbp lineToPoint:gp1];
        [gbp setLineWidth:gl];
        [gbp setLineDash:pat count:2 phase:gp0.x];
        [gbp setLineCapStyle:NSButtLineCapStyle];
        [gbp stroke];
    }
}

- (void)drawMarquee:(NSRect)dirtyRect
{
    // FIXME: don't check for marquee'ing like this.
	if (self.marqueeStartPoint.x != 0 || self.marqueeStartPoint.y != 0) {
        float stroke = [self pixelAlignStroke:1 / self.scale];
        
        NSRect mr;
        if (self.marqueeStartPoint.y < self.dragStartPoint.y) {
            mr = NSRectFromTwoPoints(self.marqueeStartPoint, self.dragStartPoint);
        } else {
            mr = NSRectFromTwoPoints(self.dragStartPoint, self.marqueeStartPoint);
        }
        mr = [self pixelAlignRect:mr withStroke:stroke];
        
        // FIXME top wobbles, this does not really fix
        float ff = [self pixelAlignPixelizedHalfStroke:stroke];
        ff = [self convertSizeFromBase:NSMakeSize(ff, 0)].width;
        mr.origin.y = floorf(fminf(self.marqueeStartPoint.y, self.dragStartPoint.y)) - ff;
        
        [[NSColor whiteColor] setStroke];
        
        CGFloat pat[2];
        pat[0] = stroke * 5;
        pat[1] = stroke * 5;
        
        NSBezierPath *p= [NSBezierPath bezierPathWithRect:mr];
        [p setLineWidth:stroke];
        [p setLineDash:pat count:2 phase:ff];
        [p setLineCapStyle:NSButtLineCapStyle];
        
        [[NSGraphicsContext currentContext] saveGraphicsState];
        CGContextSetBlendMode( [[NSGraphicsContext currentContext] graphicsPort], kCGBlendModeDifference);
        [p stroke];
        
        [[NSGraphicsContext currentContext] restoreGraphicsState];
    }
}

/* data source */

- (id)dataSource
{
	return dataSource;
}

- (void)setDataSource:(id)anObject
{
    // TODO this can be dynamically done from the widget
    NSArray *keyPaths = [NSArray arrayWithObjects:
                         @"selectedObjects",
                         @"arrangedObjects",
                         @"arrangedObjects.frame",
                         @"arrangedObjects.strokeColor",
                         @"arrangedObjects.fillColor",
                         @"arrangedObjects.text",
                         @"arrangedObjects.fontStyleMask",
                         @"arrangedObjects.textAlignment",
                         @"arrangedObjects.strokeStyle",
                         @"arrangedObjects.fontSize",
                         @"arrangedObjects.imagePath",
                         @"arrangedObjects.opacity",
                         @"arrangedObjects.enabled",
                         @"arrangedObjects.focused",
                         
                         // iphone
                         @"arrangedObjects.properties.showBar",
                         
                         // sketch
                         @"arrangedObjects.properties.sketch",
                         
                         // rectangle,
                         @"arrangedObjects.properties.cornerStyle",
                         
                         // checkbox
                         @"arrangedObjects.properties.state",
                         
                         // slider
                         @"arrangedObjects.properties.value",
                         
                         nil];
    NSString *keyPath;
    
    for (keyPath in keyPaths) {
        [dataSource removeObserver:self 
                        forKeyPath:keyPath];
    }
    
	dataSource = anObject;
    
    for (keyPath in keyPaths) {
        [dataSource addObserver:self 
                     forKeyPath:keyPath
                        options:(NSKeyValueObservingOptionNew) 
                        context:nil];
    }
}

/* kvo */

// TODO use setNeedsDisplay:inRect here by figuring out which objects changed etc.
- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object 
                        change:(NSDictionary *)change 
                       context:(void *)context
{
	[self setNeedsDisplay:YES];
}

/* mouse */

- (NSInteger)indexOfTopMostOrHandleHitWidgetAtPoint:(NSPoint)aPoint
{
	NSArray *arrangedObjects = [self.dataSource arrangedObjects];
    NSArray *selectedObjects = [self.dataSource selectedObjects];
    MKWidget *selectedObject;
	
    // first check that we have not hit a handle for a selected widget, as that will
    // take precidence and cause the associated widget to be returned
    for (NSInteger i = [selectedObjects count] - 1; i >= 0; i--) {
        selectedObject = [selectedObjects objectAtIndex:i];
		if ([selectedObject handleAtPoint:aPoint] > 0) {
			return [arrangedObjects indexOfObject:selectedObject];
		}
	}
    
    // now just check all objects
	for (NSInteger i = [arrangedObjects count] - 1; i >= 0; i--) {
		if ([[arrangedObjects objectAtIndex:i] containsPoint:aPoint]) {
			return i;
		}
	}
	
	return NSNotFound;
}

- (NSInteger)indexOfTopMostUnselectedWidgetOutsideSelectionAtPoint:(NSPoint)aPoint
{
	NSMutableArray *arrangedObjects = [NSMutableArray arrayWithArray:[self.dataSource arrangedObjects]];
    // FIXME works without this, but it seems like having it is better although it breaks hovering
    //[arrangedObjects removeObjectsInArray:[self.dataSource selectedObjects]];
    //NSRect selectedBounds;
    
    //if ([[self.dataSource selectionIndexes] count] > 0) {
    //    selectedBounds = [MKWidget widgetBounds:[self.dataSource selectedObjects]];
    //} else {
    //    selectedBounds = NSZeroRect;
    //}
	
	for (NSInteger i = [arrangedObjects count] - 1; i >= 0; i--) {
		if ([[arrangedObjects objectAtIndex:i] containsPoint:aPoint]) {
			return i;
		}
	}
	
	return NSNotFound;
}

- (void)mouseDown:(NSEvent *)anEvent
{
    if (([anEvent modifierFlags] & NSShiftKeyMask) != 0) {
        self.preventHoverHandles = YES;
    }
    
	NSPoint pt = [self convertPoint:[anEvent locationInWindow] fromView:nil];
    pt.x = roundf(pt.x);
    pt.y = roundf(pt.y);
	NSInteger hitWidgetIndex = [self indexOfTopMostOrHandleHitWidgetAtPoint:pt];
	self.dragStartPoint = self.mouseDownPoint = pt;
    
    // we were editing, and clicked outside editor
	if (editingWidget) {
        [self textEditingFinish:self];
    }
    
    if ([anEvent clickCount] > 1 && ([anEvent modifierFlags] & NSShiftKeyMask) == 0) { // double click, no shift key. editing
        if (hitWidgetIndex == NSNotFound) { // double clicked nothing, clear selection (maybe human error)
            deferredSetSelection = [NSIndexSet indexSet];
        } else {
            textEditingWidget = [[self.dataSource arrangedObjects] objectAtIndex:hitWidgetIndex];
            
            // only trigger text editing for editable widgets
            if ([textEditingWidget hasEditableText]) {
                editingWidget = YES;
                [self textEditingStart];
            } else {
                textEditingWidget = nil;
            }
        }
    } else { // single click, or double click with shift key (in which case, we just treat like a click)
        if (hitWidgetIndex == NSNotFound) {
            if (([anEvent modifierFlags] & NSShiftKeyMask) == 0) { // no shift key, deselect all
                deferredSetSelection = [NSIndexSet indexSet];
            }
            
            // record selected widgets before marquee starts
            selectedWidgetsAtMarqueeStart = [[self.dataSource selectedObjects] copy];
            
            // set marquee start point
            self.marqueeStartPoint = pt;
        } else if ([[self.dataSource selectionIndexes] containsIndex:hitWidgetIndex]) { // already selected
            MKWidget *hitWidget = [[self.dataSource arrangedObjects] objectAtIndex:hitWidgetIndex];
            self.dragState = [hitWidget handleAtPoint:pt];
            
            if (self.dragState > 0) { // we hit a handle (takes presidence over selection)
                fixedResizeAspectRatio = [hitWidget frame].size.width / [hitWidget frame].size.height;
                deferredSetSelection = [NSIndexSet indexSetWithIndex:hitWidgetIndex];
            } else if (([anEvent modifierFlags] & NSShiftKeyMask) != 0) { // shift key, remove widget from selection
                deferredRemoveSelection = [NSIndexSet indexSetWithIndex:hitWidgetIndex];
            }
        } else { // widget is not selected
            if (([anEvent modifierFlags] & NSShiftKeyMask) != 0) { // shift key, add widget to selection
                deferredAddSelection = [NSIndexSet indexSetWithIndex:hitWidgetIndex];
            } else { // set selection to widget
                deferredSetSelection = [NSIndexSet indexSetWithIndex:hitWidgetIndex];
            }
        }
    }
    
    [super mouseDown:anEvent];
}

- (void)addObjectSmartXStops:(NSMutableArray *)xStops
                   andYStops:(NSMutableArray *)yStops
{
    
    MKSnappableCoordinate sc;
    
    // can be calculated eagerly (mouse down, another thread?)
    MKWidget *otherWidget;
    NSIndexSet *selectedIndexes = [self.dataSource selectionIndexes];
    NSRect otherWidgetFrame;
    for (uint index = 0; index < [[self.dataSource arrangedObjects] count]; index++) {
        if ([selectedIndexes containsIndex:index]) continue;
        otherWidget = [[self.dataSource arrangedObjects] objectAtIndex:index];
        otherWidgetFrame = [otherWidget frame];
        
        sc = MKMakeSnappableCoordinate(NSMinX(otherWidgetFrame), MKSnappableObjectEdgeCoordinate, NO);
        [xStops addObject:[NSValue valueWithBytes:&sc objCType:@encode(MKSnappableCoordinate)]];
        sc = MKMakeSnappableCoordinate(NSMidX(otherWidgetFrame), MKSnappableObjectEdgeCoordinate, YES);
        [xStops addObject:[NSValue valueWithBytes:&sc objCType:@encode(MKSnappableCoordinate)]];
        sc = MKMakeSnappableCoordinate(NSMaxX(otherWidgetFrame), MKSnappableObjectEdgeCoordinate, NO);
        [xStops addObject:[NSValue valueWithBytes:&sc objCType:@encode(MKSnappableCoordinate)]];
        
        sc = MKMakeSnappableCoordinate(NSMinY(otherWidgetFrame), MKSnappableObjectEdgeCoordinate, NO);
        [yStops addObject:[NSValue valueWithBytes:&sc objCType:@encode(MKSnappableCoordinate)]];
        sc = MKMakeSnappableCoordinate(NSMidY(otherWidgetFrame), MKSnappableObjectEdgeCoordinate, YES);
        [yStops addObject:[NSValue valueWithBytes:&sc objCType:@encode(MKSnappableCoordinate)]];
        sc = MKMakeSnappableCoordinate(NSMaxY(otherWidgetFrame), MKSnappableObjectEdgeCoordinate, NO);
        [yStops addObject:[NSValue valueWithBytes:&sc objCType:@encode(MKSnappableCoordinate)]];
    }
}

- (void)addGridSmartXStops:(NSMutableArray *)xStops
                 andYStops:(NSMutableArray *)yStops
{
    MKSnappableCoordinate sc;
    NSSize canvasSize = [self bounds].size;
    
    // grid stops
    float g;
    float gs = gridSize;
    for (g = 0; g < canvasSize.width; g += gs) {
        sc = MKMakeSnappableCoordinate(g, MKSnappableGridCoordinate, NO);
        [xStops addObject:[NSValue valueWithBytes:&sc objCType:@encode(MKSnappableCoordinate)]];  
    }
    for (g = 0; g < canvasSize.height; g += gs) {
        sc = MKMakeSnappableCoordinate(g, MKSnappableGridCoordinate, NO);
        [yStops addObject:[NSValue valueWithBytes:&sc objCType:@encode(MKSnappableCoordinate)]];
    }
}

- (NSArray *)snappedCoordinatesFor:(float)orig 
                         withSnaps:(NSArray *)snaps 
                         andOffset:(float)offset 
                  bySnappingToGrid:(BOOL)snapToGrid 
          andSnappingToSmartGuides:(BOOL)snapToSmartGuides 
                             asMid:(BOOL)mid
{
    float diff;
    MKSnappableCoordinate sc;
    NSMutableArray *results = [NSMutableArray array];
    
    // OPTIMIZE can use a tree here to do better than O(n) search for closest coordinates
    //          may not be worth it, this is probably fucking fast, but it does get called
    //          many times (12x, worse case) for *every* mouse move event
    for (NSValue *snap in snaps) {
        [snap getValue:&sc];
        //if (sc.type == MKSnappableGridCoordinate) continue;
        //if (mid != sc.mid) continue;
        
        sc.coordinate = sc.coordinate;
        diff = sc.coordinate - orig;
        
        if (fabs(diff - offset) <= (getSnappingTolerance(sc.type, snapToGrid, snapToSmartGuides) / [self scale])) {
            sc.delta = diff;
            [results addObject:[NSValue valueWithBytes:&sc objCType:@encode(MKSnappableCoordinate)]];
        }
    }
    
    // grid
    // NOTE this works, just need to measure to ensure it's faster
    //    if (result.coordinate != sc.coordinate && !mid) {
    //        float gridSize = 20;
    //        diff = -remainderf(orig, gridSize);
    //        
    //        if (roundf(fabs(diff - offset)) <= getSnappingTolerance(MKSnappableGridCoordinate, snapToGrid, snapToSmartGuides)) {
    //            result.coordinate = gridSize * roundf(orig / gridSize);
    //            result.type = MKSnappableGridCoordinate;
    //            result.mid = NO;
    //        }
    //    }
    
    
    return results;
}

- (NSArray *)incidentalCoordinates:(NSArray *)snappedCoordinates
                    withTargetDiff:(float)diff
{
    NSMutableArray *results = [NSMutableArray array];
    MKSnappableCoordinate sc;
    
    for (NSValue *v in snappedCoordinates) {
        [v getValue:&sc];
        
        if (diff == sc.delta) {
            [results addObject:[NSValue valueWithBytes:&sc 
                                              objCType:@encode(MKSnappableCoordinate)]];
        }
    }
    
    return results;
}

- (MKSnappableCoordinate)closestSnappedCoordinate:(NSArray *)snappedCoordinates
{
    MKSnappableCoordinate closest;
    
    NSComparisonResult (^sortBlock)(id, id) = ^(id a, id b) {
        MKSnappableCoordinate sc;
        
        [(NSValue *)a getValue:&sc];
        float deltaA = sc.delta;
        
        [(NSValue *)b getValue:&sc];
        float deltaB = sc.delta;
        
        if (deltaA < deltaB) {
            return (NSComparisonResult)NSOrderedAscending;
        } else if (deltaA > deltaB) {
            return (NSComparisonResult)NSOrderedDescending;
        } else {
            return (NSComparisonResult)NSOrderedSame;
        }      
    };
    NSArray *snappedCoordinatesByMinDelta = [snappedCoordinates sortedArrayUsingComparator:sortBlock];
    
    [(NSValue *)[snappedCoordinatesByMinDelta objectAtIndex:0] getValue:&closest];
    
    return closest;
}

// FIXME broke
//- (NSPoint)snappedPointForDraggingWidgetWithPoint:(NSPoint)point
//                                          andSize:(NSSize)size
//{
//    point = [self convertPoint:point fromView:nil];
//    
//    NSPoint snappedPoint = point;
//    
//    point.x = roundf(point.x);
//    point.y = roundf(point.y);
//    
//    NSRect effectiveFrame = NSMakeRect(point.x, point.y, size.width, size.height);
//    
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    BOOL showGrid = [userDefaults boolForKey:@"showGrid"];
//    BOOL snapToGrid = showGrid && [userDefaults boolForKey:@"snapToGrid"];
//    BOOL showSmartGuides = [userDefaults boolForKey:@"showSmartGuides"];
//    BOOL snapToSmartGuides = showSmartGuides && [userDefaults boolForKey:@"snapToSmartGuides"];
//    
//    //NSPoint p = point; // real point
//    //p.x = roundf(p.x);
//    //p.y = roundf(p.y);
//    
//    //NSPoint ps = p; // real point snapped
//    
//    NSPoint sp = NSZeroPoint; // snappable point
//    NSPoint ssp = NSZeroPoint; // snapped snappable point
//    //uint sph; // snappable point handle
//    
//    // stops
//    NSMutableArray *xStops = [NSMutableArray array];
//    NSMutableArray *yStops = [NSMutableArray array];
//    
//    if (showGrid && !showSmartGuides) {
//        [self addGridSmartXStops:xStops andYStops:yStops];
//    } else if (showGrid && showSmartGuides) {
//        [self addObjectSmartXStops:xStops andYStops:yStops];
//        [self addGridSmartXStops:xStops andYStops:yStops];
//    } else if (!showGrid && showSmartGuides) {
//        [self addObjectSmartXStops:xStops andYStops:yStops];
//    }
//    
//    //NSSize canvasSize = [self bounds].size;
//    //MKSnappableCoordinate sc;
//    float diff;
//    
//    BOOL snappedX = NO;
//    BOOL snappedY = NO;
//    BOOL applySnap = NO;
//    
//    float deltaX = 0;
//    float deltaY = 0;
//    
//    //NSRect handleRect;
//    MKSnappableCoordinate scr;
//    NSArray *scrs;
//        
//    NSRect selectedRect = effectiveFrame;
//    
//    float xEdges[3] = {NSMinX(selectedRect), NSMidX(selectedRect), NSMaxX(selectedRect)};
//    for (uint i = 0; i < 3; i++) {
//        sp.x = xEdges[i];
//        
//        scrs = [self snappedCoordinatesFor:sp.x 
//                                withSnaps:xStops 
//                                andOffset:0 
//                         bySnappingToGrid:snapToGrid a
//                  ndSnappingToSmartGuides:snapToSmartGuides 
//                                    asMid:i == 1];
//        [[scrs objectAtIndex:0] getValue:&sc];
//        ssp.x = scr.coordinate;
//        diff = ssp.x - sp.x;
//        snappedX = scr.type != MKSnappableOriginalCoordinate;
//        applySnap = (scr.type == MKSnappableGridCoordinate && snapToGrid) || 
//        ((scr.type == MKSnappableObjectAdjacentCoordinate || scr.type == MKSnappableObjectEdgeCoordinate) && snapToSmartGuides);
//        
//        if (snappedX) {
//            break;
//        }
//    }
//    if (snappedX && applySnap) {
//        deltaX = diff;
//    }
//    
//    float yEdges[3] = {NSMinY(selectedRect), NSMidY(selectedRect), NSMaxY(selectedRect)};
//    for (uint i = 0; i < 3; i++) {
//        sp.y = yEdges[i];
//        
//        scrs = [self snappedCoordinatesFor:sp.y
//                                withSnaps:yStops 
//                                andOffset:0 
//                         bySnappingToGrid:snapToGrid a
//                  ndSnappingToSmartGuides:snapToSmartGuides 
//                                    asMid:i == 1];
//        [[scrs objectAtIndex:0] getValue:&sc];
//        ssp.y = scr.coordinate;
//        diff = ssp.y - sp.y;
//        snappedY = scr.type != MKSnappableOriginalCoordinate;
//        applySnap = (scr.type == MKSnappableGridCoordinate && snapToGrid) || 
//        ((scr.type == MKSnappableObjectAdjacentCoordinate || scr.type == MKSnappableObjectEdgeCoordinate) && snapToSmartGuides);
//        
//        if (snappedY) {
//            break;
//        }
//    }
//    if (snappedY && applySnap) {
//        deltaY = diff;
//    }
//
//    snappedPoint.x += deltaX;
//    snappedPoint.y += deltaY;
//    
//    snappedPoint = [self convertPointFromBase:snappedPoint];
//    return snappedPoint;
//}

- (void)mouseDragged:(NSEvent *)anEvent
{
    if (deferredAddSelection) {
        [self.dataSource addSelectionIndexes:deferredAddSelection];
        deferredAddSelection = nil;
    }
    if (deferredSetSelection) {
        [self.dataSource setSelectionIndexes:deferredSetSelection];
        deferredSetSelection = nil;
    }
    
    // we were editing, and clicked outside editor
	if (editingWidget) {
        [self textEditingFinish:self];
    }
    
	NSPoint pt = [self convertPoint:[anEvent locationInWindow] fromView:nil];
	pt.x = roundf(pt.x);
    pt.y = roundf(pt.y);
    
	if (self.marqueeStartPoint.x != 0 || self.marqueeStartPoint.y != 0) { // dragging a marquee
		[self updateMarquee:pt];
		[self setNeedsDisplay:YES];
        self.dragStartPoint = pt;
	} else {
        if (!didMouseDragWidgets) {
            [[self docUndoManager] setGroupsByEvent:NO]; 
            [[self docUndoManager] beginUndoGrouping];
        }
        
        didMouseDragWidgets = YES;
        
        // snapping
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        BOOL showGrid = [userDefaults boolForKey:@"showGrid"];
        BOOL snapToGrid = showGrid && [userDefaults boolForKey:@"snapToGrid"];
        BOOL showSmartGuides = [userDefaults boolForKey:@"showSmartGuides"];
        BOOL snapToSmartGuides = showSmartGuides && [userDefaults boolForKey:@"snapToSmartGuides"];
        
        NSPoint p = pt; // real point
        //p.x = roundf(p.x);
        //p.y = roundf(p.y);
        
        NSPoint ps = p; // real point snapped
        
        NSPoint sp = NSZeroPoint; // snappable point
        NSPoint ssp = NSZeroPoint; // snapped snappable point
        uint sph; // snappable point handle
        
        // stops
        NSMutableArray *xStops = [NSMutableArray array];
        NSMutableArray *yStops = [NSMutableArray array];
        
        if (showGrid && !showSmartGuides) {
            [self addGridSmartXStops:xStops andYStops:yStops];
        } else if (showGrid && showSmartGuides) {
            [self addObjectSmartXStops:xStops andYStops:yStops];
            [self addGridSmartXStops:xStops andYStops:yStops];
        } else if (!showGrid && showSmartGuides) {
            [self addObjectSmartXStops:xStops andYStops:yStops];
        }
        
        //NSSize canvasSize = [self bounds].size;
        //MKSnappableCoordinate sc;
        float diff;
        
        BOOL snappedX = NO;
        NSArray *scrsX;
        NSArray *scrsY;
        BOOL snappedY = NO;
        BOOL applySnap = NO;
        
        float deltaX;
        float deltaY;
        
        NSRect handleRect;
        MKSnappableCoordinate scr;
        NSMutableArray *scrs = [NSMutableArray array];
        
        if (self.dragState > 0) {
            MKWidget *w = [[self.dataSource selectedObjects] objectAtIndex:0];
            
            handleRect = [w handleRect:self.dragState];
            sph = self.dragState;
            sp = NSMakePoint(NSMidX(handleRect), NSMidY(handleRect));
            
            scrs = [NSMutableArray array];
            if ((self.dragState + 2) % 4 > 0) {
                 scrs = (NSMutableArray *)[self snappedCoordinatesFor:p.x
                                         withSnaps:xStops 
                                         andOffset:0 
                                  bySnappingToGrid:snapToGrid 
                          andSnappingToSmartGuides:snapToSmartGuides 
                                             asMid:NO];
                if ([scrs count] > 0) {
                    scr = [self closestSnappedCoordinate:scrs];
                } else {
                    scr = MKMakeSnappableCoordinate(p.x, MKSnappableOriginalCoordinate, NO);
                }
                ssp.x = scr.coordinate;
                snappedX = scr.type != MKSnappableOriginalCoordinate;
                applySnap = (scr.type == MKSnappableGridCoordinate && snapToGrid) || 
                            ((scr.type == MKSnappableObjectAdjacentCoordinate || scr.type == MKSnappableObjectEdgeCoordinate) && snapToSmartGuides);
                if (snappedX) {
                    scrsX = [self incidentalCoordinates:scrs
                                         withTargetDiff:scr.delta];
                }
                if (snappedX && applySnap) {
                    ps.x = ssp.x;
                }
            }
            
            scrs = [NSMutableArray array];
            if (self.dragState % 4 > 0) {
                scrs = (NSMutableArray *)[self snappedCoordinatesFor:p.y
                                         withSnaps:yStops 
                                         andOffset:0 
                                  bySnappingToGrid:snapToGrid 
                          andSnappingToSmartGuides:snapToSmartGuides 
                                             asMid:NO];
                if ([scrs count] > 0) {
                    scr = [self closestSnappedCoordinate:scrs];
                } else {
                    scr = MKMakeSnappableCoordinate(p.y, MKSnappableOriginalCoordinate, NO);
                }            
                ssp.y = scr.coordinate;
                snappedY = scr.type != MKSnappableOriginalCoordinate;
                applySnap = (scr.type == MKSnappableGridCoordinate && snapToGrid) || 
                            ((scr.type == MKSnappableObjectAdjacentCoordinate || scr.type == MKSnappableObjectEdgeCoordinate) && snapToSmartGuides);
                if (snappedY) {
                    scrsY = [self incidentalCoordinates:scrs
                                         withTargetDiff:scr.delta];
                }
                if (snappedY && applySnap) {
                    ps.y = ssp.y;
                }
            }
        } else {
            NSPoint startPoint = p;
            
            deltaX = p.x - self.dragStartPoint.x;
            deltaY = p.y - self.dragStartPoint.y;
            
            NSRect selectedRect = [MKWidget widgetsFrame:[self.dataSource selectedObjects]];
            
            scrs = [NSMutableArray array];
            float xEdges[3] = {NSMinX(selectedRect), NSMidX(selectedRect), NSMaxX(selectedRect)};
            for (uint i = 0; i < 3; i++) {
                sp.x = xEdges[i];
                
                [scrs addObjectsFromArray:[self snappedCoordinatesFor:sp.x 
                                         withSnaps:xStops 
                                         andOffset:deltaX 
                                  bySnappingToGrid:snapToGrid 
                          andSnappingToSmartGuides:snapToSmartGuides 
                                             asMid:i == 1]];
                
            }
            if ([scrs count] > 0) {
                snappedX = YES;
                
                scr = [self closestSnappedCoordinate:scrs];
                
                
                 diff = scr.delta;
                applySnap = (scr.type == MKSnappableGridCoordinate && snapToGrid) || 
                ((scr.type == MKSnappableObjectAdjacentCoordinate || scr.type == MKSnappableObjectEdgeCoordinate) && snapToSmartGuides);
                
                if (applySnap) {
                    startPoint.x -= deltaX - diff;
                    deltaX = diff;
                }
                
                scrsX = [self incidentalCoordinates:scrs
                                     withTargetDiff:diff];
                
            } else {
                snappedX = NO;
            }
                      
            scrs = [NSMutableArray array];
            float yEdges[3] = {NSMinY(selectedRect), NSMidY(selectedRect), NSMaxY(selectedRect)};
            for (uint i = 0; i < 3; i++) {
                sp.y = yEdges[i];
                
                [scrs addObjectsFromArray:[self snappedCoordinatesFor:sp.y
                                                            withSnaps:yStops 
                                                            andOffset:deltaY 
                                                     bySnappingToGrid:snapToGrid 
                                             andSnappingToSmartGuides:snapToSmartGuides 
                                                                asMid:i == 1]];
                
            }
            if ([scrs count] > 0) {
                snappedY = YES;
                
                scr = [self closestSnappedCoordinate:scrs];
                
                
                diff = scr.delta;
                applySnap = (scr.type == MKSnappableGridCoordinate && snapToGrid) || 
                ((scr.type == MKSnappableObjectAdjacentCoordinate || scr.type == MKSnappableObjectEdgeCoordinate) && snapToSmartGuides);
                
                if (applySnap) {
                    startPoint.y -= deltaY - diff;
                    deltaY = diff;
                }
                
                scrsY = [self incidentalCoordinates:scrs
                                     withTargetDiff:diff];
                
            } else {
                snappedY = NO;
            }
            
            
            
            self.dragStartPoint = startPoint;
        }
        
        if (snappedX) {
            snapLinesX = scrsX;
        } else {
            snapLinesX = [NSArray array];
        }
        
        if (snappedY) {
            snapLinesY = scrsY;
        } else {
            snapLinesY = [NSArray array];
        }
        
        // snapping code
        
		if (self.dragState > 0) { // resizing widget
			MKWidget *widget = [[self.dataSource selectedObjects] objectAtIndex:0];
			NSRect nf = [widget newFrameFromFrame:widget.frame 
                                        forHandle:self.dragState 
                                        withPoint:ps
                             withFixedAspectRatio:self.isFixedResizeAspectRatio 
                                  withAspectRatio:fixedResizeAspectRatio];
            
			widget.frame = nf;
            
            [[self docUndoManager] setActionName:@"Resize"];
            
            
		} else { // dragging widget(s)
			for (MKWidget *widget in [self.dataSource selectedObjects]) {
				[widget moveByDeltaX:deltaX deltaY:deltaY];
			}
            
            [[self docUndoManager] setActionName:@"Move"];
		}
	}
	
	
	[self autoscroll:anEvent];
}

- (void)mouseUp:(NSEvent *)anEvent
{
    if (!didMouseDragWidgets) {
        if (deferredAddSelection) {
            [self.dataSource addSelectionIndexes:deferredAddSelection];
        }
        if (deferredSetSelection) {
            [self.dataSource setSelectionIndexes:deferredSetSelection];
        }
        if (deferredRemoveSelection) {
            [self.dataSource removeSelectionIndexes:deferredRemoveSelection];
        }
    }
    
    // NOTE not sure if this is desirable behavior? (FW doesn't do this fwiw.)
    //      plus it currently deselects when you double click to edit
    //	// if we mouseup on a widget without moving, and without shift selected 
    //	// then select only the widget under mouse (turns out we weren't dragging)
    // NSPoint pt = [self convertPoint:[anEvent locationInWindow] fromView:nil];
    //	if (([anEvent modifierFlags] & NSShiftKeyMask) == 0 && NSEqualPoints(self.mouseDownPoint, pt)) {
    //		NSInteger hitWidgetIndex = [self indexOfTopMostWidgetAtPoint:pt];
    //		if (hitWidgetIndex != NSNotFound) {
    //			[self.dataSource setSelectionIndexes:[NSIndexSet indexSetWithIndex:hitWidgetIndex]];
    //		}
    //	}
    
    // FIXME: don't check for marquee'ing like this.
    BOOL redisplay = NO;
    if (self.marqueeStartPoint.x != 0 || self.marqueeStartPoint.y != 0) { // marqueed
        // for marquee (objects take care of triggering redrawing themselves via bindings)
        selectedWidgetsAtMarqueeStart = [NSArray array];
        redisplay = YES;
    } else if (didMouseDragWidgets) { // dragged
        // gonna need to re-show handles, since they'll be hidden
        didMouseDragWidgets = NO;
        redisplay = YES;
        
        [[self docUndoManager] setGroupsByEvent:YES]; 
        [[self docUndoManager] endUndoGrouping];
    }
    
    // reset mouse related state
    deferredAddSelection = nil;
    deferredSetSelection = nil;
    deferredRemoveSelection = nil;
	self.dragState = 0;
	self.dragStartPoint = self.mouseDownPoint = self.marqueeStartPoint = NSMakePoint(0, 0);
    
    // clear any snap lines
    snapLinesX = [NSArray array];
    snapLinesY = [NSArray array];
    
    // redraw as needed
    [self setNeedsDisplay:redisplay];
}

// NOTE good path for optimisation
- (void)mouseMoved:(NSEvent *)anEvent
{
    return;// if (self.dragStartPoint = self.mouseDownPoint = self.marqueeStartPoint
    
    NSPoint pt = [self convertPoint:[anEvent locationInWindow] fromView:nil];
    pt.x = roundf(pt.x);
    pt.y = roundf(pt.y);
    
	NSInteger hitWidgetIndex = [self indexOfTopMostUnselectedWidgetOutsideSelectionAtPoint:pt];
    
    if (hitWidgetIndex != NSNotFound) {
        MKWidget *lastHoverWidget = hoverWidget;
        hoverWidget = [[self.dataSource arrangedObjects] objectAtIndex:hitWidgetIndex];
        
        if (lastHoverWidget) {
            if (lastHoverWidget != hoverWidget) {
                [self setNeedsDisplayInRect:NSUnionRect([hoverWidget drawFrame], [lastHoverWidget drawFrame])];
            } else {
                [self setNeedsDisplayInRect:[hoverWidget drawFrame]];
            }
        } else {
            [self setNeedsDisplayInRect:[hoverWidget drawFrame]];
        }
    } else if (hoverWidget) {
        [self setNeedsDisplayInRect:[hoverWidget drawFrame]];
        hoverWidget = nil;
    }
}

- (void)updateMarquee:(NSPoint)newPoint
{
	NSRect mr = NSRectFromTwoPoints(self.marqueeStartPoint, self.dragStartPoint);
    NSArray *arrangedObjects = [self.dataSource arrangedObjects];
	
	for (NSInteger i = 0; i < [arrangedObjects count]; i++) {
		if (NSIntersectsRect(mr, [(MKWidget *)[arrangedObjects objectAtIndex:i] drawFrame])) {
			[self.dataSource addSelectionIndexes:[NSIndexSet indexSetWithIndex:i]];
		} else {
            if (![selectedWidgetsAtMarqueeStart containsObject:[arrangedObjects objectAtIndex:i]]) {
                [self.dataSource removeSelectionIndexes:[NSIndexSet indexSetWithIndex:i]];
            }
        }
	}
}

/* text editing */

- (BOOL)control:(NSControl *)control 
       textView:(NSTextView *)textView 
doCommandBySelector:(SEL)commandSelector
{
    BOOL result = NO;
    
    if (![textEditingWidget useSingleLineEditableTextMode] && commandSelector == @selector(insertNewline:)) {
        // new line action:
        // always insert a line-break character and don’t cause the receiver to end editing
        [textView insertNewlineIgnoringFieldEditor:self]; 
        result = YES;
    }
    
    if (commandSelector == @selector(insertTab:)) {
        // tab action:
        // always insert a tab character and don’t cause the receiver to end editing
        [textView insertTabIgnoringFieldEditor:self];
        result = YES;
    }
    
    return result;
}

- (void)textEditingStart
{
	// set location
	[textEditor setFrameOrigin:[textEditingWidget frame].origin];
	
	// update text
	[textEditor setStringValue:[textEditingWidget text]];
	
    // set single/multiline mode
    [[textEditor cell] setUsesSingleLineMode:[textEditingWidget useSingleLineEditableTextMode]];
    [[textEditor cell] setWraps:![textEditingWidget useSingleLineEditableTextMode]];
    NSSize size;
    if (![textEditingWidget useSingleLineEditableTextMode]) {
        size = NSMakeSize(400, 250);
    } else {
        size = NSMakeSize(400, 22);
    }
    [textEditor setFrameSize:size];
    
	// show text input + focus
	[textEditor setHidden:NO]; 
	[textEditor setEnabled:YES];
    [textEditor becomeFirstResponder];
}

- (void)textEditingFinish:(id)sender
{
    editingWidget = NO;
    
    if (textEditingWidget) {
        // update text
        textEditingWidget.text = [textEditor stringValue];
        textEditingWidget = nil;
    }
    
    // hide
	[textEditor setHidden:YES];
	[textEditor setEnabled:NO];
}

- (NSUndoManager *)docUndoManager
{
    return [self undoManager];
}

// zooming

- (void)scrollWheel:(NSEvent *)theEvent
{
    
    if (([theEvent modifierFlags] & NSAlternateKeyMask) != 0) {
        
        if ([self.dataSource.selectedObjects count] > 0) {
            NSRect r = [MKWidget widgetsFrame:self.dataSource.selectedObjects];
            NSPoint pt = NSMakePoint(NSMidX(r), NSMidY(r));
            
            [self zoomWithScrollWheelDelta:[theEvent deltaY] 
                             toCentrePoint:pt];
        
        } else {
            [super scrollWheel:theEvent];
        }
        
		
	} else {
        [super scrollWheel:theEvent];
    }
}

@end
