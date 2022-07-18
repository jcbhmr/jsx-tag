{
	Function.isConstructable = (Class) => {
    	if (!(typeof Class === "function")) {
        	return false
        }
        
        try {
        	Reflect.construct(Object, [], Class)
        } catch {
        	return false
        }
        return true
    }
    Function.isCallable = (f) => {
    	if (!(typeof f === "function")) {
        	return false
        }
        
        if (Function.prototype.toString.call(f).startsWith("class")) {
            return false
        }
        return true
    }
    
    function applyAttributes(element, attributes) {
    	for (const [name, value] of Object.entries(attributes)) {
        	if (name in element) {
            	element[name] = value
            } else {
            	if (typeof value === "boolean" || value instanceof Boolean) {
                	if (value) {
                    	element.setAttribute(name, "")
                    }
                } else {
                	element.setAttribute(name, value)
                }
            }
        }
    }
    
    const ID = 45
	const inserts = [() => "gamer", "Hello world!", "Content!!"]
}

//__Start = $:Top { console.log($); return new XMLSerializer().serializeToString($) }
__Start = $:Top { console.log($); return new XMLSerializer().serializeToString($) }

Top = __ childNodes:Node* __ { let content = new DocumentFragment(); content.replaceChildren(...childNodes); return content }

Node = Element / Insert / Text
PlainElementNode = Element / Insert / PlainElementText
CustomElementNode = Element / Insert / CustomElementText
Element = PlainElement / CustomElement

PlainElement = PlainVoidElement / PlainContentElement
PlainVoidElement = PlainTagVoid
PlainContentElement = tag:PlainTagOpen childNodes:PlainElementNode* tagClose:PlainTagClose &{ return tagClose === null || tag === tagClose } { tag.replaceChildren(...childNodes); return tag }
PlainTagVoid = TAG_START tag:TAG_NAME attrs:(_ attrs:AttrsCollec { return attrs })? __ SLASH TAG_END { let element = document.createElement(tag); applyAttributes(element, attrs ?? {}); return element }
PlainTagOpen = TAG_START tag:TAG_NAME attrs:(_ attrs:AttrsCollec { return attrs })? __ TAG_END { let element = document.createElement(tag); applyAttributes(element, attrs ?? {}); return element }
PlainTagClose = tag:(TAG_START SLASH tag:TAG_NAME __ TAG_END { return tag }) { return tag } / AnonTagClose { return null }

CustomElement = CustomVoidElement / CustomContentElement
CustomVoidElement = CustomTagVoid
CustomContentElement = CustomTagOpen childNodes:CustomElementNode* CustomTagClose
CustomTagVoid = TAG_START f:Insert (_ AttrsCollec)? __ SLASH TAG_END
CustomTagOpen = TAG_START f:Insert (_ AttrsCollec)? __ TAG_END
CustomTagClose = (TAG_START SLASH Insert __ TAG_END) / AnonTagClose

AnonTagClose = TAG_START SLASH __ TAG_END

AttrsCollec = (attrs:(attr:Attr __ _ { return attr })* attr:Attr { return { ...attrs, ...attr } }) / (attrs:(attr:Attr __ _ { return attr })* spread:AttrSpread { return { ...attrs, ...spread } })
Attr = AttrPair / AttrSolo
AttrPair = name:ATTR_NAME EQ value:AttrVal { return { [name]: value } }
AttrSolo = name:ATTR_NAME { return { [name]: true } }
AttrVal = Insert / Bool / QString / ATTR_VAL_RAW
AttrSpread = "..." insert:Insert { return Object(insert) }

// Inverse of Node, since Text is greedy and needs a lookahead
Text = PlainElementText / CustomElementText
PlainElementText = text:$(!(PlainTagClose / Element / Insert) .)+ { return new Text(text) }
CustomElementText = text:$(!(CustomTagClose / Element / Insert) .)+ { return new Text(text) }

Insert = "PLACEHOLDER" "[" id:Int "]" "[" index:Int "]" &{ return id === ID && 0 <= index && index < inserts.length } { return inserts[index] }

Int = text:$("0" / ([1-9] [0-9]*)) &{ return Number.isSafeInteger(Number(text)) } { return Number(text) }
Bool = True / False
True = TRUE { return true }
False = FALSE { return false }
QString = DqString / SqString
DqString = DQ text:$(!DQ .)* DQ { return text }
SqString = SQ text:$(!SQ .)* SQ { return text }

TAG_START = $"<"
TAG_END = $">"
SLASH = $"/"
DQ = $'"'
SQ = $"'"
EQ = $"="
TRUE = $("true" / "TRUE")
FALSE = $("false" / "FALSE")
TAG_NAME = $[a-zA-Z0-9_\-]+
ATTR_NAME = $[a-zA-Z0-9_\-]+
ATTR_VAL_RAW = $[a-zA-Z0-9!@#$%^&*()\-=_+:;,./?\[\]{}\\|]+
_ = $[ \t\r\n]
__ = $[ \t\r\n]*
