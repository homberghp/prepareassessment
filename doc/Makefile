CSSDIR=css
IMAGESDIR=images

index.html: *.adoc
	asciidoctor -o index.html -b html5 -a linkcss -a imagesdir=$(IMAGESDIR) -a stylesdir=$(CSSDIR) -a stylesheet=asciidoctor.css  USING.adoc
