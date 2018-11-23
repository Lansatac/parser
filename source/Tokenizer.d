module Tokenizer;

version(unittest) import fluent.asserts;

import std.stdio;

import std.range;
import std.algorithm.iteration;
import std.algorithm.searching;
import std.typecons;
import std.format;
import std.uni;

import Tokens;

unittest
{
	Tokenize("").should.equal([]);
	Tokenize(" ").should.equal([]);
	Tokenize("1").should.equal([Token("1", TokenType.Literal)]);
	Tokenize("1 + 2").should.equal([Token("1", TokenType.Literal), Token("+", TokenType.Operator), Token("2", TokenType.Literal)]);
	Tokenize("12").should.equal([Token("12", TokenType.Literal)]);
	Tokenize("()").should.equal([Token("(", TokenType.Paren), Token(")", TokenType.Paren)]);
}

Token[] Tokenize(StringRange)(StringRange text)
	if(isInputRange!StringRange)
{
	Token[] tokens = [];
	while(!text.empty)
	{
		int taken = 0;
		Nullable!TokenType tokenType;
		taken = takeWhitespace(text);
		if(taken != 0)
		{
			goto TextConsumed;
		}
		taken = takeParen(text);
		if(taken != 0)
		{
			tokenType = TokenType.Paren;
			goto TextConsumed;
		}
		taken = takeNumber(text);
		if(taken != 0)
		{
			tokenType = TokenType.Literal;
			goto TextConsumed;
		}
		taken = takeOperator(text);
		if(taken != 0)
		{
			tokenType = TokenType.Operator;
			goto TextConsumed;
		}
		throw new Exception(format("String cannot be tokenized: '%s'", text));

TextConsumed:
		if(!tokenType.isNull)
			tokens ~= Token(text[0..taken], tokenType.get);
		text = text[taken..$];
	}
	return tokens;
}

unittest
{
	takeWhitespace("").should.equal(0);
	takeWhitespace("a").should.equal(0);
	takeWhitespace(" ").should.equal(1);
	takeWhitespace(" a ").should.equal(1);
	takeWhitespace(" \t").should.equal(2);
}

int takeWhitespace(string text)
{
	int taken = 0;
	foreach(dchar c; text)
	{
		if(!c.isWhite)
			break;
		++taken;
	}
	return taken;
}

unittest
{
	takeParen("").should.equal(0);
	takeParen("a").should.equal(0);
	takeParen("(").should.equal(1);
	takeParen("()").should.equal(1);
}

int takeParen(string text)
{
	return !text.empty
			&& (text.front == '(' || text.front == ')') ? 1 : 0;
}

unittest
{
	takeNumber("").should.equal(0);
	takeNumber("1").should.equal(1);
	takeNumber("12").should.equal(2);
	takeNumber("12a").should.equal(2);
	takeNumber("12 12").should.equal(2);
}

int takeNumber(string text)
{
	int taken = 0;
	foreach(dchar c; text)
	{
		if(!c.isNumber)
			break;
		++taken;
	}
	return taken;
}

unittest
{
	takeOperator("").should.equal(0);
	takeOperator("1").should.equal(0);
	takeOperator("+").should.equal(1);
	takeOperator("+-").should.equal(1);
}

int takeOperator(string text)
{
	int taken = 0;
	foreach(operator; Operators)
	{
		if(text.startsWith(operator))
		{
			taken = cast(int)operator.length;
			break;
		}
	}
	return taken;
}