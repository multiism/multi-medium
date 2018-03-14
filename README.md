
# <span style="font-family: 'Seoge Print', 'Seoge Script', 'Seoge', cursive">MultiMedium</span>

A new version of the handwriting medium, for the web.

Write more personally, while still supporting selection, copy and paste, and screen reader accessibility.
(If you want the aural form of your content to be personal, record it! It would also be cool to be able to line that up with the text easily.)

[See a demo.](http://multiism.github.io/multi-medium/)
Hm, the words seem to be really close together, needs some word spacing.

[See this page on my website for some "styled" text.](http://website-a1j01.c9users.io/make-making-better)

## TODO

* Undo/redo buttons for mobile
* A way to clear or reset individual words
* For some reason the save button exported only changed words, so now I have two `setData` calls in `demo.coffee`; this *works*, but 
* You should be able to save without changing anything (especially because of that just-described problem); currently it only pops up if you change something and you can only change something by rewriting at least one word
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
