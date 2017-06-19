defmodule Semantics do
	def count(lex,pid)do
		Enum.map lex,fn(x)->
			[{flag,_}|tail] = x
			if flag do
			
			else
			x
			end
		end
	end
	def count_bytes(string,pid)do
	end
	defp id_check(string,pid) when (length(string) == 1)do
		first = List.first(string)
		if(first.type == "label") do
				0
			else
				0
			end
	end
	defp id_check(string,pid) when (length(string) == 2)do
	[first|[second]] = string
		if(first.type == "seg_identifier" && second.name == "segment")do
			Table.put pid,"counter",0
			0
		else
			if(first.type == "seg_identifier" && second.name == "ends")do
			Table.delete pid,"counter"
			0
			end
		end
	end
	#if first lex is identifier
	defp id_check(string,pid) when (length(string) == 3) do
	[first|[second|[third]]]= string
	[{"counter",count}] = Table.get pid,"counter"
		case second.name do
			"db"-> if(third.type == "string")do
					
				else
			 	if(third.type == "hexadecimal") do
				
				end
				end
			else
				Table.put(pid,"error",first.string)
				{:false,"type error"}
			end
			"dw"-> if(third.type == "hexadecimal") do
				list = Table.get pid,"var"
				list = Enum.filter(list,fn({"var",val})-> val == first.name end)
				if(length(list) == 0)do
				Table.put pid,"var",first.name
				{:true,"smth"}
				else
				Table.put(pid,"error",first.string)
				{:false,"name redefinition"}
				end
			else
				Table.put(pid,"error",first.string)
				{:false,"type error"}
			end
			"dd"-> if(third.type == "hexadecimal") do
				list = Table.get pid,"var"
				list = Enum.filter(list,fn({"var",val})-> val == first.name end)
				if(length(list) == 0)do
				Table.put pid,"var",first.name
				{:true,"smth"}
				else
				Table.put(pid,"error",first.string)
				{:false,"name redefinition"}
				end
			else
				Table.put(pid,"error",first.string)
				{:false,"type error"}
			end
			"="-> if(third.type == "hexadecimal") do
				Table.put(pid,"const",{first.name,third.name})
				{:true,"smth"}
			else
				Table.put(pid,"error",first.string)
				{:false,"type error"}
			end
				_->Table.put(pid,"error",first.string)
				{:false,"type error"}
		end
	end
	defp id_check(string,pid)do
		first = List.first(string)
		Table.put(pid,"error",first.string)
		{:false,"type error"}
	end
	#if theres casting in one operand command
	defp type_check({[command|[first|[second|[third]]]],[]},pid)do
		if(first.type == "size_type" && second.type == "operator")do
			case command.name do
			"idiv"-> if((third.type == "reg8" && first.name != "word") || (third.type == "reg32" && first.name != "word"))do
				{:true,"smth"}
			else
				Table.put(pid,"error",third.string)
				{:false,"type error"}
			end
			"int"-> case third.type do
				"hexadecimal"->
				base = byte_size(third.name)-1
				hex = String.codepoints(binary_part(third.name, 0, base))
				if(length(hex)>8 && first.name != "byte")do
					Table.put(pid,"error",third.string)
					{:false,"type error"}
				else
					{:true,"smth"}
				end

				"string"->
					if(length(String.codepoints(third.name))>3)do
						Table.put(pid,"error",third.string)
						{:false,"type error"}
					else
						{:true,"smth"}
					end

				"const"->
				list = Table.get(pid,"const")
				|>Enum.filter(fn({_,{name,_}})->name == third.name end)
				|>List.last
				{_,{key,value}} = list
				base = byte_size(value)-1
				hex = String.codepoints(binary_part(value, 0, base))
				if(length(hex)>8)do
					Table.put(pid,"error",third.string)
					{:false,"type error"}
				else
					{:true,"smth"}
				end
				_->Table.put(pid,"error",third.string)
					:false
			end
			_-> Table.put(pid,"error",third.string)
				{:false,"type error"}
		end
		else
			{:err,:false}
		end
	end
	#if first lex is command
	defp type_check({[command|[first]],[]},pid)do
		case command.name do
			"idiv"-> if(first.type == "reg8" || first.type == "reg32")do
				{:true,"smth"}
			else
				Table.put(pid,"error",first.string)
				{:false,"type error"}
			end
			"int"-> case first.type do
				"hexadecimal"->
				base = byte_size(first.name)-1
				hex = String.codepoints(binary_part(first.name, 0, base))
				if(length(hex)>8)do
					Table.put(pid,"error",first.string)
					{:false,"type error"}
				else
					{:true,"smth"}
				end
				"string"->
					if(length(String.codepoints(first.name))>3)do
						Table.put(pid,"error",first.string)
						{:false,"type error"}
					else
						{:true,"smth"}
					end
				"const"->
				list = Table.get(pid,"const")
				|>Enum.filter(fn({_,{name,_}})->name == first.name end)
				|>List.last
				{_,{key,value}} = list
				base = byte_size(value)-1
				hex = String.codepoints(binary_part(value, 0, base))
				if(length(hex)>8)do
					Table.put(pid,"error",first.string)
					{:false,"type error"}
				else
					{:true,"smth"}
				end
				_->Table.put(pid,"error",first.string)
					{:false,"type error"}
			end
			_-> Table.put(pid,"error",first.string)
				{:false,"type error"}
		end
	end
	defp type_check({[command|first], [_|last]},pid) do
		fst = List.first(first)
		lst = List.first(last)
		{type1,name1} = op_check(first,pid)
		{type2,name2} = op_check(last,pid)
		im1 = make_implicit(name1)
		im2 = make_implicit(name2)
		synt = file("syntax.md")
		wew = Enum.find synt,fn(x)-> (x.type == [im1,im2] and x.allowed == command.name) end
		if(wew == :nil)do
			Table.put(pid,"error",command.string)
			{:false,"type error"}
		else
			case check_types(type1,type2) do
				:warning->
					Table.put(pid,"warning",command.string)
					{:warning,"type mismatch"}
				false->
					Table.put(pid,"error",command.string)
					{:false,"type error"}
				true-> 
				if(command.name == "xor" and (type1 == :type || type2 == :type))do
					Table.put(pid,"error",command.string)
					{:false,"type error"}
				else
					{:true,"smth"}
				end
			end
		end		
	end
	defp type_check(string)do
		:false
	end
	defp check_types(type1,type2) when (type1 == :type and type2 == :type) do
		:false
	end
	defp check_types(type1,type2) when (type1 == type2) do
		:true
	end
	defp check_types(type1,type2) when ((type1 == :reg or type2 == :reg)and(type1 == :type or type2 == :type)) do
		:warning
	end
	defp check_types(type1,type2) when (type1 == :type or type2 == :type) do
		:true
	end
	defp check_types(type1,type2) when (type1 == :reg and type2 == :reg) do
		:true
	end
	defp check_types(type1,type2) when (type1 == :reg or type2 == :reg) do
		:warning
	end
	defp check_types(type1,type2) when (type1 != type2) do
		:false
	end
	defp op_check(operand,pid) when (length(operand) == 3) do
		[fst|[sec|[thd]]] = operand
		if(fst.type == "size_type" && sec.type == "operator")do
			case fst.name do
				"byte" ->
					case thd.type do
					   "equation" -> if(equation_check(thd.name))do
					   	{:byte,:equation}
					   	else
					   	{:err,:false}
					   end
					   "prefix" ->if(equation_check(thd.name))do
					   	{:byte,:prefix}
					   	else
					   	{:err,:false}
					   end
					   "identifier"->
					   	list = Table.get pid,"var"
						list = Enum.filter(list,fn({"var",val})-> val == fst.name end)
						if(length(list) == 0)do
						{:byte,:identifier}
						else
						{:err,:false}
						end
					   _ -> {:err,:false}
					end
				"word" ->
					case thd.type do
					   "equation" -> if(equation_check(thd.name))do
					   	{:word,:equation}
					   	else
					   	{:err,:false}
					   end
					   "prefix" ->if(prefix_check(thd.name))do
					   	{:word,:prefix}
					   	else
					   	{:err,:false}
					   end
					   "identifier"->
					   	list = Table.get pid,"var"
						list = Enum.filter(list,fn({"var",val})-> val == fst.name end)
						if(length(list) == 0)do
						{:word,:identifier}
						else
						{:err,:false}
						end
					   _ -> {:err,:false}
					end
				"dword" ->
					case thd.type do
					   "equation" -> if(equation_check(thd.name))do
					   	{:dword,:equation}
					   	else
					   	{:err,:false}
					   end
					   "prefix" ->if(prefix_check(thd.name))do
					   	{:dword,:prefix}
					   	else
					   	{:err,:false}
					   end
					   "identifier"->
					   	list = Table.get pid,"var"
						list = Enum.filter(list,fn({"var",val})-> val == fst.name end)
						if(length(list) == 0)do
						{:byte,:identifier}
						else
						{:err,:false}
						end
					   _ -> {:err,:false}
					end
				_ -> {:err,:false}
			end
		else
			{:err,:false}
		end
	end
	defp op_check(operand,pid) when (length(operand) == 1) do
		[lol] = operand
		case lol.type do
			"equation" -> if(equation_check(lol.name))do
			   	{:type,:equation}
			   	else
			   	{:err,:false}
			   end
			"prefix" -> if(equation_check(lol.name))do
				{:type,:prefix}
			   	else
			   	{:err,:false}
			   end
			"reg8" -> {:reg,:reg8}
			"reg32" -> {:reg,:reg32}
			"hexadecimal" ->{:type,:hexadecimal}
			"string" -> {:type,:string}
			"const" -> {:type,:const}
			"identifier"->{:type,:identifier}
			_ -> {:err,:false}
		end
	end
	defp op_check(operand,pid)do
		{:err,:false}
	end
	defp equation_check([eq])do
		list = Regex.split(~r{(\[|\]|\+|\*)},eq,include_captures: true, trim: true)
		allowed = ["eax","ebx","ecx","edx","esi","ebp","esp"]
		used = ["[","]","+","+","*"]
		mult = ["2h","4h","8h"]
		IO.inspect eq,label: "eq"
		numbers = Enum.filter(list, fn(x) ->
			base = byte_size(x)-1
			last = binary_part(x,base,byte_size(x)-base)
			last == "h"
		 end)
		if(length(numbers) == 2)do
				[first|[second]] = numbers
				if(first in mult && length(String.codepoints(second)) <= 10)do
					golist(list,allowed,used)
					else
					false
				end
			else
				false
		end
	end
	defp equation_check(eq)do
		list = Regex.split(~r{\:},eq)
		case length(list) do
			1->equation_check(list)
			2->prefix_check(list)
		end
	end
	defp golist([],_,[])do
		true
	end
	defp golist([],_,[smt])do
		false
	end
	defp golist([head|tail],allowed,used)do
		base = byte_size(head)-1
		hex = String.codepoints(binary_part(head, 0, base))
		cond do
			(head in used)->golist(tail,allowed,List.delete(used, head))
			(head in allowed)->golist(tail,allowed,used)
			(Dictionary.checkHex(hex))->golist(tail,allowed,used)
			true->false
		end
	end
	defp prefix_check([seg|[eq]])do
		segments = ["cs","ds","ss","es","fs","gs"]
		if(seg in segments)do
			equation_check(eq)
		else
			false
		end
	end
end