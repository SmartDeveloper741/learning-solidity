/*
	This file is part of solidity.

	solidity is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	solidity is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with solidity.  If not, see <http://www.gnu.org/licenses/>.
*/
/** @file Compiler.cpp
 * @author Gav Wood <i@gavwood.com>
 * @date 2014
 */

#include <liblll/Compiler.h>
#include <liblll/Parser.h>
#include <liblll/CompilerState.h>
#include <liblll/CodeFragment.h>

using namespace std;
using namespace solidity;
using namespace solidity::util;
using namespace solidity::lll;

bytes solidity::lll::compileLLL(string _src, langutil::EVMVersion _evmVersion, bool _opt, std::vector<std::string>* _errors, ReadCallback const& _readFile)
{
	try
	{
		CompilerState cs;
		cs.populateStandard();
		auto assembly = CodeFragment::compile(std::move(_src), cs, _readFile).assembly(cs);
		if (_opt)
			assembly = assembly.optimise(true, _evmVersion, true, 200);
		bytes ret = assembly.assemble().bytecode;
		for (auto i: cs.treesToKill)
			killBigints(i);
		return ret;
	}
	catch (Exception const& _e)
	{
		if (_errors)
		{
			_errors->emplace_back("Parse error.");
			_errors->emplace_back(boost::diagnostic_information(_e));
		}
	}
	catch (std::exception const& _e)
	{
		if (_errors)
		{
			_errors->emplace_back("Parse exception.");
			_errors->emplace_back(boost::diagnostic_information(_e));
		}
	}
	catch (...)
	{
		if (_errors)
			_errors->emplace_back("Internal compiler exception.");
	}
	return bytes();
}

std::string solidity::lll::compileLLLToAsm(std::string _src, langutil::EVMVersion _evmVersion, bool _opt, std::vector<std::string>* _errors, ReadCallback const& _readFile)
{
	try
	{
		CompilerState cs;
		cs.populateStandard();
		auto assembly = CodeFragment::compile(std::move(_src), cs, _readFile).assembly(cs);
		if (_opt)
			assembly = assembly.optimise(true, _evmVersion, true, 200);
		string ret = assembly.assemblyString();
		for (auto i: cs.treesToKill)
			killBigints(i);
		return ret;
	}
	catch (Exception const& _e)
	{
		if (_errors)
		{
			_errors->emplace_back("Parse error.");
			_errors->emplace_back(boost::diagnostic_information(_e));
		}
	}
	catch (std::exception const& _e)
	{
		if (_errors)
		{
			_errors->emplace_back("Parse exception.");
			_errors->emplace_back(boost::diagnostic_information(_e));
		}
	}
	catch (...)
	{
		if (_errors)
			_errors->emplace_back("Internal compiler exception.");
	}
	return string();
}

string solidity::lll::parseLLL(string _src)
{
	sp::utree o;

	try
	{
		parseTreeLLL(std::move(_src), o);
	}
	catch (...)
	{
		killBigints(o);
		return string();
	}

	ostringstream ret;
	debugOutAST(ret, o);
	killBigints(o);
	return ret.str();
}
