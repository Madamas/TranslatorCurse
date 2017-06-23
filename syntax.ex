defmodule Syntax do
	#TODO
	#Create interface for syntax analyzer
	def check_syntax(lex)do
		pid = Table.start_link
		wut = Enum.map lex, fn(line)->
			#IO.inspect line,label: "line to check"
			first = List.first(line)
			case first.type do
				"segment"->if(first.name == "end")do
					{:true,"smth"}
				else
					Table.put(pid,"error",first.string)
					{:false,"segment error"}
				end
				"identifier"-> id_check(line,pid)
				"seg_identifier"-> id_check(line,pid)
				"const"-> id_check(line,pid)
				"label"-> id_check(line,pid)
				"command"-> if(first.name == "jcxz" || first.name == "cli")do
					if(length(line) == 1)do
						{:true,"smth"}
					else
						Table.put(pid,"error",first.string)
						{:false,"bad argument"}
					end
				else
					type_check(Enum.split_while(line, fn(x)-> x.name != "," end),pid)
				end
				_->Table.put(pid,"error",first.string)
					{:false,"wrong lexem"}
			end			
		end
		synt = List.flatten wut
		{compose(lex,synt,[]),pid}
	end
	defp compose([],[],acc)do
		acc
	end
	defp compose([head|tail],[h|t],acc)do
		compose(tail,t,acc++[[h|head]])
	end
	defp id_check(string,pid) when (length(string) == 1)do
		first = List.first(string)
		if(first.type == "label") do
				base = byte_size(first.name)-1
				name = binary_part(first.name, 0, base)
				Table.put(pid,"identifier",{name,first})
				{:true,"smth"}
			else
				Table.put(pid,"error",first.string)
				{:false,"wrong lexem"}
			end
	end
	defp id_check(string,pid) when (length(string) == 2)do
	[first|[second]] = string
		if(first.type == "seg_identifier" && second.name == "segment")do
			list = Table.get pid,"segment"
			list = Enum.filter(list,fn({_,{{name,state},_}})-> name == first.name && state == "start" end)
			if(length(list) == 0)do
			Table.put pid,"identifier",{first.name,first.string}
			Table.put pid,"segment",{{first.name,"start"},first.string}
			{:true,"smth"}
			else
				Table.put(pid,"error",first.string)
				{:false,"segment redefinition"}
			end
		else
			if(first.type == "seg_identifier" && second.name == "ends")do
			Table.put pid,"identifier",{first.name,first.string}
			list = Table.get pid,"segment"
			list = Enum.filter(list,fn({_,{{name,state},_}})-> name == first.name && state == "end" end)
			if(length(list) == 0)do
			Table.put pid,"segment",{{first.name,"end"},first.string}
			{:true,"smth"}
			else
			Table.put(pid,"error",first.string)
			{:false,"multiple segment close"}
			end
			else
			Table.put(pid,"error",first.string)
			{:false,"segment error"}
			end
		end
	end
	#if first lex is identifier
	defp id_check(string,pid) when (length(string) == 3) do
	[first|[second|[third]]]= string
		case second.name do
			"db"-> if(third.type == "string" || third.type == "hexadecimal") do
				list = Table.get pid,"var"
				list = Enum.filter(list,fn({"var",val})-> val == first.name end)
				if(length(list) == 0)do
				Table.put(pid,first.type,{first.name,%{third|type: "db"}})
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
			"dw"-> if(third.type == "hexadecimal") do
				list = Table.get pid,"var"
				list = Enum.filter(list,fn({"var",val})-> val == first.name end)
				if(length(list) == 0)do
				Table.put(pid,first.type,{first.name,%{third|type: "dw"}})
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
				Table.put(pid,first.type,{first.name,%{third|type: "dd"}})
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
			"="-> 
				case third.type do
					"hexadecimal"->
						Table.put(pid,"identifier",{first.name,third})
						Table.put(pid,"const",{first.name,third.name})
						{:true,"smth"}
					"string"-> if(String.length(third.name)<=6)do
						Table.put(pid,"identifier",{first.name,third})
						Table.put(pid,"const",{first.name,third.name})
						{:true,"smth"}
						else
							Table.put(pid,"error",first.string)
							{:false,"type error"}
						end
					_->
						Table.put(pid,"error",first.string)
						{:false,"type error"}
				end
			_->
				Table.put(pid,"error",first.string)
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
		#IO.inspect command,label: "command"
		#IO.inspect first,label: "first"
		#IO.inspect name1,label: "name1"
		#IO.inspect type1,label: "type1"
		#IO.inspect im1,label: "im1"
		#IO.inspect last,label: "last"
		#IO.inspect name2,label: "name2"
		#IO.inspect type2,label: "type2"
		#IO.inspect im2,label: "im2"
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
				if(command.name == "xor")do
					case type2 do
						:string->Table.put(pid,"error",command.string)
								{:false,"type error"}
						:label->
							Table.put(pid,"error",command.string)
							{:false,"phase error between passes"}
						_->{:true,"smth"}
					end
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
	defp check_types(type1,type2) when (type1 == :type and type2 == :word) do
		:warning
	end
	defp check_types(type1,type2) when (type1 == :type and type2 == :dword) do
		:true
	end
	defp check_types(type1,type2) when (type1 == :type and type2 == :byte) do
		:warning
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
	defp check_types(type1,type2) when (type1 == :byte and type2 == :byte) do
		:true
	end
	defp check_types(type1,type2) when (type1 == :word and type2 == :byte) do
		:true
	end
	defp check_types(type1,type2) when (type1 == :dword and type2 == :byte) do
		:true
	end
	defp check_types(type1,type2) when (type1 == :dword and type2 == :word) do
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
					   "prefix" ->if(equation_check(thd.name))do
					   	{:dword,:prefix}
					   	else
					   	{:err,:false}
					   end
					   "identifier"->
					   	list = Table.get pid,"var"
						list = Enum.filter(list,fn({"var",val})-> val == fst.name end)
						if(length(list) == 0)do
						{:dword,:identifier}
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
			"hexadecimal" ->check_hex(lol.name)
			"string" -> {:type,:string}
			"const" ->check_const(lol.name,pid)
			"identifier"->{:type,:identifier}
			"label"->{:type,:label}
			_ -> {:err,:false}
		end
	end
	defp op_check(operand,pid)do
		{:err,:false}
	end
	defp check_const(const,pid)do
		list = Table.get pid,"const"
		values = Enum.filter(list,fn({_,{name,_}})->name == const end)
		{"const",{name,value}} = List.last(values)
		base = byte_size(value)-1
		hex = String.codepoints(binary_part(value, 0, base))
		if(Dictionary.checkHex(hex))do
			check_hex(value)
		else
			cond do
				(String.length(value)<=3)->{:byte,:string}
				(String.length(value)>3 and String.length(value)<=5)->{:word,:string}
				true->{:err,:false}
			end
		end
	end
	defp equation_check([eq])do
		list = Regex.split(~r{(\[|\]|\+|\*)},eq,include_captures: true, trim: true)
		allowed = ["eax","ebx","ecx","edx","esi","ebp","esp"]
		used = ["[","]","+","+","*"]
		mult = ["2h","4h","8h"]
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
	defp check_hex(hex)do
		cond do
			(String.length(hex)<=3)->{:byte,:hexadecimal}
			(String.length(hex)>3 and String.length(hex)<=5)->{:word,:hexadecimal}
			(String.length(hex)>5 and String.length(hex)<=7)->{:dword,:hexadecimal}
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
	def seg_align([],acc)do
		List.flatten(acc)
	end
	def seg_align(list,acc)do
		{_,{{name,_},_}} = List.first(list)
		intervals = Enum.filter(list,fn({_,{{seg,_},_}}) -> seg == name end)
		if(length(intervals) == 2)do
			[first|[second]] = intervals
			{_,{{name,_},head}} = first
			{_,{{name,_},tail}} = second
			if(head > tail) do
				seg_align(Enum.filter(list,fn({_,{{seg,_},_}}) -> seg != name end),acc)
			else
				gen = for n <- head..tail, do: n
				seg_align(Enum.filter(list,fn({_,{{seg,_},_}}) -> seg != name end),[acc]++[gen])
			end
		else
			seg_align(Enum.filter(list,fn({_,{{seg,_},_}}) -> seg != name end),acc)
		end
	end
	def align_intervals(lex,pid)do
		list = Table.get pid,"segment"
		intervals = seg_align(list,[])
		Enum.map lex, fn(string)->
			[{flag,_}|[first|tail]] = string
			if(first.string in intervals || first.name == "end")do
				string
			else
				[{false,"out of segment"}|[first|tail]]
			end
		end
	end
end