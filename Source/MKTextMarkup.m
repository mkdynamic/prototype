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

#import "MKTextMarkup.h"
#import "OnigRegexp.h"

static const OnigOption phraseMarkupExpressionOptions = (OnigOptionMultiline |
                                                         OnigOptionIgnorecase |
                                                         OnigOptionExtend);
static const OnigOption listMarkupExpressionOptions = phraseMarkupExpressionOptions;

static NSString *const unorderedListExpressionString =
    @"\
    (?<=^) \
    (?<markup>[\\*\\-]{1,5}\\s+?) \
    ";
static OnigRegexp *unorderedListExpression = nil;

static NSString *const orderedListExpressionString =
    @"\
    (?<=^) \
    (?<markup>[\\#(\\d.)]{1,5}\\s+?) \
    ";
static OnigRegexp *orderedListExpression = nil;

static NSString *const boldExpressionString =
    @"\
    (?!^\\*\\s) \
    (?!^\\*\\*\\s) \
    (?!^\\*\\*\\*\\s) \
    (?!^\\*\\*\\*\\*\\s) \
    (?!^\\*\\*\\*\\*\\*\\s) \
    (?<=^|[\\s_,(\\-'\"]) \
    (?<markup-open>\\*) \
    (?=\\S) \
    (?<content>[^\\n]+?) \
    (?<=\\S) \
    (?<markup-close>\\*) \
    (?=$|[\\s_,\\-.?!)'\"]) \
    ";
static OnigRegexp *boldExpression = nil;
static void (^ const boldFormatter)(NSMutableAttributedString *content) =
    ^(NSMutableAttributedString *content) {
        [content applyFontTraits:NSBoldFontMask
                           range:NSMakeRange(0, [content length])];
    };

static NSString *const italicExpressionString =
    @"\
    (?<markup-open>_) \
    (?=\\S) \
    (?<content>.+?_*) \
    (?<=\\S) \
    (?<markup-close>_) \
    ";
static OnigRegexp *italicExpression = nil;
static void (^ const italicFormatter)(NSMutableAttributedString *content) =
    ^(NSMutableAttributedString *content) {
        [content applyFontTraits:NSItalicFontMask
                           range:NSMakeRange(0, [content length])];
    };

static NSString *const superscriptExpressionString =
    @"\
    (?<markup-open>\\^) \
    (?=\\S) \
    (?<content>.+?\\^*) \
    (?<=\\S) \
    (?<markup-close>\\^) \
    ";
static OnigRegexp *superscriptExpression = nil;
static void (^ const superscriptFormatter)(NSMutableAttributedString *content) =
^(NSMutableAttributedString *content) {
    [content addAttribute:NSSuperscriptAttributeName
                    value:[NSNumber numberWithInt:1]
                    range:NSMakeRange(0, [content length])];
};

static NSString *const subscriptExpressionString =
    @"\
    (?<markup-open>\\~) \
    (?=\\S) \
    (?<content>.+?\\~*) \
    (?<=\\S) \
    (?<markup-close>\\~) \
    ";
static OnigRegexp *subscriptExpression = nil;
static void (^ const subscriptFormatter)(NSMutableAttributedString *content) =
^(NSMutableAttributedString *content) {
    [content addAttribute:NSSuperscriptAttributeName
                    value:[NSNumber numberWithInt:-1]
                    range:NSMakeRange(0, [content length])];
};

static NSString *const strikethroughExpressionString =
    @"\
    (?!^\\-\\s) \
    (?!^\\-\\-\\s) \
    (?!^\\-\\-\\-\\s) \
    (?!^\\-\\-\\-\\-\\s) \
    (?!^\\-\\-\\-\\-\\-\\s) \
    (?<=^|[\\s_,(\'\"]) \
    (?<markup-open>\\-) \
    (?=\\S) \
    (?<content>[^\\n]+?) \
    (?<=\\S) \
    (?<markup-close>\\-) \
    (?=$|[\\s_,.?!)'\"]) \
    ";
static OnigRegexp *strikethroughExpression = nil;
static void (^ const strikethroughFormatter)(NSMutableAttributedString *content) =
^(NSMutableAttributedString *content) {
    [content addAttribute:NSStrikethroughStyleAttributeName
                    value:[NSNumber numberWithInt:NSUnderlineStyleSingle]
                    range:NSMakeRange(0, [content length])];
};

static NSString *const linkExpressionString =
    @"\
    (?<markup-open>\\<) \
    (?=\\S) \
    (?<content>.+?\\>*) \
    (?<=\\S) \
    (?<markup-close>\\>) \
    ";
static OnigRegexp *linkExpression = nil;
static void (^ const linkFormatter)(NSMutableAttributedString *content) =
^(NSMutableAttributedString *content) {
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSColor blueColor], NSForegroundColorAttributeName,
                           [NSNumber numberWithInt:NSUnderlineStyleSingle], NSUnderlineStyleAttributeName,
                           nil];
    [content addAttributes:attrs
                     range:NSMakeRange(0, [content length])];
};

@interface MKTextMarkup ()
+ (void)markupPhrase:(const NSMutableAttributedString *)output
      withExpression:(const OnigRegexp *)expression
        andFormatter:(const void (^)(NSMutableAttributedString *))formatter;
+ (void)markupUnorderedList:(const NSMutableAttributedString *)output;
+ (void)markupOrderedList:(const NSMutableAttributedString *)output;
@end

@implementation MKTextMarkup
+ (void)initialize
{
    // *...*
    boldExpression = [OnigRegexp compile:boldExpressionString
                                 options:phraseMarkupExpressionOptions];

    // _..._
    italicExpression = [OnigRegexp compile:italicExpressionString
                                   options:phraseMarkupExpressionOptions];

    // ^...^
    superscriptExpression = [OnigRegexp compile:superscriptExpressionString
                                        options:phraseMarkupExpressionOptions];

    // ~...~
    subscriptExpression = [OnigRegexp compile:subscriptExpressionString
                                      options:phraseMarkupExpressionOptions];

    // -...-
    strikethroughExpression = [OnigRegexp compile:strikethroughExpressionString
                                          options:phraseMarkupExpressionOptions];

    // <...>
    linkExpression = [OnigRegexp compile:linkExpressionString
                                 options:phraseMarkupExpressionOptions];

    // [*-] Item 1
    unorderedListExpression = [OnigRegexp compile:unorderedListExpressionString
                                          options:listMarkupExpressionOptions];

    // # Item 1
    orderedListExpression = [OnigRegexp compile:orderedListExpressionString
                                        options:listMarkupExpressionOptions];
}

+ (void)markupUnorderedList:(const NSMutableAttributedString *)output
{
    OnigRegexp *expression = unorderedListExpression;
    OnigResult *result;
    NSString *matchedMarkup;
    uint indentLevel;
    NSRange replaceRange;
    NSMutableAttributedString *replaceContent;
    int cursor = 0;
    float indentSize = 15.f;
    float hangingTextIndent;
    float bulletIndent;
    NSMutableParagraphStyle *par;
    NSRange effectiveRange;

    while ((result = [expression search:[output string] start:cursor])) {
        // get the matched markup
        matchedMarkup = [result stringForName:@"markup"];

        // calc. the indent level (length minus any space)
        indentLevel = [[matchedMarkup stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] - 1;

        // get the range of the entrie match (including the markup)
        replaceRange = [result bodyRange];



        // prepare the replacement
        replaceContent = [[output attributedSubstringFromRange:replaceRange] mutableCopy];
        par = [(NSDictionary *)[replaceContent attribute:NSParagraphStyleAttributeName
                                               atIndex:0
                                 longestEffectiveRange:&effectiveRange
                                               inRange:NSMakeRange(0, [replaceContent length])] mutableCopy];
        [replaceContent replaceCharactersInRange:NSMakeRange(0, [replaceContent length]) withString:@"•\t"];
        bulletIndent = indentLevel * indentSize;
        hangingTextIndent = (indentLevel + 1) * indentSize;
        [par setTabStops:@[
          [[NSTextTab alloc] initWithType:NSLeftTabStopType location:0],
          [[NSTextTab alloc] initWithType:NSLeftTabStopType location:hangingTextIndent]
        ]];
        [par setFirstLineHeadIndent:bulletIndent];
        [par setHeadIndent:hangingTextIndent];
        [replaceContent addAttribute:NSParagraphStyleAttributeName value:par range:NSMakeRange(0, [replaceContent length])];

       // replace the marked up version in the original string with out formatted one
        [output replaceCharactersInRange:replaceRange
                    withAttributedString:replaceContent];

       // optimization: increment the cursor to end of replaced content in output string
        cursor = NSMaxRange(replaceRange) - 1;
    }
}

+ (void)markupOrderedList:(const NSMutableAttributedString *)output
{
    OnigRegexp *expression = orderedListExpression;
    OnigResult *result;
    NSString *matchedMarkup;
    uint indentLevel;
    NSRange replaceRange;
    NSMutableAttributedString *replaceContent;
    int cursor = 0;
    float indentSize = 15.f;
    float hangingTextIndent;
    float bulletIndent;
    NSMutableDictionary *itemIndexes = [[NSMutableDictionary alloc] init];
    itemIndexes[@(0)] = @(0);
    itemIndexes[@(1)] = @(0);
    itemIndexes[@(2)] = @(0);
    itemIndexes[@(3)] = @(0);
    itemIndexes[@(4)] = @(0);
    NSMutableParagraphStyle *par;
    NSRange effectiveRange;

    while ((result = [expression search:[output string] start:cursor])) {
        // get the matched markup
        matchedMarkup = [result stringForName:@"markup"];

        // calc. the indent level (length minus any space)
        indentLevel = [[matchedMarkup stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] - 1;

        // get the range of the entrie match (including the markup)
        replaceRange = [result bodyRange];

        // reset counter if we are preceeded by a newline


        // increment level counter
        itemIndexes[@(indentLevel)] = @([itemIndexes[@(indentLevel)] integerValue] + 1);

        // reset sub ranges to 0
        for (uint i = 5; i > indentLevel; i--) {
            itemIndexes[@(i)] = @(0);
        }

        // prepare the replacement
        replaceContent = [[output attributedSubstringFromRange:replaceRange] mutableCopy];
        par = [(NSDictionary *)[replaceContent attribute:NSParagraphStyleAttributeName
                                                 atIndex:0
                                   longestEffectiveRange:&effectiveRange
                                                 inRange:NSMakeRange(0, [replaceContent length])] mutableCopy];
        [replaceContent replaceCharactersInRange:NSMakeRange(0, [replaceContent length]) withString:[[NSString alloc] initWithFormat:@"%li.\t", [itemIndexes[@(indentLevel)] integerValue]]];
        bulletIndent = indentLevel * indentSize;
        hangingTextIndent = (indentLevel + 1) * indentSize;
        [par setTabStops:@[
         [[NSTextTab alloc] initWithType:NSLeftTabStopType location:0],
         //[[NSTextTab alloc] initWithType:NSLeftTabStopType location:bulletIndent + 10],
         [[NSTextTab alloc] initWithType:NSLeftTabStopType location:hangingTextIndent]
         ]];
        [par setFirstLineHeadIndent:bulletIndent];
        [par setHeadIndent:hangingTextIndent];
        [replaceContent addAttribute:NSParagraphStyleAttributeName value:par range:NSMakeRange(0, [replaceContent length])];

        // replace the marked up version in the original string with out formatted one
        [output replaceCharactersInRange:replaceRange
                    withAttributedString:replaceContent];

        // optimization: increment the cursor to end of replaced content in output string
        cursor = NSMaxRange(replaceRange) - 1;
    }
}

+ (void)markupPhrase:(const NSMutableAttributedString *)output
      withExpression:(const OnigRegexp *)expression
        andFormatter:(const void (^)(NSMutableAttributedString *))formatter
{
    OnigResult *result;
    NSString *matchedContent;
    NSRange replaceRange;
    NSMutableAttributedString *replaceContent;
    int markupOpenGroupIndex, markupCloseGroupIndex;
    NSRange markupOpenRange, markupCloseRange;
    int cursor = 0;

    while ((result = [expression search:[output string] start:cursor])) {
        // get the content (without markup)
        matchedContent = [result stringForName:@"content"];

        // get the range of the entire match (including markup)
        replaceRange = [result bodyRange];

        // extract matched content from original string (copies existing attributes)
        replaceContent = [[output attributedSubstringFromRange:replaceRange] mutableCopy];

        // remove opening markup
        markupOpenGroupIndex = [result indexForName:@"markup-open"];
        markupOpenRange = [result rangeAt:markupOpenGroupIndex];
        markupOpenRange.location -= replaceRange.location;
        [replaceContent deleteCharactersInRange:markupOpenRange];

        // remove closing markup
        markupCloseGroupIndex = [result indexForName:@"markup-close"];
        markupCloseRange = [result rangeAt:markupCloseGroupIndex];
        markupCloseRange.location -= replaceRange.location;
        markupCloseRange.location -= markupOpenRange.length; // calc for the fact we just removed opening markup
        [replaceContent deleteCharactersInRange:markupCloseRange];

        // apply the formatting
        (void) formatter(replaceContent);

        // replace the marked up version in the original string with out formatted one
        [output replaceCharactersInRange:replaceRange
                    withAttributedString:replaceContent];

        // optimization: increment the cursor to end of replaced content in output string
        cursor = NSMaxRange(replaceRange) - 1;
    }
}

+ (void)markup:(const NSMutableAttributedString *)output
{
    [self markupPhrase:output
        withExpression:boldExpression
          andFormatter:boldFormatter];

    [self markupPhrase:output
        withExpression:italicExpression
          andFormatter:italicFormatter];

    [self markupPhrase:output
        withExpression:superscriptExpression
          andFormatter:superscriptFormatter];

    [self markupPhrase:output
        withExpression:subscriptExpression
          andFormatter:subscriptFormatter];

    [self markupPhrase:output
        withExpression:strikethroughExpression
          andFormatter:strikethroughFormatter];

    [self markupPhrase:output
        withExpression:linkExpression
          andFormatter:linkFormatter];

    [self markupUnorderedList:output];
    [self markupOrderedList:output];
}
@end
