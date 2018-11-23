module Convert;

version(unittest) import fluent.asserts;

import std.container;
import std.range;

import Tokens;

class ParseException : Exception
{
	this(string message)
	{
		super(message);
	}
}


unittest
{
	precedence(Token("+", TokenType.Operator)).should.be.lessThan(precedence(Token("*", TokenType.Operator)));
}

unittest
{
	import Tokenizer;
	InfixToPostfix([]).should.equal([]);

	InfixToPostfix(Tokenize("1")).should.equal([Token("1", TokenType.Literal)]);
	InfixToPostfix(Tokenize("1 + 2"))
		.should.equal([
			Token("1", TokenType.Literal),
			Token("2", TokenType.Literal),
			Token("+", TokenType.Operator)
			]);

	InfixToPostfix(Tokenize("1 + 2 * 3"))
		.should.equal([
			Token("1", TokenType.Literal),
			Token("2", TokenType.Literal),
			Token("3", TokenType.Literal),
			Token("*", TokenType.Operator),
			Token("+", TokenType.Operator)
			]);

	InfixToPostfix(Tokenize("(1 + 2) * 3"))
		.should.equal([
			Token("1", TokenType.Literal),
			Token("2", TokenType.Literal),
			Token("+", TokenType.Operator),
			Token("3", TokenType.Literal),
			Token("*", TokenType.Operator)
			]);


	InfixToPostfix(Tokenize("(")).should.throwException!ParseException();
	InfixToPostfix(Tokenize(")")).should.throwException!ParseException();
}

Token[] InfixToPostfix(Token[] input)
{
	//import std.stdio;
	//import std.algorithm.iteration;
	//writefln("Begin Processing %s", input);

	auto OutputStack = make!(Array!Token);
	auto OperatorStack = make!(Array!Token);

	foreach(token;input)
	{
		//writefln("Processing %s\nOperatorStack: %s\nOutputStack: %s\n", token, OperatorStack.array.map!(t=>t.Token).array, OutputStack.array.map!(t=>t.Token).array);
		final switch(token.Type)
		{
		case TokenType.Literal:
			OutputStack.insert(token);
			break;
		case TokenType.Operator:
			while(!OperatorStack.empty
					&& (
						OperatorStack.back.Token != "("
						&& (
							OperatorStack.back.precedence > token.precedence
							|| (
									OperatorStack.back.precedence == token.precedence
									&& OperatorStack.back.associativity == Associativity.Left
								)
							)
						)
				)
			{
				OperatorStack.popTo(OutputStack);
			}
			OperatorStack.insert(token);
			break;
		case TokenType.Paren:
			if(token.Token == "(")
			{
				OperatorStack.insert(token);
			}
			else
			{
				while(!OperatorStack.empty && OperatorStack.back.Token != "(")
				{
					OperatorStack.popTo(OutputStack);
				}
				OperatorStack.removeBack;
			}
			break;
		}
	}

	while(!OperatorStack.empty)
	{
		OperatorStack.popTo(OutputStack);
	}

	return OutputStack.array;
}

int precedence(Token operator)
{
	return OperatorPrecedence[operator.Token];
}


Associativity associativity(Token operator)
{
	return OperatorAssociativity[operator.Token];
}

T pop(T)(Array!T from)
{
	auto back = from.back;
	from.removeBack;
	return back;
}

void popTo(T)(Array!T from, Array!T to)
{
	to.insert(from.pop);
}