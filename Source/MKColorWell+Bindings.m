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

#import "MKColorWell+Bindings.h"

@implementation MKColorWell (Bindings)

-(void)propagateValue:(id)value
           forBinding:(NSString*)binding;
{
	NSParameterAssert(binding != nil);
    
	NSDictionary* bindingInfo = [self infoForBinding:binding];
	if (!bindingInfo)
		return;
    
	NSDictionary* bindingOptions = [bindingInfo objectForKey:NSOptionsKey];
	if (bindingOptions) {
		NSValueTransformer* transformer = [bindingOptions valueForKey:NSValueTransformerBindingOption];
		if (!transformer || (id)transformer == [NSNull null]) {
			NSString* transformerName = [bindingOptions valueForKey:NSValueTransformerNameBindingOption];
			if(transformerName && (id)transformerName != [NSNull null]){
				transformer = [NSValueTransformer valueTransformerForName:transformerName];
			}
		}
        
		if (transformer && (id)transformer != [NSNull null]) {
			if ([[transformer class] allowsReverseTransformation]) {
				value = [transformer reverseTransformedValue:value];
			} else {
				NSLog(@"WARNING: binding \"%@\" has value transformer, but it doesn't allow reverse transformations in %s", binding, __PRETTY_FUNCTION__);
			}
		}
	}
    
	id boundObject = [bindingInfo objectForKey:NSObservedObjectKey];
	if (!boundObject || boundObject == [NSNull null]) {
		NSLog(@"ERROR: NSObservedObjectKey was nil for binding \"%@\" in %s", binding, __PRETTY_FUNCTION__);
		return;
	}
    
	NSString* boundKeyPath = [bindingInfo objectForKey:NSObservedKeyPathKey];
	if (!boundKeyPath || (id)boundKeyPath == [NSNull null]) {
		NSLog(@"ERROR: NSObservedKeyPathKey was nil for binding \"%@\" in %s", binding, __PRETTY_FUNCTION__);
		return;
	}
    
    if ([[boundObject valueForKeyPath:boundKeyPath] isNotEqualTo:value])
        [boundObject setValue:value forKeyPath:boundKeyPath];
}

@end
