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
	// Accept whitespace (no need for pre-dedent)
    = _* @Element _*

Insert
    // 'key' matches the default format generation of 'StringRegistry'
    = "PLACEHOLDER" "[" key:KEY "]"
    // Skip if not actually a valid one. User might be trying to guess one?
    &{ return inserts.has(key) }
    // Return as a raw value. Can be checked or wrapped at the rule level, not here.
    { return inserts.get(key) }
KEY = $([a-z0-9] [a-z0-9] [a-z0-9] [a-z0-9] [a-z0-9] [a-z0-9] [a-z0-9] [a-z0-9] /* 8x */)

Element
    = VoidElement / (CustomElement / BuiltinElement)
VoidElement
    = "<" Tag:(Insert / TAG_NAME) props:(_ @Attrs)? _* "/>"
    { return createElement(Tag, props) }
CustomElement
    = "<" Tag:Insert props:(_+ @Attrs)? _* ">" children:Child* "</" Close:Insert _* ">"
    &{ return Tag === Close }
    { return createElement(Tag, props, ...children) }
BuiltinElement
    = "<" tag:TAG_NAME props:(_+ @Attrs)? _* ">" children:Child* "</" close:TAG_NAME _* ">"
    &{ return tag === close }
    { return createElement(tag, props, ...children) }

// https://www.typescriptlang.org/play?#code/DwBwfAEgpgNjD2ACYBDMB3eAnGATAhMAPRrHgCwAUEA
// https://www.typescriptlang.org/play?#code/DwBwfAEgpgNjD2BYAUMAhmA7vATjAJgITAD0Gp4KQA
Child
    = NWS? @(Insert / Element / ChildText) NWS?
NWS = $(_* (NL _*)+)
// This is effectively the inverse of wherever 'ChildText' appears. It MUST include any potential termination
// matcher since PEG grammars don't have non-greedy operators like '.*?' in regex.
CHILD_TEXT_STOP
    = $(NWS / ("</" (Insert / TAG_NAME) _* ">") / (NWS? (Insert / Element) NWS?))
ChildText
    = chars:(!(CHILD_TEXT_STOP) @((@_ _*) / .))+
    { return chars.join("") }

Attrs
    = first:(Insert / Attr) rest:(_+ @(Insert / Attr))*
    { return Object.assign({}, first, ...rest) }

Attr
    = ValueAttr / PresentAttr

ValueAttr
    = name:ATTR_NAME "=" value:AttrValue
    { return { [name]: value } }

PresentAttr
    = name:ATTR_NAME
    { return { [name]: true } }

AttrValue
    = Insert / QuotedString

QuotedString
    = DoubleQuotedString / SingleQuotedString
DoubleQuotedString
    = '"' @$(!'"' .)* '"'
SingleQuotedString
    = "'" @$(!"'" .)* "'"

TAG_NAME = $[a-zA-Z0-9_\-:]+
// This MUST NEVER swallow the "/", otherwise 'VoidElement' won't work!
ATTR_NAME = $[a-zA-Z0-9_\-]+

NL = $("\r"? "\n")
_ = $[ \t\r\n]
