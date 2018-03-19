
# ![MultiMedium](rough-logo.png)

A new version of the handwriting medium, for the web.

Write more personally, while still supporting selection, copy and paste, and screen reader accessibility.
(If you want the aural form of your content to be personal, record it! It would also be cool to be able to line that up with the text easily.)

[See a demo.](http://multiism.github.io/multi-medium/)
Hm, the words seem to be really close together, needs some word spacing.

[See this page on my website for some "styled" text.](http://isaiahodhner.ml/make-making-better)

## TODO

* Undo/redo buttons for mobile
* A way to clear or reset individual words
* For some reason the save button seemed to export only changed words, so I ended up putting two `setData` calls in `demo.coffee`; I've since replaced it, but, idk, it should probably be investigated
* Reconciliation with updated text, probably need some GUIDs or similar IDs for words and/or to include the text of the words that they're replacing
	* (can improve the diff/patch-ability at the same time by putting words on multiple lines; and probably have the key on a separate line from the data too as anchoring points for the whatever SCM diff algorithm)
* Better serialization format, especially since CoffeeScript gives a maximum callstack error trying to parse the data I have in `demo.coffee` currently; I had to wrap it in a `JSON.parse` call; it should really be a lot more compact than JSON, and shouldn't rely on the language the API is called from so much (serializing to nested JS data structures; it should just be a string instead)
* You should be able to save without changing anything; currently the Save option only pops up if you change something and you have to rewrite at least one word when changing something
* Diffs?
* Record longer words
	* A metaphorical hyphen gesture
	* Or automatically give your room when you near the edge
	* Shift the word off left with an animation (and continue showing part of it)
* Next word button for handwriting conversion (writing out existing text)
* Freewriting mode (handwriting new words, as opposed to handwriting out existing text)
* Drag recording area around with a handle
* Establish API boundaries
* jQuery-plugin-like API
	* And actual jQuery plugin, why not (but no dependency)
* Publish to npm
* Scalable graphics (could be SVG or canvas scaled by `devicePixelRatio`)
* Optimize, probably have a single canvas in the DOM, and use WebGL to render text
* Fix triple-clicking a paragraph to select it
* Hide text underneath canvases when selecting? Or hide canvases? Probably hide canvases.
* Support other languages
* Replace lorem ipsum on the demo
