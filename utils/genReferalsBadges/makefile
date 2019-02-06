.PHONY: clean

clean:
	rm -rf *.aux
	rm -rf *.dvi
	rm -rf *.log
	rm -rf *.out

%.tex: %.in texgenerator.bash modelo.tex
	./texgenerator.bash $< > $@

%.dvi: %.tex
	latex -interaction=nonstopmode $<

%.ps: %.dvi
	dvips -o $@ $<

%.pdf: %.ps
	ps2pdf $<

