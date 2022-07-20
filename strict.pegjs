{{
    import StringRegistry from "./string-registry.js" // Not in TS-world anymore
    // Need 'Array.isTemplateObject()' to determine string trust (only construct trusted JSX)
    // Ref: https://github.com/tc39/proposal-array-is-template-object#an-example
    import "npm:core-js/proposals/array-is-template-object"
}}

{
    // Input is originally the args of whatever was passed (NON-string-ified). In this case, that is a tagged template arg package
    const [strings, ...inserts] = input
    // Input MUST be from a trusted template string!
    if (!Array.isTemplateObject(strings)) {
        throw new TypeError("Expected template object")
    }

    // This holds the ID keys that will be used for 'PLACEHOLDER[${id}]' strings in parsing
    const ids = new StringRegistry()
    // Convert inserts into ID strings that are like pointers to the 'StringRegistry'-hidden value
    const placeholders = inserts.map((insert) => ids.for(insert))
    // Interleave the two arrays. The 'placeholders' array is 1 element shorter than 'strings' since it is "between" each string pair
    const monostring = strings.flatMap((string, i) => i < placeholders.length ? [string, placeholders[i]] : [string]).join("")
    
    // Reset the input to this "safe string" to parse
    input = monostring

    // Extract some vital properties that must be in-scope for construction of the resulting object
    const { createElement } = options

    // This should be an auto-coercion in PEGgy.js, but it's not
    input = String(input)
}

START
    = __ $:Element __
    { return $ }

Insert
    = "PLACEHOLDER" "[" id2:Int "]" "[" i:Int "]"
    & { return id2 === id }
    { return inserts[i] }

Element
    = VoidElement / ContentElement
VoidElement
    = "<" Tag:TagName props:(_ @Attrs)? __ "/>"
    { return createElement(Tag, props) }
ContentElement
    = "<" Tag:TagName props:(_ @Attrs)? ">" children:Child* "</" Close:TagName __ ">"
    &{ return Tag === Close }
    { return createElement(Tag, props, ...children) }
TagName
    = Insert / TAG_NAME

Child
    = Element / Insert / ChildText
ChildText
	// Stop on end of parent, or beginning of other child
    = $(!(("</" Close:TagName __ ">") / Element / Insert) .)+

/**
 * This matches an attribute list. That's it.
 * - It does NOT check that there is a prepending mandatory whitespace character
 * - It DOES match a zero-length attribute list
 * - It DOES eat optional whitespace on both ends
 */
Attrs
    = __ rest:(@Attr ___)* last:Attr? spread:Insert? __
    { return Object.assign({}, ...rest, last, spread) }

Attr
    = ValueAttr

ValueAttr
    = name:ATTR_NAME "=" value:AttrValue
    { return { [name]: value } }

AttrValue
    = Insert / QuotedString

QuotedString
    = DoubleQuotedString / SingleQuotedString
DoubleQuotedString
    = '"' (!'"' .)* '"'
SingleQuotedString
    = "'" (!"'" .)* "'"
Int
    = text:$("0" / ([1-9] [0-9]*))
    &{ return Number.isSafeInteger(Number(text)) }
    { return Number(text) }

// This MUST NEVER swallow the "/", otherwise 'VoidElement' won't work!
ATTR_NAME = $[a-zA-Z0-9_\-]+
TAG_NAME = $[a-zA-Z0-9_\-]+

// Single
_ = $[ \t\r\n]
// Optional
__ = $[ \t\r\n]*
// Required
___ = $[ \t\r\n]+
