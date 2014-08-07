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

#import "MKWidgetToolView.h"
#import "MKWidget.h"
#import "JLNDragEffectManager.h"
#import "MKElement.h"

NSSize MKSizeToFit(NSSize size, NSSize bounds) {
    float widthScale = 0;
    float heightScale = 0;
    
    if (size.width != 0)
        widthScale = bounds.width / size.width;
    
    if (size.height != 0)
        heightScale = bounds.height / size.height;                
    
    float scale = MIN(widthScale, heightScale);
    
    return NSMakeSize(size.width * scale, size.height * scale);
    
}

@implementation MKWidgetToolView

@synthesize kind, widget, insideImg, outsideImg, img;

- (BOOL)isFlipped {
	return YES;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
    return YES;
}

- (NSString *)kind {
    return (NSString *)NSStringFromClass((Class)[delegate representedObject]);
}

- (MKWidget *)widget {
    if (widget == nil) {
        widget = [(MKWidget *)[(Class)[delegate representedObject] alloc] init];
        widget.sidebar=YES;
    }
    return widget;
}

- (void)saveImage:(NSImage *)anImage withSize:(NSString *)size {
    NSString *fileName = [NSString stringWithFormat:@"%@_%@", [self kind], size];
    fileName = [fileName stringByAppendingPathExtension:@"png"];
    NSString *filePath = [@"~/desktop/prototype/" stringByExpandingTildeInPath];
    filePath = [filePath stringByAppendingPathComponent:fileName];
    
    NSData *imageData = [anImage TIFFRepresentation];
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
    [imageRep setSize:[anImage size]];
    imageData = [imageRep representationUsingType:NSPNGFileType properties:nil];
    [imageData writeToFile:filePath atomically:NO];
}


- (void)drawRect:(NSRect)dirtyRect {
    if (self.outsideImg == nil) {
        widget.sidebar=NO;
        [widget setSize:[widget defaultSize]];
        self.outsideImg = [self.widget asImage];
        widget.sidebar=YES;
    }
    
    NSRect rect = NSInsetRect([self bounds], 10, 10);
    
    NSSize natSize = widget.defaultSize;
    NSSize targSize = MKSizeToFit(natSize, rect.size);
    
    [self.widget setSize:targSize];
    
    targSize = self.widget.frame.size;
    
    rect.origin.x += (rect.size.width - targSize.width) / 2;
    rect.origin.y += (rect.size.height - targSize.height) / 2;
    rect.size = targSize;
    
    [self.widget setFrame:rect];
    [self.widget drawRect:dirtyRect withSelection:NO];

    if (self.insideImg == nil) {
        self.insideImg = [self.widget asImage];
    }
}

- (void)mouseDown:(NSEvent *)theEvent {
    NSPoint pt = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    NSPasteboard *dragPasteboard = [NSPasteboard pasteboardWithName:NSDragPboard];
    [dragPasteboard declareTypes:[NSArray arrayWithObject:@"widget"] owner:self];
    
    [self dragImage:[[[NSImage alloc] initWithSize:NSMakeSize(1, 1)] autorelease] 
                 at:pt 
             offset:NSZeroSize
              event:theEvent 
         pasteboard:dragPasteboard 
             source:self 
          slideBack:NO];
    
    [super mouseDown:theEvent];
}

#pragma mark Dragging Source

- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal {
	return NSDragOperationNone;
}

- (void)draggedImage:(NSImage *)anImage beganAt:(NSPoint)aPoint {
	// Let's figure out our geometry. For shits-n-giggles, we'll 
	// make the whole window our source screen rect, and the 
	// current mouse position (at start of drag) as the slide-back point
	NSPoint startPointInScreen = [NSEvent mouseLocation];
	NSRect sourceScreenRect = [[self superview] bounds];
    sourceScreenRect.origin = [[self window] frame].origin;
	
	// Let's use some images reminiscent of Interface Builder's
	// drag-from-Library-palette-to-make-a-real-object effect
	NSImage *insideImage = self.insideImg;
	NSImage *outsideImage = self.outsideImg;
	
	// Don the boas and start the drag show!
	[[JLNDragEffectManager sharedDragEffectManager] startDragShowFromSourceScreenRect:sourceScreenRect 
																	  startingAtPoint:startPointInScreen 
																			   offset:NSZeroSize
																		  insideImage:insideImage 
																		 outsideImage:outsideImage 
																			slideBack:YES];
}

- (void)draggedImage:(NSImage *)draggedImage movedTo:(NSPoint)screenPoint {
	// Update the position
	[[JLNDragEffectManager sharedDragEffectManager] updatePosition];
}

- (void)draggedImage:(NSImage *)anImage endedAt:(NSPoint)aPoint operation:(NSDragOperation)operation {
	// End the drag show, clean up the glitter and sweat-and-masquera puddles and call it a day
	[[JLNDragEffectManager sharedDragEffectManager] endDragShowWithResult:operation];
	
	// Do any other processing you might need, including going home to your cats and wig collection
	// ...
}

@end
