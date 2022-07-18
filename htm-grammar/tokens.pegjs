/**
 * Collection of tokens I didn't know where to put
 *
 * All of these tokens use the '$' modified to capture the raw text that was matched,
 * not an array/list of characters.
 */

/** HTML tag stuff */
TAG_OPEN_START = $"<"
TAG_OPEN_END = $">"
TAG_OPEN_END_VOID = $"/>"
TAG_CLOSE_START = "</"
TAG_CLOSE_END = ">"
// Not all-encompasing, but good enough
TAG_LOCALNAME = $[a-zA-Z0-9_\-]+

/** HTML attribute stuff */
// This doesn't cover everything, but it's good enough
ATTR_NAME = $[a-zA-Z0-9_\-]+
// IDK if this is more or less permissive than the actual HTML spec?
ATTR_VALUE_UNQUOTED = $[a-zA-Z0-9!@#$%^&*()\-=_+:;,./?\[\]{}\\|]+

/** Well-known character literals */
DOUBLE_QUOTE = $'"'
SINGLE_QUOTE = $"'"
EQUAL_SIGN = $"="

/** Whitespace stuff */
WHITESPACE = $[ \t\r\n]
OPTIONAL_WHITESPACE = $[ \t\r\n]*
MANDATORY_WHITESPACE = $[ \t\r\n]+

/** Literal tokens */
TRUE = $("true" / "TRUE")
FALSE = $("false" / "FALSE")
DIGIT = $[0-9]
ZERO = $"0"
NON_ZERO = $[1-9]
UINT = $((NON_ZERO DIGIT*) / ZERO)
