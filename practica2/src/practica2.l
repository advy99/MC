%option noyywrap
%option yylineno

%{
#include <iostream>
#include <fstream>
#include <vector>
#include <stack>

using namespace std;

ifstream fichero;

int ordenes_preprocesador;
int num_defines;

pair<int, int> contar_parentesis = make_pair(0,0);

pair<int, int> contar_llaves = make_pair(0, 0);

vector<pair<string, int> > includes;
vector<pair<string, int> > comentarios_linea;

vector<pair<string, int> > comentarios_bloque;

stack<char> parentesis_llaves;
vector<int> error_parentesis;


string texto;

%}


%%

^"#" {ordenes_preprocesador++;texto.append(YYText());}
^"#include"\ ?[<"][a-zA-Z.a-zA-Z]*[>"] {ordenes_preprocesador++; string frase(YYText()); includes.push_back(make_pair( frase.substr(8, frase.size()-1), lineno() )  );texto.append(YYText());}
^"#define" {num_defines++; ordenes_preprocesador++;texto.append(YYText());}


"//".*	{string comentario(YYText()); comentarios_linea.push_back(make_pair(comentario, lineno()));texto.append(YYText());}

"/*".*"*/"	{string comentario(YYText()); comentarios_bloque.push_back(make_pair(comentario, lineno()));texto.append(YYText());}

("/*")+[^"*/"]*("/*")*[^"*/"]*"*/"	{string comentario(YYText()); comentarios_bloque.push_back(make_pair(comentario, lineno()));texto.append(YYText());}

"(" {parentesis_llaves.push('('); contar_parentesis.first++;texto.append(YYText());}
")" { if(!parentesis_llaves.empty() && parentesis_llaves.top() == '(' ){
			parentesis_llaves.pop();
		} else {
			error_parentesis.push_back(lineno());
			texto.append("ERROR-->");
		}
		contar_parentesis.second++;
	 texto.append(YYText());
	}

"{" {	parentesis_llaves.push('{');
		contar_llaves.first++;
		texto.append(YYText());
	 }

"}" { if(!parentesis_llaves.empty() && parentesis_llaves.top() == '{' ){
			parentesis_llaves.pop();
		} else {
			error_parentesis.push_back(lineno());
			texto.append("ERROR-->");
		}

	   contar_llaves.second++;
	  texto.append(YYText());
 	 }



. {texto.append(YYText());}
\n {texto.append(YYText());
	 texto.append(to_string(lineno()));
	 }

%%


int main(int argc, char ** argv){

	if (argc != 2 && argc != 3){
		cout << "ERROR: Número invalido de parametros" << endl
			  << "\t Uso: ./" << argv[0] << " <fichero_entrada> [<fichero_salida>] " << endl
			  << "\t El fichero de entrada leerá el código en C/C++" << endl
			  << "\t El fichero de salida es opcional. Si no proporciona la salida se realizará por pantalla" << endl;
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
		  << "Numero de includes: " << includes.size() << endl << endl
		  << "Numero de parentesis a la izquierda: " << contar_parentesis.first << endl
		  << "Numero de parentesis a la derecha: " << contar_parentesis.second << endl << endl
		  << "Numero de llaves a la izquierda: " << contar_llaves.first << endl
		  << "Numero de llaves a la derecha: " << contar_llaves.second << endl << endl
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

	cout << endl << endl;

	if (error_parentesis.empty()){
		cout << "No he encontrado errores en las llaves o parentesis del codigo" << endl;
	} else {
		cout << "He encontrado los siguientes errores en las llaves o parentesis del codigo" << endl;
		for (auto it = error_parentesis.begin(); it != error_parentesis.end(); ++it){
			cout <<  "\tERROR: Parentesis o llaves erroneas en la linea " << (*it) << endl;
		}
	}


	if (argc == 3){
		fstream salida(argv[2], fstream::out);
		salida << texto;
		salida.close();
	} else {
		cout << endl << endl << texto;
	}


	return 0;

}
