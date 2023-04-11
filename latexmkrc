@default_files = ('main');

$pdf_mode = 1;
$bibtex_use = 2;
$recorder = 1;
$preview_continuous_mode = 1;
$clean_ext = "synctex.gz acn acr alg aux bbl bcf blg brf fdb_latexmk glg glo gls idx ilg ind lof log lot out run.xml toc pdf thm toe ist idx";
$pdflatex = "xelatex -file-line-error -halt-on-error -src-specials -synctex=1 %O %S";