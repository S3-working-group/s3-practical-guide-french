
CONFIG=content/structure.yaml
GLOSSARY=content/glossary.yaml
SOURCE=content/src
TMPFOLDER=tmp
LOC=content/localization.po
PRJ=config/project.yaml
MKTPL=mdslides template

# get language specific parameters
include config/make-conf

define update-make-conf
# update the make conf file from translations
$(MKTPL) templates/make-conf config/make-conf $(LOC) $(PRJ)
endef

site:
	# build jekyll site
	$(update-make-conf)

	# build content files
	mdslides build jekyll $(CONFIG) $(SOURCE) docs/ --glossary=$(GLOSSARY) --template=content/website/_templates/index.md --section-index-template=content/website/_templates/pattern-index.md --introduction-template=content/website/_templates/introduction.md

	# split introduction into intro and concepts/principles
	awk '{print >out}; /<!-- split here -->/{out="tmp/docs/concepts-and-principles-content.md"}' out=tmp/docs/introduction-content.md docs/introduction.md
	$(MKTPL) templates/docs/introduction.md $(TMPFOLDER)/docs/intro_tmpl.md $(LOC) $(PRJ)
	cd $(TMPFOLDER)/docs; multimarkdown --to=mmd --output=../../docs/introduction.md intro_tmpl.md
	$(MKTPL) templates/docs/concepts-and-principles.md $(TMPFOLDER)/docs/concepts_tmpl.md $(LOC) $(PRJ)
	cd $(TMPFOLDER)/docs; multimarkdown --to=mmd --output=../../docs/concepts-and-principles.md concepts_tmpl.md
	
	# prepare templates
	$(MKTPL) templates/docs/_layouts/default.html docs/_layouts/default.html $(LOC) $(PRJ)
	$(MKTPL) templates/docs/_layouts/plain.html docs/_layouts/plain.html $(LOC) $(PRJ)
	$(MKTPL) templates/docs/_config.yml docs/_config.yml $(LOC) $(PRJ)
	$(MKTPL) templates/docs/CNAME docs/CNAME $(LOC) $(PRJ)
	$(MKTPL) content/website/_includes/footer.html docs/_includes/footer.html $(LOC) $(PRJ)
	cp templates/docs/map.md docs/map.md
	$(MKTPL)  templates/docs/pattern-map.html docs/_includes/pattern-map.html $(LOC) $(PRJ)
	cp content/website/_includes/header.html docs/_includes/header.html

	# build the site
	cd docs;jekyll build

epub:
	# render an ebook as epub
	$(update-make-conf)

	# render intro, chapters and appendix to separate md files
	mdslides build ebook $(CONFIG) $(SOURCE) $(TMPFOLDER)/ebook/ --glossary=$(GLOSSARY) --section-prefix="$(SECTIONPREFIX)"

	# prepare and copy template
	$(MKTPL) templates/epub--master.md $(TMPFOLDER)/ebook/epub--master.md $(LOC) $(PRJ)
	# transclude all to one file 
	cd $(TMPFOLDER)/ebook; multimarkdown --to=mmd --output=epub-compiled.md epub--master.md
	# render to epub
	cd $(TMPFOLDER)/ebook; pandoc epub-compiled.md -f markdown -t epub3 --toc --toc-depth=3 -s -o ../../$(TARGETFILE).epub

htmlbook:
	# render an ebook as html book
	$(update-make-conf)

	# create description
	multimarkdown --to=html --output=tmp/store-description.html content/src/introduction/s3-overview-supporter-edition.md

	# -- start copied section

	# render intro, chapters and appendix to separate md files
	mdslides build ebook content/structure-supporter-edition.yaml $(SOURCE) $(TMPFOLDER)/htmlbook/ --glossary=$(GLOSSARY) --section-prefix="$(SECTIONPREFIX)"

	# prepare and copy template
	$(MKTPL) templates/htmlbook--master.md $(TMPFOLDER)/htmlbook/htmlbook--master.md $(LOC) $(PRJ)
	# transclude all to one file 
	cd $(TMPFOLDER)/htmlbook; multimarkdown --to=html --output=book.html htmlbook--master.md
	rm $(TMPFOLDER)/htmlbook/*.md
	cp templates/epub.css $(TMPFOLDER)/htmlbook
	-rm supporter-edition.zip
	cd $(TMPFOLDER)/htmlbook; zip  -r ../../supporter-edition *

ebook:
	# render an ebook as pdf (via LaTEX)
	$(update-make-conf)
	
	# render intro, chapters and appendix to separate md files (but without sectionprefix!)
	mdslides build ebook $(CONFIG) $(SOURCE) $(TMPFOLDER)/ebook/ --glossary=$(GLOSSARY) --no-section-prefix

	# copy md and LaTEX templates
	$(MKTPL) templates/ebook--master.md $(TMPFOLDER)/ebook/ebook--master.md $(LOC) $(PRJ)
	$(MKTPL) config/ebook.tex $(TMPFOLDER)/ebook/ebook.tex $(LOC) $(PRJ)
	$(MKTPL) config/ebook-style.sty $(TMPFOLDER)/ebook/ebook-style.sty $(LOC) $(PRJ)

	# make an index
	mdslides index latex $(CONFIG) $(TMPFOLDER)/ebook/tmp-index.md
	# transclude all to one file
	cd $(TMPFOLDER)/ebook; multimarkdown --to=mmd --output=tmp-ebook-compiled.md ebook--master.md

	cd $(TMPFOLDER)/ebook; multimarkdown --to=latex --output=tmp-ebook-compiled.tex tmp-ebook-compiled.md
	cd $(TMPFOLDER)/ebook; latexmk -pdf -xelatex -silent ebook.tex 
	cd $(TMPFOLDER)/ebook; mv ebook.pdf ../../$(TARGETFILE).pdf
	
	# clean up
	cd $(TMPFOLDER)/ebook; latexmk -C

single:
	$(update-make-conf)

	$(MKTPL) templates/single-page--master.md $(TMPFOLDER)/ebook/single-page--master.md $(LOC) $(PRJ)

	# render intro, chapters and appendix to separate md files
	mdslides build ebook $(CONFIG) $(SOURCE) $(TMPFOLDER)/ebook/ --glossary=$(GLOSSARY)
	# transclude all to one file 
	cd $(TMPFOLDER)/ebook; multimarkdown --to=mmd --output=../../docs/all.md single-page--master.md

gitbook:
	mdslides build gitbook $(CONFIG) $(SOURCE) gitbook/ --glossary=$(GLOSSARY)

update:
	$(update-make-conf)

clean:
	# clean all generated content
	-rm -r docs/img
	-rm -r docs/_site
	-rm docs/*.md
	# take no risk here!
	-rm -r tmp

setup:
	# prepare temp folders and jekyll site
	$(update-make-conf)
	# prepare temp folders
	echo "this might produce error output if folders already exist"
	-mkdir -p $(TMPFOLDER)/ebook
	-mkdir -p $(TMPFOLDER)/htmlbook
	-mkdir -p $(TMPFOLDER)/web-out
	-mkdir -p $(TMPFOLDER)/docs
	-mkdir docs/_site
	# -mkdir gitbook
ifeq ("$(wildcard $(TMPFOLDER)/ebook/img)","")
	cd $(TMPFOLDER)/ebook; ln -s ../../img
endif 

	# images for htmlbook
ifneq ("$(wildcard $(TMPFOLDER)/htmlbook/img)","")
	# take no risk here!
	rm -r tmp/htmlbook/img
endif 
	cp -r img $(TMPFOLDER)/htmlbook/img


	# clean up and copy images do to docs folder
ifneq ("$(wildcard docs/img)","")
	rm -r docs/img
endif
	cp -r img docs/img
ifneq ("$(wildcard gitbook/img)","")
	# rm -r gitbook/img
endif
	# cp -r img gitbook/img
