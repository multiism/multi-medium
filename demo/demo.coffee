
# header = document.createElement "h1"
# document.body.appendChild header
# header.appendChild new MultiMedium "MultiMedium"

# p = document.createElement "p"
# document.body.appendChild p
# p.appendChild new MultiMedium "MultiMedium is the future of handwriting."

for element in document.querySelectorAll "h1, h2, h3, h4, h5, h6, p"
	text = element.innerText
	element.innerHTML = ""
	element.appendChild new MultiMedium text

# document.body.appendChild new MultiMedium.Input
