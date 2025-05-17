#ifndef SYMBOL_INFO_HPP
#define SYMBOL_INFO_HPP

#include <iostream>
#include <string>

using namespace std;

class SymbolInfo
{
	string name, type;

public:
	SymbolInfo *next;
	SymbolInfo(string name, string type, SymbolInfo *next = NULL)
	{
		this->name = name;
		this->type = type;
		this->next = next;
	}
	~SymbolInfo()
	{
	}
	string get_name()
	{
		return name;
	}
	void set_name(string name)
	{
		this->name = name;
	}
	string get_type()
	{
		return type;
	}
	void set_type(string type)
	{
		this->type = type;
	}
};

#endif