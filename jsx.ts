import parse from "./jsx-parse.js"

export { jsx as default }

// .bind(undefined, createElement)
function jsx(createElement, strings, ...inserts) {
	const id = crypto.getRandomValues(new Uint32Array(1))[0]
	const bigstring = inserts
		.flatMap((insert, i) => [strings[i], `PLACEHOLDER[${id}][${i}]`])
		.concat([strings.at(-1)])
		.join("")

	return parse(bigstring, { createElement, id, inserts })
}
