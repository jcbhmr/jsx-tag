import BiMap from "npm:@jcbhmr/bimap"

export { StringRegistry as default }

/**
 * Inspired by the global 'Symbol' registry, this class allows a user to instantiate and map
 * a bunch of arbitrary JS values to safe plain strings! This means you can display them, print them,
 * share them, all without actually passing an object around. This is useful for embedding references
 * into other strings. For instance, parsing a tagged template string!
 * 
 * Just as 'Symbol.for()' returns a 'Symbol', 'StringRegistry::for()' returns a 'String' primitive. And
 * just as 'Symbol.keyFor()' returns a 'String', StringRegistry::keyFor()' returns 'T'
 * 
 * 'for()' is to put in, and 'keyFor()' is to get out
 * 
 * Usually, you call 'StringRegistry::for()' on a bunch of unknown objects, then use the resulting string
 * keys in whatever output format you wish. Later, you can retrieve the original objects by using
 * 'StringRegistry::keyFor()' to get the object key pointing to this string identifier.
 */
class StringRegistry<T> {
    #map = new BiMap()
    #generateId
    constructor(generateId: GenerateId<T> = generateIdDefault) {
        this.#generateId = generateId
    }

    keyFor(id: string) {
        return this.#map.get(id)
    }
    for(thing: T) {
        if (this.#map.hasValue(thing)) {
            return this.#map.getKey(thing)
        } else {
            const id = this.#generateId(thing)
            this.#map.set(id, thing)
            return id
        }
    }
}

// Generate type from default implementation
type GenerateId = typeof generateIdDefault
/** Generates a random ID of length 8 */
function generateIdDefault<T>(thing: T) {
    return Math.random().toString(36).slice(2, 6).padStart(4, "0")
        + Math.random().toString(36).slice(2, 6).padStart(4, "0")
}
