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

#import "MKIconPickerController.h"

@implementation MKIconPickerController

@synthesize icons;

- (id)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    if (self) {
        icons = [NSMutableArray array];
        
        NSString *bundleRoot = [[NSBundle mainBundle] bundlePath];
        NSFileManager *manager = [NSFileManager defaultManager];
        NSDirectoryEnumerator *direnum = [manager enumeratorAtPath:bundleRoot];
        
        NSString *filename;
        
        while ((filename = [direnum nextObject] )) {
            filename = [bundleRoot stringByAppendingPathComponent:filename];
            if ([filename hasSuffix:@"_s1.png"] || [filename hasSuffix:@".eps"]) {
                NSImage *img = [[NSImage alloc] initWithContentsOfFile:filename];
                img.name = filename;
                [icons addObject:img];
            }
        }
    }
    
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after 
    // your window controller's window has been loaded from its nib file.
}

- (void)pickIcon:(id)sender {
    NSButton *btn = (NSButton *)sender;
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"IconPicked" object:[[btn image] name]];
    
    [self close];
}

@end
