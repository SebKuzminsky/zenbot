README.html: README.md
	markdown2 $^ >| $@
