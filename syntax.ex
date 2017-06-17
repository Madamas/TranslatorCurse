defmodule Syntax do
	#TODO
	#Create interface for syntax analyzer
	def check_syntax(lex)do
		wut = Enum.map lex, fn(line)->
			#IO.inspect line,label: "line to check"
			first = List.first(line)
			case first.type do
				"segment"->if(first.name == "end")do
					:true
				else
					:false
				end
				"identifier"-> id_check(line,[])
				"seg_identifier"-> id_check(line,[])
				"const"-> id_check(line,[])
				"label"-> id_check(line,[])
				"command"-> if(first.name == "jcxz" || first.name == "cli")do
					if(length(line) == 1)do
						:true
					else
						:false
					end
				else
					IO.inspect (Enum.split_while(line, fn(x)-> x.name != "," end)),label: "kekos"
					type_check(Enum.split_while(line, fn(x)-> x.name != "," end))
				end
			end			
		end
		synt = List.flatten wut
		compose(lex,synt,[])
	end
	defp compose([],[],acc)do
		acc
	end
	defp compose([head|tail],[h|t],acc)do
		compose(tail,t,acc++[[h|head]])
	end
	defp id_check(string,table) when (length(string) == 1)do
		first = List.first(string)
		if(first.type == "label") do
				[:true,table]
			else
				[:false,table]
			end
	end
	defp id_check(string,table) when (length(string) == 2)do
	#IO.inspect string,label: "GOT HERE SOME STRING2"
	[first|[tail]] = string
	#IO.inspect first,label: "GOT HERE SOME FIRST"
	#IO.inspect tail,label: "GOT HERE SOME TAIL"
	if(first.type == "seg_identifier" && tail.type == "segment") do
		:true
	else
		:false
	end
	end
	#if first lex is identifier
	defp id_check(string,table) when (length(string) == 3) do
	[first|[second|[third]]]= string
		case second.name do
			"db"-> if(third.type == "string" || third.type == "hexadecimal") do
				[:true,table]
			else
				[:false,table]
			end
			"dw"-> if(third.type == "hexadecimal") do
				[:true,table]
			else
				[:false,table]
			end
			"="-> if(third.type == "string" || third.type == "hexadecimal") do
				[:true,table]
			else
				[:false,table]
			end
				_->[:false,table]
		end
	end
	defp id_check(string,table)do
		:false
	end
	#if first lex is command
	defp type_check({[command|[first]],[]})do
		case command.name do
			"idiv"-> if(first.type == "reg8" || first.type == "reg32")do
				:true
			else
				:false
			end
			"int"-> case first.type do
				"hexadecimal"->:true
				"string"->:true
				"label"->:true
				"const"->:true
				_->:false
			end
			_-> :false
		end
	end
	defp type_check({[command|first], [_|last]}) do
		{type1,name1} = op_check(first)
		{type2,name2} = op_check(last)
		im1 = make_implicit(name1)
		im2 = make_implicit(name2)
		synt = file("syntax.md")
		wew = Enum.find synt,fn(x)-> (x.type == [im1,im2] and x.allowed == command.name) end
		if(wew == :nil)do
			:false
		else
			check_types(type1,type2)
		end		
	end
	defp type_check(string)do
		:false
	end
	#TODO add size check so you can compare both operands for syntax 
	#operands can't both be :type 
	defp check_types(type1,type2) when (type1 == :type and type2 == :type) do
		:false
	end
	defp check_types(type1,type2) when (type1 == type2) do
		:true
	end
	defp check_types(type1,type2) when (type1 == :type or type2 == :type) do
		:true
	end
	defp check_types(type1,type2) when (type1 != type2) do
		:false
	end
	defp file(path) do
		{atom, pid} = File.open path,[:utf8]
		acc = case atom do
			:error -> IO.puts "error"
			:ok -> fileHandle pid,[]
		end
		acc
	end
	defp fileHandle(pid,acc) do
		string = IO.read pid,:line
		case string do
			:eof -> File.close pid
			acc
			_ ->
				string = Regex.replace(~r/\t/,string,"", global: true)
				|>String.trim_trailing()
				|> (&Regex.split(~r{\ },&1)).()
				[h|t] = string
				fileHandle(pid,acc++[%{type: t,allowed: h}])
		end
	end
	#TODO this function gets explicit type and returns abstract typename (like imm or reg)
	defp make_implicit(atom) do
		string = to_string(atom)
		map = file("allowed.md")
		found = Enum.find map,fn(x)-> string in x.type end
		if(found == :nil)do
			:false
		else
			found.allowed
		end
	end
	#checking operands
	#TODO const will return :type type
	defp op_check(operand) when (length(operand) == 3) do
		[fst|[sec|[thd]]] = operand
		if(fst.type == "size_type" && sec.type == "operator")do
			case fst.name do
				"byte" ->
					case thd.type do
					   "equation" -> {:byte,:equation}
					   "prefix" -> {:byte,:prefix}
					   "reg8" -> {:byte,:reg8}
					   "reg32" -> {:byte,:reg32}
					   "hexadecimal" ->	{:byte,:hexadecimal}
					   "string" -> {:byte1,:string}
					   _ -> {:err,:false}
					end
				"dword" ->
					case thd.type do
					   "equation" -> {:dword,:equation}
					   "prefix" -> {:dword,:prefix}
					   "reg8" -> {:dword,:reg8}
					   "reg32" -> {:dword,:reg32}
					   "hexadecimal" ->	{:dword,:hexadecimal}
					   "string" -> {:dword,:string}
					   _ -> {:err,:false}
					end
				_ -> {:err,:false}
			end
		else
			{:err,:false}
		end
	end
	defp op_check(operand) when (length(operand) == 1) do
		[lol] = operand
		case lol.type do
			"equation" -> {:type,:equation}
			"prefix" -> {:type,:prefix}
			"reg8" -> {:byte,:reg8}
			"reg32" -> {:dword,:reg32}
			"hexadecimal" ->{:type,:hexadecimal}
			"string" -> {:type,:string}
			"const" -> {:type,:const}
			"identifier"->{:type,:identifier}
			_ -> {:err,:false}
		end
	end
	defp op_check(operand)do
		{:err,:false}
	end
	defp equation_check(eq)do
		
	end
end