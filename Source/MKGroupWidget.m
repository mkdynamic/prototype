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

#import "MKGroupWidget.h"
#import "MKWidgetELement.h"
#import "MKWidget.h"

@implementation MKGroupWidget

static NSDictionary *delegatedProperties;

+ (void)load
{
    delegatedProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithBool:YES], @"strokeColor",
                           [NSNumber numberWithBool:YES], @"fillColor",
                           [NSNumber numberWithBool:YES], @"fontStyleMask",
                           [NSNumber numberWithBool:YES], @"textAlignment",
                           [NSNumber numberWithBool:YES], @"strokeStyle",
                           [NSNumber numberWithBool:YES], @"fontSize",
                           
                           // iphone
                           [NSNumber numberWithBool:YES], @"properties.showBar",
                           
                           // sketch
                           [NSNumber numberWithBool:YES], @"properties.sketch",
                           nil];
}

@synthesize groupedWidgets;

- (NSMutableArray *)subelements {
	return [NSMutableArray arrayWithArray:self.groupedWidgets];
}

- (id)valueForKeyPath:(NSString *)keyPath
{
    if ([delegatedProperties valueForKey:keyPath]) {
      return [[arrayControler selection] valueForKeyPath:keyPath];
    } else {
       return [super valueForKeyPath:keyPath];
    }
}

- (void)setValue:(id)value forKeyPath:(NSString *)key
{
    if ([delegatedProperties valueForKey:key]) {
        for (MKWidgetElement *el in [self subelements]) {
            [el.groupedWidget setValue:value forKeyPath:key];
        }
    }

    [super setValue:value forKeyPath:key];
}

- (void)setInitialGroupFrame:(NSRect)aFrame {
    [self willChangeValueForKey:@"frame"];
	frame = [self constrainedFrame:aFrame];
    self.minNaturalSize = frame.size;
    self.maxNaturalSize = frame.size;
    [self didChangeValueForKey:@"frame"];
}

// NOTE this only works if the new bounds are non-zero in dimensions (since it users a scalar transform)
- (void)setFrame:(NSRect)aFrame {
    NSRect oldFrame = frame;
    super.frame = aFrame;
    
    float ratioX = frame.size.width / oldFrame.size.width;
    float ratioY = frame.size.height / oldFrame.size.height;
    CGAffineTransform t;
    CGRect b;
    
    // TODO as a polish detail, we can detect what the bottom most grouped object is
    //      and if it's a browser window/iphone etc. we can make the gravity for everything else
    //      anchor to that :)
    for (MKWidgetElement *el in [self subelements]) {
        // move (to ensure scaling about group origin)
        t = CGAffineTransformMakeTranslation(0 - oldFrame.origin.x, 0 - oldFrame.origin.y);
        b = CGRectApplyAffineTransform(NSRectToCGRect(el.groupedWidget.frame), t);
        
        // scale + move back (to ensure scaling about group origin) + translate by offset
        t = CGAffineTransformMake(ratioX, 0.f, 0.f, ratioY, frame.origin.x, frame.origin.y);
        b = CGRectApplyAffineTransform(b, t);
        el.groupedWidget.frame = NSRectFromCGRect(b);
    }
}

- (void)setGroupedWidgets:(NSArray *)widgetElements {
    NSArrayController *props = [[NSArrayController alloc] init];
    
    for (MKWidgetElement *el in widgetElements) {
        el.group = self;
        [props addObject:el.groupedWidget];
    }
    
    NSRange allRng = NSMakeRange(0, [[props arrangedObjects] count]);
    [props setSelectionIndexes:[NSIndexSet indexSetWithIndexesInRange:allRng]];
    
    arrayControler = props;
    groupedWidgets = widgetElements;
}

/* NSCoding */

- (void)encodeWithCoder:(NSCoder *)coder {
	[super encodeWithCoder:coder];
    [coder encodeObject:self.groupedWidgets forKey:@"grouped_widgets"];
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
    self.groupedWidgets = [coder decodeObjectForKey:@"grouped_widgets"];
	
	return self;
}

/* NSCopying */

- (id)copyWithZone:(NSZone *)zone {
    MKGroupWidget *copy = [super copyWithZone:zone];
    
    NSMutableArray *groupWidgs = [NSMutableArray array];
    for (MKWidget *widget in self.groupedWidgets) {
        [groupWidgs addObject:[widget copyWithZone:zone]];
    }
    copy.groupedWidgets = (NSArray *)groupWidgs;
    
    return copy;
}

@end
