/**
 * This defines the attributes grammar to match against strings like the following examples (unquoted):
 * hello=world
 * hello="world"
 * hello=${var}
 * hello=true
 * hello=null
 * ...${obj}
 *
 * Tokens relating to attributes (name, raw value, etc.) are defined at the bottom of this file
 */

/**
 * This matches an attribute list. That's it.
 * - It does NOT check that there is a prepending mandatory whitespace character (see 'element.pegjs')
 * - It DOES match a zero-length attribute list
 * - It DOES eat optional whitespace on both ends
 *
 * We don't return an AST of stuff to deal with at a higher level, instead, we return a closure so that all
 * the attribute application logic is RIGHT HERE and not in the 'element.pegjs' file.
 */
// This is a lot of nested expressions...
Attrs
    // The repetition is needed so that its a list of 'Attr's joined by 'MANDATORY_WHITESPACE's. This is just
    // how you have to write it: '(THING SEP)* THING?'. When there is only 1 item, it matches the last
    // 'THING?' and none of the 0-N of the rest. When there is two, it must match 'THING SEP THING', and
    // when three, it must match 'THING SEP THING SEP THING', and so on. That's why this is the way it is.
    = OPTIONAL_WHITESPACE (rest:(attr:Attr { return attr }) MANDATORY_WHITESPACE)* last:Attr? OPTIONAL_WHITESPACE
    {
        // 🎗️ REMINDER: 'last' is either 'undefined' (PEG didn't match) or a pre-made closure to apply a single
        // attribute. 'rest' is an array of the same stuff. It's not user defined (so it can't be intentionally
        // null) so we are a-OK to check that here.
        if (last != null) {
            var all = rest.concat([last])
        } else {
            var all = rest
        }
        // Return a closure that will be called with the 'Element' instance (the actual DOM node) AFTER initial
        // creation, but BEFORE children get added.
        return (element) => {
            // These are all mutator functions that each apply a SINGLE attribute. See later in this file for
            // attribute application rules.
            for (const apply of all) {
                apply(element)
            }
        }
    }

Attr
    // Having 'SpreadAttrs' here ONLY WORKS because we delegate work to a callback/closure function, not returning
    // a single '{ name, value }' object pair. This allows us more freedom to apply ANY NUMBER of attributes at a
    // time in a single function!
    = ValueAttr / PresentAttr / SpreadAttrs

{{
    /**
     * Centralized logic for applying an attribute value
     *
     * Does NOT apply default values to 'value'. Make sure that 'PresentAttr' calls this function with 'true'!
     * 💡 TIP: Use '.bind()' for the callback generation! It's puposefully got 'element' as the last param 😉.
     */
    function applyAttr(name, value) {
        // TODO: Handle 'on*' convention events
        if (name in element) {
            element[name] = value
        } else {
            element.setAttribute(name, value)
        }
    }
}}

ValueAttr
    = name:ATTR_NAME "=" value:AttrValue
    { return applyAttr.bind(undefined, name, value) }

PresentAttr
    = name:ATTR_NAME
    { return applyAttr.bind(undefined, name, true) }

SpreadAttrs
    = "..." spread:Insert
    {
        return (element) => {
            for (const [name, value] of Object.entries(spread)) {
                applyAttr(name, value, element)
            }
        }
    }


// TODO: Is this 'ATTR_NAME' complete? Is it HTML-spec-like? Should it have more stuff like ":"?
ATTR_NAME = $[a-zA-Z0-9_\-]+
// TODO: Is 'ATTR_VALUE_RAW' over-inclusive? What does the HTML spec look like?
ATTR_VALUE_RAW = $[a-zA-Z0-9!@#$%^&*()\-=_+:;,./?\[\]{}\\|]+
