These files should be concatenated together (order doesn't matter, as long as `.pegjs` is first) by the `makefile`

## Polyfills

This parser requires the `Function.isConstructable()` and `Function.isCallable()` functions to be polyfilled in the global scope. You can get an [implementation of these functions from zloirock/core-js](https://github.com/zloirock/core-js#function-iscallable-isconstructor-).
