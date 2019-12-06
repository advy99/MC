HOME = .
BIN = $(HOME)/bin
DATOS = $(HOME)/datos
OBJ = $(HOME)/obj
SRC = $(HOME)/src

all: compila ejecuta

compila: $(SRC)/practica2.l
	flex++ -o $(OBJ)/lex.yy.cc $<
	g++ $(OBJ)/lex.yy.cc -o $(BIN)/prog


ejecuta:
	$(BIN)/prog $(DATOS)/entrada.cc

clean:
	-rm $(BIN)/*
	-rm $(OBJ)/*
