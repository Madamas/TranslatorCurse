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
					:true
				else
					Table.put(pid,"error",first.string)
					:false
				end
				"identifier"-> id_check(line,pid)
				"seg_identifier"-> id_check(line,pid)
				"const"-> id_check(line,pid)
				"label"-> id_check(line,pid)
				"command"-> if(first.name == "jcxz" || first.name == "cli")do
					if(length(line) == 1)do
						:true
					else
						Table.put(pid,"error",first.string)
						:false
					end
				else
					type_check(Enum.split_while(line, fn(x)-> x.name != "," end),pid)
				end
				_->Table.put(pid,"error",first.string)
					:false
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
				:true
			else
				Table.put(pid,"error",first.string)
				:false
			end
	end
	defp id_check(string,pid) when (length(string) == 2)do
	[first|[second]] = string
		if(first.type == "seg_identifier" && second.name == "segment")do
			list = Table.get pid,"segment"
			list = Enum.filter(list,fn({_,{{name,state},_}})-> name == first.name && state == "start" end)
			IO.inspect list,label: "LIST START"
			if(length(list) == 0)do
			Table.put pid,"segment",{{first.name,"start"},first.string}
			:true
			else
				Table.put(pid,"error",first.string)
				:false
			end
		else
			if(first.type == "seg_identifier" && second.name == "ends")do
			list = Table.get pid,"segment"
			list = Enum.filter(list,fn({_,{{name,state},_}})-> name == first.name && state == "end" end)
			if(length(list) == 0)do
			Table.put pid,"segment",{{first.name,"end"},first.string}
			:true
			else
			Table.put(pid,"error",first.string)
			:false
			end
			else
			Table.put(pid,"error",first.string)
			:false
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
				Table.put pid,"var",first.name
				:true
				else
				Table.put(pid,"error",first.string)
				:false
				end
			else
				Table.put(pid,"error",first.string)
				:false
			end
			"dw"-> if(third.type == "hexadecimal") do
				list = Table.get pid,"var"
				list = Enum.filter(list,fn({"var",val})-> val == first.name end)
				if(length(list) == 0)do
				Table.put pid,"var",first.name
				:true
				else
				Table.put(pid,"error",first.string)
				:false
				end
			else
				Table.put(pid,"error",first.string)
				:false
			end
			"dd"-> if(third.type == "hexadecimal") do
				list = Table.get pid,"var"
				list = Enum.filter(list,fn({"var",val})-> val == first.name end)
				if(length(list) == 0)do
				Table.put pid,"var",first.name
				:true
				else
				Table.put(pid,"error",first.string)
				:false
				end
			else
				Table.put(pid,"error",first.string)
				:false
			end
			"="-> if(third.type == "string" || third.type == "hexadecimal") do
				Table.put(pid,"const",{first.name,third.name})
				:true
			else
				Table.put(pid,"error",first.string)
				:false
			end
				_->Table.put(pid,"error",first.string)
				:false
		end
	end
	defp id_check(string,pid)do
		first = List.first(string)
		Table.put(pid,"error",first.string)
		:false
	end
	#if theres casting in one operand command
	defp type_check({[command|[first|[second|[third]]]],[]},pid)do
		if(first.type == "size_type" && second.type == "operator")do
			case command.name do
			"idiv"-> if((third.type == "reg8" && first.name != "word") || (third.type == "reg32" && first.name != "word"))do
				:true
			else
				Table.put(pid,"error",third.string)
				:false
			end
			"int"-> case third.type do
				"hexadecimal"->
				base = byte_size(third.name)-1
				hex = String.codepoints(binary_part(third.name, 0, base))
				if(length(hex)>8 && first.name != "byte")do
					Table.put(pid,"error",third.string)
					:false
				else
					:true
				end

				"string"->
					if(length(String.codepoints(third.name))>3)do
						Table.put(pid,"error",third.string)
						:false
					else
						:true
					end

				"const"->
				list = Table.get(pid,"const")
				|>IO.inspect
				|>Enum.filter(fn({_,{name,_}})->name == third.name end)
				|>List.last
				{_,{key,value}} = list
				base = byte_size(value)-1
				hex = String.codepoints(binary_part(value, 0, base))
				if(length(hex)>8)do
					Table.put(pid,"error",third.string)
					:false
				else
					:true
				end
				_->Table.put(pid,"error",third.string)
					:false
			end
			_-> Table.put(pid,"error",third.string)
				:false
		end
		else
			{:err,:false}
		end
	end
	#if first lex is command
	defp type_check({[command|[first]],[]},pid)do
		case command.name do
			"idiv"-> if(first.type == "reg8" || first.type == "reg32")do
				:true
			else
				Table.put(pid,"error",first.string)
				:false
			end
			"int"-> case first.type do
				"hexadecimal"->
				base = byte_size(first.name)-1
				hex = String.codepoints(binary_part(first.name, 0, base))
				if(length(hex)>8)do
					Table.put(pid,"error",first.string)
					:false
				else
					:true
				end
				"string"->
					if(length(String.codepoints(first.name))>3)do
						Table.put(pid,"error",first.string)
						:false
					else
						:true
					end
				"const"->
				list = Table.get(pid,"const")
				|>IO.inspect
				|>Enum.filter(fn({_,{name,_}})->name == first.name end)
				|>List.last
				{_,{key,value}} = list
				base = byte_size(value)-1
				hex = String.codepoints(binary_part(value, 0, base))
				if(length(hex)>8)do
					Table.put(pid,"error",first.string)
					:false
				else
					:true
				end
				_->Table.put(pid,"error",first.string)
					:false
			end
			_-> Table.put(pid,"error",first.string)
				:false
		end
	end
	defp type_check({[command|first], [_|last]},pid) do
		{type1,name1} = op_check(first)
		{type2,name2} = op_check(last)
		im1 = make_implicit(name1)
		im2 = make_implicit(name2)
		synt = file("syntax.md")
		wew = Enum.find synt,fn(x)-> (x.type == [im1,im2] and x.allowed == command.name) end
		if(wew == :nil)do
			Table.put(pid,"error",command.string)
			:false
		else
			if(check_types(type1,type2))do
				:true
			else
				Table.put(pid,"error",command.string)
				:false
			end
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
					   "equation" -> if(equation_check(thd.name))do
					   	{:byte,:equation}
					   	else
					   	{:err,:false}
					   end
					   "prefix" ->if(prefix_check(thd.name))do
					   	{:byte,:prefix}
					   	else
					   	{:err,:false}
					   end
					   "reg8" -> {:byte,:reg8}
					   "reg32" -> {:byte,:reg32}
					   "hexadecimal" ->	{:byte,:hexadecimal}
					   "string" -> {:byte1,:string}
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
					   "reg8" -> {:word,:reg8}
					   "reg32" -> {:word,:reg32}
					   "hexadecimal" ->	{:word,:hexadecimal}
					   "string" -> {:word1,:string}
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
					   "reg8" -> {:dword,:reg8}
					   "reg32" -> {:dword,:reg32}
					   "hexadecimal" ->	{:dword,:hexadecimal}
					   "string" -> {:dword1,:string}
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
			"equation" -> if(equation_check(lol.name))do
			   	{:type,:equation}
			   	else
			   	{:err,:false}
			   end
			"prefix" -> if(prefix_check(lol.name))do
				{:type,:prefix}
			   	else
			   	{:err,:false}
			   end
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
	defp equation_check([eq])do
		list = Regex.split(~r{(\[|\]|\+|\*)},eq,include_captures: true, trim: true)
		allowed = ["eax","ebx","ecx","edx","esi","ebp","esp"]
		used = ["[","]","+","+","*"]
		golist(list,allowed,used)
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
			IO.inspect intervals,label: "intervals"
			[first|[second]] = intervals
			{_,{{name,_},head}} = first
			{_,{{name,_},tail}} = second
			IO.inspect head,label: "head"
			IO.inspect tail,label: "tail"
			if(head > tail) do
				seg_align(Enum.filter(list,fn({_,{{seg,_},_}}) -> seg != name end),acc)
			else
				gen = for n <- head..tail, do: n
				IO.inspect gen,label: "gen"
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
			[flag|[first|tail]] = string
			if(first.string in intervals || first.name == "end")do
				string
			else
				[false|[first|tail]]
			end
		end
	end
end