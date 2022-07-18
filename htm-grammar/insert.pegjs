/**
 * This entire grammar gets wrapped in a function that gets re-called each time the user calls
 * the 'htm()' function. Each time, it passes the 'inserts' array (the '${var}' inserts) and the
 * current UUID of the execution. Why a UUID per-execution? So that you never get the "oh I had
 * the text 'PLACEHOLDER[4]' in my string that got passed in, and now things are breaking?"
 *
 * The props are wrapped in an object so that the names don't collide
 */
Insert
    = "PLACEHOLDER" "[" id:Int "]" "[" i:Int "]"
    & { return id === execution.id }
    { return execution.inserts[i] }
