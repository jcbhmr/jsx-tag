{
    const { createElement, id, inserts } = options
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
