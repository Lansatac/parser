import std.stdio;

import Tokenizer;
import Convert;

import std.range;
import std.algorithm.iteration;

void main()
{
	string input;
	do
	{
		write("Enter Expression: ");
		input = readln;

		auto tokens = Tokenize(input);
		writefln("Tokenized: %s", tokens);
		writefln("To Postfix: %s", tokens.InfixToPostfix.map!(token=>token.Token));
	} while(input != "\n");
}
