//
//  PrioritySplitViewDelegate.m
//  ColumnSplitView
//
//  Created by Matt Gallagher on 2009/09/01.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PrioritySplitViewDelegate : NSObject <NSSplitViewDelegate> {
    @private
    NSMutableDictionary *lengthsByViewIndex;
	NSMutableDictionary *viewIndicesByPriority;
}
- (void)setMinimumLength:(CGFloat)minLength
          forViewAtIndex:(NSInteger)viewIndex;
- (void)setPriority:(NSInteger)priorityIndex
     forViewAtIndex:(NSInteger)viewIndex;
@end
