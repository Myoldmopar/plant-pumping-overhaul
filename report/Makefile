filename=main
args="-interaction=nonstopmode "

pdf:
	pdflatex ${args} ${filename}
	bibtex ${filename}||true
	pdflatex ${args} ${filename}
	pdflatex ${args} ${filename}

clean:
	rm -f ${filename}.{ps,pdf,log,aux,out,dvi,bbl,blg}
	rm -f media/*.png

.PHONY:
	pdf