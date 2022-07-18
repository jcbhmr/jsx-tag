__Start
    = $:Element
    { return $ }

/**
 * This entire grammar gets wrapped in a function that gets re-called each time the user calls
 * the 'jsx()' function. Each time, it passes the 'inserts' array (the '${var}' inserts) and the
 * current UUID of the execution. Why a UUID per-execution? So that you never get the "oh I had
 * the text 'PLACEHOLDER[4]' in my string that got passed in, and now things are breaking?"
 *
 * The props are wrapped in an object so that the names don't collide
 */
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
    = tag:(Insert / TAG_NAME) __
    { return tag }

Child
    = Element / Insert / Text
Text
    = $.+

/**
 * This matches an attribute list. That's it.
 * - It does NOT check that there is a prepending mandatory whitespace character (see 'element.pegjs')
 * - It DOES match a zero-length attribute list
 * - It DOES eat optional whitespace on both ends
 *
 * We don't return an AST of stuff to deal with at a higher level, instead, we return a closure so that all
 * the attribute application logic is RIGHT HERE and not in the 'element.pegjs' file.
 */
Attrs
    = __ (rest:(attr:Attr ___ { return attr }))* spread:Insert __
    { return Object.assign({}, ...rest, last, spread) }

Attr
    = ValueAttr

ValueAttr
    = name:ATTR_NAME "=" value:AttrValue
    { return { [name]: value } }

AttrValue
    = Insert / QuotedString

// This MUST NEVER swallow the "/", otherwise 'VoidElement' won't work!
ATTR_NAME = $[a-zA-Z0-9_\-]+

// Single
_ = $[ \t\r\n]
// Optional
__ = $[ \t\r\n]*
// Required
___ = $[ \t\r\n]+
