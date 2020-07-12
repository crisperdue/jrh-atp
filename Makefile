# List of ML files to compile as a library. This leaves out the following
# which are probably not much use:
#
# sigma.ml       (Sigma-formulas and evaluator-by-proof)
# turing.ml      (OCaml implementation of Turing machines)
# undecidable.ml (Proofs related to undecidability results)
# bhk.ml         (Trivial instance of BHK interpretation)
# many.ml        (Example relevant to many-sorted logic)
# hol.ml         (Simple higher order logic setup)

# Compiler commands.
# Compile without deprecation warnings (-w -3).
#
OCC = ocamlfind ocamlc -w -3
OCCOPT = ocamlfind ocamlopt -w -3

# Most of the source files.  The non-interactive parts of
# these files get concatenated into atp_interactive.ml.
#
MLFILES = initialization.ml lib.ml intro.ml \
          formulas.ml prop.ml propexamples.ml           \
          defcnf.ml dp.ml stal.ml bdd.ml fol.ml skolem.ml               \
          herbrand.ml unif.ml tableaux.ml resolution.ml prolog.ml       \
          meson.ml skolems.ml equal.ml cong.ml rewrite.ml               \
          order.ml completion.ml eqelim.ml                              \
          paramodulation.ml decidable.ml qelim.ml cooper.ml             \
          complex.ml real.ml grobner.ml geom.ml interpolation.ml        \
          combining.ml lcf.ml lcfprop.ml folderived.ml lcffol.ml        \
          tactics.ml limitations.ml

# The default is an interactive session ready to run examples.
# atp-top is a shell script that starts an OCaml top level with
# appropriate initializations.
#
atp-top: atp_batch.cmo printers.ml samples
	-true

# A bytecode executable that runs examples from example.ml (only)
#
example: example.ml atp_batch.cmo
	$(OCC) -pp "camlp5o ./Quotexpander.cmo" -o examples \
	  nums.cma atp_batch.cmo example.ml

# Alternatively, one with native code
#
example-opt: example.ml atp_batch.cmx
	$(OCCOPT) -pp "camlp5o ./Quotexpander.cmo" -o examples-opt \
	  nums.cmxa atp_batch.cmx example.ml

# The object files containing all functionality, but no
# interactive examples.
#
atp_batch.cmx: Quotexpander.cmo atp_batch.ml
	$(OCCOPT) -pp "camlp5o ./Quotexpander.cmo" -w ax -c atp_batch.ml

atp_batch.cmo: Quotexpander.cmo atp_batch.ml
	$(OCC) -pp "camlp5o ./Quotexpander.cmo" -w ax -c atp_batch.ml

# Files of just interactive examples from MLFILES, all in
# the samples/ subdirectory.
#
samples: $(MLFILES)
	for f in $(MLFILES); do echo ./mk-samples $$f; done

# A file to #use to install all printers from the MLFILES
#
printers.ml: $(MLFILES)
	grep '#install_printer' $(MLFILES) >printers.ml

# The camlp5 quotation expander
#
Quotexpander.cmo: Quotexpander.ml
	$(OCC) -package camlp5 -c Quotexpander.ml


# Concatenated MLFILES are here, with interactive examples removed,
# but with printers installed.  To load into a top level.
#
atp_interactive.ml: $(MLFILES); ./Mk_ml_file $(MLFILES) >atp_interactive.ml

# Like atp_interactive, but no printers installed.
#
atp_batch.ml: $(MLFILES)
	./Mk_ml_file $(MLFILES) | grep -v install_printer >atp_batch.ml

# Clean up
#
clean:
	-rm -f atp_batch.cma atp_batch.cmi atp_batch.cmo atp_batch.cmx \
	  atp_batch.o atp_batch.ml \
	  example example.exe example_opt example-opt.exe \
	  example.cmi example.cmo example.cmx example.o \
	  Quotexpander.cmo Quotexpander.cmi \
	  atp_interactive.ml
