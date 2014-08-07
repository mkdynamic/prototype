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

#import "MKWidgetElement.h"
#import "MKWidget.h"

@implementation MKWidgetElement

@synthesize groupedWidget, group;

- (void)drawForWidget:(MKWidget *)widget {
    [groupedWidget drawRect:NSMakeRect(0, 0, FLT_MAX, FLT_MAX) withSelection:NO];
}

- (void)setGroupedWidget:(MKWidget *)widget {
    widget.widgetElement = self;
    groupedWidget = widget;
}

/* NSCoding */

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:[self groupedWidget] forKey:@"grouped_widget"];
}

- (id)initWithCoder:(NSCoder *)coder {
	[self init];
	[self setGroupedWidget:[coder decodeObjectForKey:@"grouped_widget"]];
	
	return self;
}

/* NSCopying */

- (id)copyWithZone:(NSZone *)zone {
    MKWidgetElement *copy = [[[self class] allocWithZone:zone] init];
    [copy setGroupedWidget:[[self groupedWidget] copyWithZone:zone]];
    
    return copy;
}

@end
