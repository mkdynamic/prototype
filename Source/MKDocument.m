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

#import "MKDocument.h"
#import "MKWidget.h"
#import "MKAppController.h"
#import "MKWindowController.h"
#import "MKDrawView.h"
#import "MKExportAccessoryView.h"

@interface MKDocument ()

- (void)printDocument:(id)sender onlySelection:(BOOL)isOnlySelection;
- (void)exportDocument:(id)sender onlySelection:(BOOL)isOnlySelection;
- (NSString *)filenameForFormat:(NSPopUpButton *)format withURL:(NSURL *)url;

@end

@implementation MKDocument

@synthesize objects;

- (id)init 
{
    self = [super init];
    if (self) {
		self.objects = [NSArray array];
		_selection = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)makeWindowControllers 
{
    MKWindowController *windowController = [[MKWindowController alloc] init];
    [self addWindowController:windowController];
}

- (NSData *)dataOfType:(NSString *)typeName 
                 error:(NSError **)outError 
{
	return [NSKeyedArchiver archivedDataWithRootObject:[self objects]];
}

- (BOOL)readFromData:(NSData *)data 
              ofType:(NSString *)typeName 
               error:(NSError **)outError 
{
	NSArray *arr = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	
	self.objects = arr;
	return YES;
}

- (void)selectObject:(id)object 
{
	if ([self.objects containsObject:object] && ![_selection containsObject:object]) {
		[_selection addObject:object];
	}
}

- (void)deselectObject:(id)object 
{
	[_selection removeObject:object];
}

- (void)selectAll 
{
	[_selection setArray:self.objects];
}

- (void)deselectAll 
{
	[_selection removeAllObjects];
}

- (NSArray *)selection 
{
	return _selection;
}

/* undo machinary */

- (void)setObjects:(NSArray *)newObjects 
{
    // see if objects are same (but array or order could be diff)
    BOOL sameObjects = [objects isEqualToArray:newObjects];
    
    // stop observing old objects
    if (objects && !sameObjects)
        for (MKWidget *widget in objects)
            [self stopObservingWidgetForUndo:widget];
    
    // record change for undo
    [[[self undoManager] prepareWithInvocationTarget:self] setObjects:objects];
    
    // set value
    objects = [newObjects copy];
    
    // start observing new objects
    if (objects && !sameObjects)
        for (MKWidget *widget in objects)
            [self startObservingWidgetForUndo:widget];
}

- (void)startObservingWidgetForUndo:(MKWidget *)widget 
{
    for (NSString *key in [[widget keyPathsToObserveForUndo] keyEnumerator])
        [widget addObserver:self 
                 forKeyPath:key 
                    options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                    context:nil];
}

- (void)stopObservingWidgetForUndo:(MKWidget *)widget 
{
    for (NSString *key in [[widget keyPathsToObserveForUndo] keyEnumerator])
        [widget removeObserver:self 
                    forKeyPath:key];
}

- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object 
                        change:(NSDictionary *)change 
                       context:(void *)context 
{
    if ([object isKindOfClass:[MKWidget class]]) {
        MKWidget *widget = (MKWidget *)object;
        
        id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
        id newValue = [change objectForKey:NSKeyValueChangeNewKey];
        
        if ([newValue isNotEqualTo:oldValue]) {
            NSUndoManager *undo = [self undoManager];
            [[undo prepareWithInvocationTarget:widget] setValue:oldValue 
                                                     forKeyPath:keyPath];
        
            if (!([undo isUndoing] || [undo isRedoing])) {
                NSString *actionName = [[widget keyPathsToObserveForUndo] valueForKey:keyPath];
                [undo setActionName:actionName];
            }
        }
    } else {
        // when we don't recognize the observed action, pass it up call chain
        [super observeValueForKeyPath:keyPath 
                             ofObject:object 
                               change:change 
                              context:context];
    }
}

/* printing */

- (void)printDocument:(id)sender
{
    [self printDocument:sender onlySelection:NO];
}

- (void)printSelection:(id)sender
{
    [self printDocument:sender onlySelection:YES];
}

- (void)printOperationDidRun:(NSPrintOperation *)printOperation
                     success:(BOOL)success
                 contextInfo:(void *)info {
    if (success) {
        // Can save updated NSPrintInfo, but only if you have
        // a specific reason for doing so
        // [self setPrintInfo: [printOperation printInfo]];
    }
}

- (void)printDocument:(id)sender
        onlySelection:(BOOL)isOnlySelection
{
    MKAppController *appDelegate = (MKAppController *)[NSApp delegate];
    MKWindowController *windowController = appDelegate.docWindowController;
    NSWindow *window = windowController.window;
    
    MKDrawView *view = [[MKDrawView alloc] initWithFrame:NSMakeRect(0, 0, 99999, 99999)];
    view.dataSource = appDelegate.docWindowController.graphicsController;
    view.outputMode = 1;
    
    NSPrintInfo *printInfo = [self printInfo];
    [printInfo setSelectionOnly:isOnlySelection];
    NSPrintOperation *op = [NSPrintOperation printOperationWithView:(NSView *)view
                                                          printInfo:printInfo];
    
    [op runOperationModalForWindow:window
                          delegate:self
                    didRunSelector:@selector(printOperationDidRun:success:contextInfo:)
                       contextInfo:NULL];
}

/* export */

- (void)exportDocument:(id)sender
{
    [self exportDocument:sender onlySelection:NO];
}

- (void)exportSelection:(id)sender
{
    [self exportDocument:sender onlySelection:YES];
}

- (void)exportDocument:(id)sender
         onlySelection:(BOOL)isOnlySelection
{
    MKAppController *appDelegate = (MKAppController *)[NSApp delegate];
    MKWindowController *windowController = appDelegate.docWindowController;
    NSWindow *window = windowController.window;
    
    NSViewController *accessoryViewController = [[NSViewController alloc] initWithNibName:@"ExportSavePanelAccessoryView" bundle:nil];
    MKExportAccessoryView *accessoryView = (MKExportAccessoryView *)accessoryViewController.view;
    [accessoryView.fileType setTarget:self];
    [accessoryView.fileType setAction:@selector(changedExportFileFormat:)];
    
    NSSavePanel *panel = [NSSavePanel savePanel];
    accessoryView.savePanel = panel;
    [panel setAllowedFileTypes:@[(id)kUTTypePDF, (id)kUTTypePNG, (id)kUTTypeJPEG, (id)kUTTypeGIF, (id)kUTTypeTIFF]];
    [panel setAccessoryView:accessoryView];
    [panel setExtensionHidden:NO];
    [panel setCanSelectHiddenExtension:YES];
    [panel setNameFieldStringValue:@"export.pdf"];
    [panel setPrompt:@"Export"];
    [panel setTitle:@"Export"];
    [panel setNameFieldLabel:@"Export As:"];
    [panel setAllowsOtherFileTypes:NO];
    
    [panel beginSheetModalForWindow:window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            MKDrawView *view = [[MKDrawView alloc] initWithFrame:NSMakeRect(0, 0, 99999, 99999)];
            NSArrayController *arrayController = [[NSArrayController alloc] init];
            if (isOnlySelection) {
                arrayController.content = appDelegate.docWindowController.graphicsController.selectedObjects;
            } else {
                arrayController.content = appDelegate.docWindowController.graphicsController.arrangedObjects;
            }
            view.dataSource = arrayController;
            view.outputMode = 2;
            NSData *data;
            
            switch ([accessoryView.fileType selectedTag]) {
                case 0:
                    data = [view pdfData];
                    break;
                case 1:
                    data = [view imageData:kUTTypePNG];
                    break;
                case 2:
                    data = [view imageData:kUTTypeJPEG];
                    break;
                case 3:
                    data = [view imageData:kUTTypeGIF];
                    break;
                case 4:
                    data = [view imageData:kUTTypeTIFF];
                    break;
                default:
                    break;
            }
            
            NSURL *url = panel.URL;
            [data writeToURL:url atomically:NO];
        }
    }];
}

- (NSString *)filenameForFormat:(NSPopUpButton *)format
                        withURL:(NSURL *)url
{
    NSString *ext;
    
    switch ([format selectedTag]) {
        case 0:
            ext = @"pdf";
            break;
        case 1:
            ext = @"png";
            break;
        case 2:
            ext = @"jpg";
            break;
        case 3:
            ext = @"gif";
            break;
        case 4:
            ext = @"tiff";
            break;
        default:
            break;
    }
    
    NSString *filename;
    if (url) {
        NSString *filenameWithoutExt = [[url URLByDeletingPathExtension] lastPathComponent];
        filename = [filenameWithoutExt stringByAppendingPathExtension:ext];
    } else {
        filename = @"";
    }
    
    return filename;
}

// FIXME if you uncheck extension and then change file type to non-PDF, the extension is wrong (is PDF)
//- (NSString *)panel:(id)sender
//userEnteredFilename:(NSString *)filename
//          confirmed:(BOOL)okFlag
//{
//    NSSavePanel *savePanel = (NSSavePanel *)sender;
//    NSPopUpButton *btn = ((MKExportAccessoryView *)savePanel.accessoryView).fileType;
//    NSString *sanitizedFilename = [self filenameForFormat:btn withURL:[savePanel URL]];
//    [savePanel setNameFieldStringValue:sanitizedFilename];
//    return sanitizedFilename;
//}

- (void)changedExportFileFormat:(id)sender
{
    NSPopUpButton *btn = (NSPopUpButton *)sender;
    NSSavePanel *savePanel = ((MKExportAccessoryView *)btn.superview).savePanel;
    NSString *filename = [self filenameForFormat:btn withURL:[savePanel URL]];
    [savePanel setNameFieldStringValue:filename];
}

@end
