module Tokens;

enum TokenType{Literal, Operator, Paren};
enum Associativity{Left, Right};

auto Operators = ["^", "+", "-", "*", "/"];

auto OperatorPrecedence(){
return [
		"^": 4,
		"*": 3,
		"/": 3,
		"+": 2,
		"-": 2
	];
}

auto OperatorAssociativity(){
return [
		"^": Associativity.Right,
		"*": Associativity.Left,
		"/": Associativity.Left,
		"+": Associativity.Left,
		"-": Associativity.Left
	];
}

struct Token
{
	this(string token, TokenType type)
	{
		_token = token;
		_type = type;
	}

	string Token() {return _token;}
	TokenType Type() {return _type;}

private:
	string _token;
	TokenType _type;
}