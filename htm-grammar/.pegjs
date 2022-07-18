/**
 * @param createElement
 * @param id
 * @param inserts
 */
{{
    if (true) {
        var createElement = Array.of
        var id = 45
        var inserts = ["attr", "text"]
        // <p data-test=PLACEHOLDER[45][0]>PLACEHOLDER[45][1]</p>
    }
}}

__Start
    = $:Element
    { return $ }

Insert
    = "PLACEHOLDER" "[" id2:Int "]" "[" i:Int "]"
    & { return id2 === id }
    { return inserts[i] }

Element
    = VoidElement / ContentElement
VoidElement
    = "<" Tag:TagName _ props:Attrs "/>"
    { return createElement(Tag, props) }
ContentElement
    = "<" Tag:TagName _ props:Attrs ">" children:Child* "</" Close:TagName ">"
    &{ return Tag === Close }
    { return createElement(Tag, props, ...children) }
TagName
    = Insert / TAG_NAME

Child
    = Element / Insert / Text
Text
    = $(!"<" .)+

/**
 * This matches an attribute list. That's it.
 * - It does NOT check that there is a prepending mandatory whitespace character (see 'element.pegjs')
 * - It DOES match a zero-length attribute list
 * - It DOES eat optional whitespace on both ends
 */
Attrs
    = __ rest:(attr:Attr ___ { return attr })* last:Attr? spread:Insert? __
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
