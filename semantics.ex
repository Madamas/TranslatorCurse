defmodule Semantics do
	def count_bytes(lex,pid)do
		wut = Enum.map lex, fn(line)->
			[{flag,_}|tail] = line
			if flag do
			first = List.first(tail)
			case first.type do
				"segment"-> 0
				"identifier"-> id_check(tail,pid)
				"seg_identifier"-> id_check(tail,pid)
				"const"-> id_check(tail,pid)
				"label"-> id_check(tail,pid)
				"command"-> 
					case first.name do
						"jcxz"->
						[{"counter",counter}] = Table.get pid,"counter" 
						Table.update pid,"counter",counter+3
						counter
						"cli"-> 
						[{"counter",counter}] = Table.get pid,"counter" 
						Table.update pid,"counter",counter+1
						counter
						_-> type_check(Enum.split_while(tail, fn(x)-> x.name != "," end),pid)
					end
				_-> 0
			end
			else
			line
			end		
		end
		List.flatten wut
		align(wut,lex,[])
	end
	defp align([],[],acc)do
		acc
	end
				#wut - lex
	defp align([h|t],[head|tail],acc)do		
		[{flag,fk}|tl] = head
		align(t,tail,acc++[[[{flag,fk,h}|tl]|head]])
	end
	defp id_check(string,pid) when (length(string) == 1)do
		first = List.first(string)
		if(first.type == "label") do
				[{"counter",counter}] = Table.get pid,"counter" 
				counter
			else
				[{"counter",counter}] = Table.get pid,"counter" 
				counter
			end
	end
	defp id_check(string,pid) when (length(string) == 2)do
	[first|[second]] = string
		if(first.type == "seg_identifier" && second.name == "segment")do
			Table.put pid,"counter",0
			0
		else
			if(first.type == "seg_identifier" && second.name == "ends")do
			[{"counter",counter}] = Table.get pid,"counter" 
			Table.delete pid,"counter"
			counter
			end
		end
	end
	#if first lex is identifier
	defp id_check(string,pid) when (length(string) == 3) do
	[first|[second|[third]]]= string
		case second.name do
			"db"-> 
				case third.type do
					"string"->
						[{"counter",counter}] = Table.get pid,"counter" 
						Table.update pid,"counter",counter+String.length(third.name)-2
						counter
					"hexadecimal"->
						[{"counter",counter}] = Table.get pid,"counter" 
						Table.update pid,"counter",counter+1
						counter
				end
			"dw"-> 
				[{"counter",counter}] = Table.get pid,"counter" 
				Table.update pid,"counter",counter+2
				counter
			"dd"->
				[{"counter",counter}] = Table.get pid,"counter" 
				Table.update pid,"counter",counter+4
				counter
			"="-> 
				[{"counter",counter}] = Table.get pid,"counter"
				counter
		end
	end
	defp id_check(string,pid)do
		0
	end
	#if theres casting in one operand command
	defp type_check({[command|[first|[second|[third]]]],[]},pid)do
		if(first.type == "size_type" && second.type == "operator")do
			case command.name do
			"idiv"-> 
				[{"counter",counter}] = Table.get pid,"counter" 
				Table.update pid,"counter",counter+2
				counter
			"int"-> 
				[{"counter",counter}] = Table.get pid,"counter" 
				Table.update pid,"counter",counter+2
				counter
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
			"idiv"-> 
				[{"counter",counter}] = Table.get pid,"counter" 
				Table.update pid,"counter",counter+2
				counter
			"int"-> 
			case first.name do
				"3"->
				[{"counter",counter}] = Table.get pid,"counter" 
				Table.update pid,"counter",counter+1
				counter
				_->
				[{"counter",counter}] = Table.get pid,"counter" 
				Table.update pid,"counter",counter+2
				counter
			end			
			_-> 0
		end
	end
	defp type_check({[command|first], [_|last]},pid) do
		fst = List.first(first)
		lst = List.first(last)
		{type1,name1,offset1} = op_check(first,pid)
		{type2,name2,offset2} = op_check(last,pid)
		im1 = make_implicit(name1)
		im2 = make_implicit(name2)
		synt = file("syntax.md")
		wew = Enum.find synt,fn(x)-> (x.type == [im1,im2] and x.allowed == command.name) end
		case command.name do
			"mov"->for_mov({type1,name1},{type2,im2},pid)
			"xchg"->for_xchg({type1,name1,offset1},{type2,im2,name2},pid)
			"cmp"->for_cmp({type1,im1},{type2,name2,offset2},pid)
			"xor"->for_xor({type1,name1,offset1},{type2,name2,offset2},pid)
			_->0
		end		
	end
	defp for_mov({type1,name1},{type2,name2},pid) when (name1 == :reg32 and name2 == :reg) do
		[{"counter",counter}] = Table.get pid,"counter" 
		Table.update pid,"counter",counter+2
		counter
	end
	defp for_mov({type1,name1},{type2,name2},pid) when (name1 == :reg32 and name2 == :reg) do
		[{"counter",counter}] = Table.get pid,"counter" 
		Table.update pid,"counter",counter+2
		counter
	end
	defp for_mov({type1,name1},{type2,name2},pid) when (name1 == :reg8 and name2 == :reg) do
		[{"counter",counter}] = Table.get pid,"counter" 
		Table.update pid,"counter",counter+2
		counter
	end
	defp for_mov({type1,name1},{type2,name2},pid) when (name1 == :reg8 and name2 == :reg) do
		[{"counter",counter}] = Table.get pid,"counter" 
		Table.update pid,"counter",counter+2
		counter
	end
	defp for_mov({type1,name1},{type2,name2},pid) when (name1 == :reg32 and name2 == :imm) do
		[{"counter",counter}] = Table.get pid,"counter" 
		Table.update pid,"counter",counter+5
		counter
	end
	defp for_mov({type1,name1},{type2,name2},pid) when (name1 == :reg8 and name2 == :imm) do
		[{"counter",counter}] = Table.get pid,"counter" 
		Table.update pid,"counter",counter+2
		counter
	end
	defp for_xchg({type1,name1,offset1},{type2,im2,name2},pid) when (name1 == :identifier and im2 == :reg) do
		[{"counter",counter}] = Table.get pid,"counter" 
		Table.update pid,"counter",counter+6
		counter
	end
	defp for_xchg({type1,name1,offset1},{type2,im2,name2},pid) when (name1 == :equation and im2 == :reg) do
		[{"counter",counter}] = Table.get pid,"counter" 
		Table.update pid,"counter",counter+3+offset1
		counter
	end
	defp for_xchg({type1,name1,offset1},{type2,im2,name2},pid) when (name1 == :prefix and im2 == :reg) do
		[{"counter",counter}] = Table.get pid,"counter" 
		Table.update pid,"counter",counter+4+offset1
		counter
	end
	defp for_cmp({type1,im1},{type2,name2,offset2},pid) when (im1 == :reg and name2 == :identifier) do
		[{"counter",counter}] = Table.get pid,"counter" 
		Table.update pid,"counter",counter+6
		counter
	end
	defp for_cmp({type1,im1},{type2,name2,offset2},pid) when (im1 == :reg and name2 == :prefix) do
		[{"counter",counter}] = Table.get pid,"counter" 
		Table.update pid,"counter",counter+4+offset2
		counter
	end
	defp for_cmp({type1,im1},{type2,name2,offset2},pid) when (im1 == :reg and name2 == :equation) do
		[{"counter",counter}] = Table.get pid,"counter" 
		Table.update pid,"counter",counter+3+offset2
		counter
	end
	defp for_xor({type1,name1,offset1},{type2,name2,offset2},pid) when (name1 == :equation and name2 == :hexadecimal)do
		if (type2 == :byte) do
			[{"counter",counter}] = Table.get pid,"counter" 
			Table.update pid,"counter",counter+5+offset1
			counter
		else
			[{"counter",counter}] = Table.get pid,"counter" 
			Table.update pid,"counter",counter+7+offset1
			counter
		end
	end
	defp for_xor({type1,name1,offset1},{type2,name2,offset2},pid) when (name1 == :prefix and name2 == :hexadecimal)do
		if (type2 == :byte) do
			[{"counter",counter}] = Table.get pid,"counter" 
			Table.update pid,"counter",counter+5+offset1
			counter
		else
			[{"counter",counter}] = Table.get pid,"counter" 
			Table.update pid,"counter",counter+8+offset1
			counter
		end
	end
	defp for_xor({type1,name1,offset1},{type2,name2,offset2},pid) when (name1 == :equation and name2 == :const)do
		if (type2 == :byte) do
			[{"counter",counter}] = Table.get pid,"counter" 
			Table.update pid,"counter",counter+4+offset1
			counter
		else
			[{"counter",counter}] = Table.get pid,"counter" 
			Table.update pid,"counter",counter+7+offset1
			counter
		end
	end
	defp for_xor({type1,name1,offset1},{type2,name2,offset2},pid) when (name1 == :prefix and name2 == :const)do
		if (type2 == :byte) do
			[{"counter",counter}] = Table.get pid,"counter" 
			Table.update pid,"counter",counter+5+offset1
			counter
		else
			[{"counter",counter}] = Table.get pid,"counter" 
			Table.update pid,"counter",counter+7+offset1
			counter
		end
	end
	defp for_xor({type1,name1,offset1},{type2,name2,offset2},pid) when (name1 == :equation and name2 == :string)do
		if (type2 == :byte) do
			[{"counter",counter}] = Table.get pid,"counter" 
			Table.update pid,"counter",counter+5+offset1
			counter
		else
			[{"counter",counter}] = Table.get pid,"counter" 
			Table.update pid,"counter",counter+7+offset1
			counter
		end
	end
	defp for_xor({type1,name1,offset1},{type2,name2,offset2},pid) when (name1 == :prefix and name2 == :string)do
		if (type2 == :byte) do
			[{"counter",counter}] = Table.get pid,"counter" 
			Table.update pid,"counter",counter+5+offset1
			counter
		else
			[{"counter",counter}] = Table.get pid,"counter" 
			Table.update pid,"counter",counter+7+offset1
			counter
		end
	end
	defp for_xor({type1,name1,offset1},{type2,name2,offset2},pid) when (name1 == :identifier and name2 == :string)do
		case type1 do
			:byte-> 
			[{"counter",counter}] = Table.get pid,"counter" 
			Table.update pid,"counter",counter+7
			counter
			:word-> if(type2 == :byte)do
			[{"counter",counter}] = Table.get pid,"counter" 
			Table.update pid,"counter",counter+8
			counter
			else
			[{"counter",counter}] = Table.get pid,"counter" 
			Table.update pid,"counter",counter+9
			counter
			end
			:dword->
			case type2 do
				:byte-> 
					[{"counter",counter}] = Table.get pid,"counter" 
					Table.update pid,"counter",counter+7
					counter
				:word-> 
					[{"counter",counter}] = Table.get pid,"counter" 
					Table.update pid,"counter",counter+10
					counter
				:dword-> 
					[{"counter",counter}] = Table.get pid,"counter" 
					Table.update pid,"counter",counter+10
					counter
			end
		end
	end
	defp for_xor({type1,name1,offset1},{type2,name2,offset2},pid) when (name1 == :identifier and name2 == :hexadecimal)do
		case type1 do
			:byte-> 
			[{"counter",counter}] = Table.get pid,"counter" 
			Table.update pid,"counter",counter+7
			counter
			:word-> if(type2 == :byte)do
			[{"counter",counter}] = Table.get pid,"counter" 
			Table.update pid,"counter",counter+8
			counter
			else
			[{"counter",counter}] = Table.get pid,"counter" 
			Table.update pid,"counter",counter+9
			counter
			end
			:dword->
			case type2 do
				:byte-> 
					[{"counter",counter}] = Table.get pid,"counter" 
					Table.update pid,"counter",counter+7
					counter
				:word-> 
					[{"counter",counter}] = Table.get pid,"counter" 
					Table.update pid,"counter",counter+10
					counter
				:dword-> 
					[{"counter",counter}] = Table.get pid,"counter" 
					Table.update pid,"counter",counter+10
					counter
			end
		end
	end
	defp for_xor({type1,name1,offset1},{type2,name2,offset2},pid) when (name1 == :identifier and name2 == :const)do
		case type1 do
			:byte-> 
			[{"counter",counter}] = Table.get pid,"counter" 
			Table.update pid,"counter",counter+7
			counter
			:word-> if(type2 == :byte)do
			[{"counter",counter}] = Table.get pid,"counter" 
			Table.update pid,"counter",counter+8
			counter
			else
			[{"counter",counter}] = Table.get pid,"counter" 
			Table.update pid,"counter",counter+9
			counter
			end
			:dword->
			case type2 do
				:byte-> 
					[{"counter",counter}] = Table.get pid,"counter" 
					Table.update pid,"counter",counter+7
					counter
				:word-> 
					[{"counter",counter}] = Table.get pid,"counter" 
					Table.update pid,"counter",counter+10
					counter
				:dword-> 
					[{"counter",counter}] = Table.get pid,"counter" 
					Table.update pid,"counter",counter+10
					counter
			end
		end
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
			String.to_atom(found.allowed)
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
					   "equation" -> equation_check(thd.name,:byte)
					   "prefix" ->prefix_check(thd.name,:byte)
					   "identifier"->{:byte,:identifier,0}
					   _ -> {:err,:false,0}
					end
				"word" ->
					case thd.type do
					   "equation" -> equation_check(thd.name,:dword)
					   "prefix" ->prefix_check(thd.name)
					   "identifier"->{:word,:identifier,0}
					   _ -> {:err,:false,0}
					end
				"dword" ->
					case thd.type do
					   "equation" -> equation_check(thd.name,:dword)
					   "prefix" ->prefix_check(thd.name,:dword)
					   "identifier"->{:dword,:identifier,0}
					   _ -> {:err,:false,0}
					end
				_ -> {:err,:false,0}
			end
		else
			{:err,:false,0}
		end
	end
	defp op_check(operand,pid) when (length(operand) == 1) do
		[lol] = operand
		case lol.type do
			"equation" -> equation_check(lol.name)
			"prefix" -> prefix_check(lol.name)
			"reg8" -> {:reg,:reg8,0}
			"reg32" -> {:reg,:reg32,0}
			"hexadecimal" ->h_check(lol.name)
			"string" -> str_ch(lol.name)
			"const" -> const_check(lol.name,pid)
			"identifier"->name_check(lol.name,pid)
			"label"->{:type,:label,0}
			_ -> {:err,:false,0}
		end
	end
	defp op_check(operand,pid)do
		{:err,:false}
	end
	defp name_check(thing,pid)do
		list = Table.get pid,"identifier"
		[{"identifier",{^thing,value}}] = Enum.filter(list, fn({_,{name,value}})-> name==thing end)
		type = case value.type do
			"db"->:byte
			"dw"->:word
			"dd"->:dword
		end
		{type,:identifier,0}
	end
	defp const_check(thing,pid)do
		list = Table.get pid,"identifier"
		lst = Enum.filter(list, fn({_,{name,_}})-> name == thing end)
		{"identifier",{^thing,map}} = List.last(lst)
		case map.type do
			"string"->str_ch(map.name,:const)
			"hexadecimal"->h_check(map.name,:const)
		end
	end
	defp str_ch(string,type \\ :string)do
		cond do
			String.length(string)<=3->{:byte,type,0}
			(String.length(string)>3)->{:dword,type,0}
		end
	end
	defp h_check(string,type \\ :hexadecimal)do
		cond do
			String.length(string)<=3->{:byte,type,0}
			(String.length(string)>3 and String.length(string)<=5)->{:word,type,0}
			(String.length(string)>5 and String.length(string)<=9)->{:dword,type,0}
		end
	end
	defp string_offset(eq,type \\ :type)do
		list = Regex.split ~r{(\[|\+|\*|\])},eq,trim: :true
		lst = List.last(list)
		cond do
			String.length(lst)<=3->offset = 1
			(String.length(lst)>3 and String.length(lst)<=5)->offset=2
			(String.length(lst)>5)->offset=4
		end
		{type,:equation,offset}
	end
	defp equation_check(eq,type \\ :type)do
		list = Regex.split ~r{(\[|\+|\*|\])},eq,trim: :true
		lst = List.last(list)
		cond do
			String.length(lst)<=3->offset = 1
			(String.length(lst)>3 and String.length(lst)<=5)->offset=2
			(String.length(lst)>5)->offset=4
		end
		{type,:equation,offset}
	end
	defp prefix_check(eq,type \\ :type)do
		[seg|tail] = Regex.split(~r{\:},eq)
		case seg do
			"ss"->ss_check(tail,type)
			"ds"->ds_check(tail,type)
			_->pr_check(tail,type)
		end		
	end
	defp pr_check([eq],type)do
		list = Regex.split ~r{(\[|\+|\*|\])},eq,trim: :true
		lst = List.last(list)
		cond do
			String.length(lst)<=3->offset = 1
			(String.length(lst)>3 and String.length(lst)<=5)->offset=2
			(String.length(lst)>5)->offset=4
		end
		{type,:prefix,offset}
	end
	defp ss_check([eq],type)do
		allowed = ["ebp","esp"]
		list = Regex.split ~r{(\[|\+|\*|\])},eq,trim: :true
		lst = List.last(list)
		reg = Enum.filter list,fn(x)-> x in allowed end
		cond do
			String.length(lst)<=3->offset = 1
			(String.length(lst)>3 and String.length(lst)<=5)->offset=2
			(String.length(lst)>5)->offset=4
		end
			if (reg != 0)do
				{type,:prefix,offset}
			else
				{type,:equation,offset}
			end
	end
	defp ds_check([eq],type)do
		allowed = ["eax","ebx","edx","ecx","esi","edi"]
		list = Regex.split ~r{(\[|\+|\*|\])},eq,trim: :true
		lst = List.last(list)
		reg = Enum.filter list,fn(x)-> x in allowed end
		cond do
			String.length(lst)<=3->offset = 1
			(String.length(lst)>3 and String.length(lst)<=5)->offset=2
			(String.length(lst)>5)->offset=4
		end
			if (reg != 0)do
				{type,:equation,offset}
			else
				{type,:prefix,offset}
			end
	end
end