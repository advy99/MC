%option noyywrap
%option yylineno

%{
#include <iostream>
#include <fstream>
#include <vector>

using namespace std;

ifstream fichero;

int ordenes_preprocesador;
int num_defines;
vector<pair<string, int> > includes;
vector<pair<string, int> > comentarios_linea;

vector<pair<string, int> > comentarios_bloque;

%}


%%



^"#" {ordenes_preprocesador++;}
^"#include "[<"][a-zA-Z.a-zA-Z]*[>"] {ordenes_preprocesador++; string frase(YYText()); includes.push_back(make_pair( frase.substr(9, frase.size()-1), lineno() )  );}
^"#define" {num_defines++; ordenes_preprocesador++;}

"//".*	{string comentario(YYText()); comentarios_linea.push_back(make_pair(comentario, lineno()));}


"/*".*"*/"	{string comentario(YYText()); comentarios_bloque.push_back(make_pair(comentario, lineno()));}



. {}
\n {}

%%


int main(int argc, char ** argv){

	if (argc != 2){
		cout << "ERROR: Número invalido de parametros" << endl
			  << "\t Uso: ./" << argv[0] << " <fichero> " << endl;
		exit(1);
	}

	fichero.open(argv[1]);

	if (fichero.fail()){
		cout << "Error de lectura de " << argv[1] << endl;
		exit(2);
	}

	num_defines = ordenes_preprocesador = 0;

	yyFlexLexer flujo(&fichero, 0);
	flujo.yylex();


	cout << endl << endl;

	cout << "Numero de ordenes del preprocesador: " << ordenes_preprocesador << endl
		  << "Numero de defines: " << num_defines << endl
		  << "Numero de includes: " << includes.size() << endl
		  << "Numero de comentarios de linea:" << comentarios_linea.size() << endl
		  << "Numero de comentarios en bloque: " << comentarios_bloque.size() << endl;

	cout << endl << endl;


	cout << "Se han incluido los siguientes archivos: " << endl;

	for (auto it = includes.begin(); it != includes.end(); ++it){
		cout <<  "\tEn la linea " << (*it).second << " : " << (*it).first << endl;
	}



	cout << endl << endl << "Se han hecho los siguientes comentarios de linea: " << endl;

	for (auto it = comentarios_linea.begin(); it != comentarios_linea.end(); ++it){
		cout <<  "\tEn la linea " << (*it).second << " : " << (*it).first << endl;
	}

	cout << endl << endl << "Se han hecho los siguientes comentarios en bloque: " << endl;

	for (auto it = comentarios_bloque.begin(); it != comentarios_bloque.end(); ++it){
		cout <<  "\tEn la linea " << (*it).second << " : " << (*it).first << endl;
	}

	return 0;

}
