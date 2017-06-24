defmodule Dictionary do
	def addProp(list) do
	dict = file("dict.md")
	|> Kernel.++([%{name: ",",type: "divider", size: "1"}])
	list = Enum.map list, fn str ->
		Enum.map str, fn x->
			kek = "not"
			kek = Enum.map dict, fn y->
				if x.name == y.name do
					elem = %{x | size: y.size, type: y.type}
					kek = "in"
				end
				case kek do
					"in" -> elem
					"not" -> "not"
				end
			end
			kek = Enum.uniq kek
			kek = kek -- ["not"]
			num = Enum.count kek
			case num do
				1 -> List.first(kek)
				_ ->
				case checkType(x.name) do
					:hex -> %{x | size: "0", type: "hexadecimal"}
					:identifier -> %{x | size: "4", type: "identifier"}
					:wrong_lexem -> %{x | size: "0", type: "wrong_lexem"}
					:string -> 	%{x | size: "#{(String.length(x.name)-2)*2}", type: "string"}
					:label -> %{x | size: "0", type: "label"}
					:equation -> %{x | size: "0", type: "equation"}
					:prefix -> %{x | size: "0", type: "prefix"}
					:nil -> %{x | size: "0", type: "wrong_lexem"}
				end
			end
		end
	end
	list
	end
	def make_const(lex)do
		pid = Table.start_link
		lex = Enum.map lex, fn(string)->
			case length(string)do
				2-> [first|[second]] = string
				if(first.type == "identifier" && second.type == "segment")do
					[%{first | type: "seg_identifier"},second]
				else
					string
				end
				3-> [first|[second|[third]]] = string
				if(first.type == "identifier" && second.type == "directive" && (third.type == "hexadecimal" || third.type == "string"))do
					[%{first | type: "const"},second,third]
				else
					string
				end
				_->string
			end
		end
		Enum.map lex,fn(string)->
			case (length(string))do
				1-> [one] = string
				if(one.type == "label")do
					base = byte_size(one.name)-1
					name = binary_part(one.name, 0, base)
					Table.put(pid,"identifier",{name,one})
					Table.put(pid,one.type,{name,one})
				end
				2->[first|[second]] = string
					if(first.type == "seg_identifier")do
						Table.put(pid,first.type,first.name)
					end
				3->[first|[second|[third]]] = string
					case first.type do
						"identifier"-> Table.put(pid,first.type,{first.name,%{third|type: "#{second.name}"}})
						"const"-> Table.put(pid,"identifier",{first.name,third})
							Table.put(pid,first.type,{first.name,third})
						_-> :nil
					end
				_-> :nil
			end
		end
		{lex,pid}
	end
	def const_correct(lex,pid)do
		list = Table.get(pid,"const")
		llist = Table.get(pid,"label")
		lnames = Enum.map llist, fn(x)->
			{_,{name,_}} = x
			name
		end
		names = Enum.map list, fn(x)->
			{_,{name,_}} = x
			name
		end
		Table.close_link(pid)
		lex = Enum.map lex, fn(string)->
			Enum.map string,fn(x)->
				if(x.type == "identifier")do
					if(x.name in names)do
						%{name: x.name,type: "const",size: x.size,string: x.string}
					else
						x
					end
				else
					x
				end
			end
		end
		Enum.map lex, fn(string)->
			Enum.map string,fn(x)->
				if(x.type == "identifier")do
					if(x.name in lnames)do
						%{x| type: "label"}
					else
						x
					end
				else
					x
				end
			end
		end
	end
	defp file(path) do
		{atom, pid} = File.open path,[:utf8]
		dict = case atom do
			:error -> IO.puts "error"
			:ok -> fileHandle pid,[]
		end
		dict
	end
	defp fileHandle(pid,lex) do
		string = IO.read pid,:line
		case string do
			:eof -> File.close pid
			lex
			_ ->
				string = Regex.replace(~r/\n/,string,"", global: true)
				|> (&Regex.split(~r{;},&1)).()
				lex = stringHandle(string,lex)
				fileHandle(pid,lex)
		end
	end
	defp stringHandle([head|_tail],lex) do
		str = Regex.split(~r{,},head)
		|> tokenHandle
		lex ++ [str]
	end

	defp tokenHandle([head|tail]) do
		[h|t] = tail
		%{name: head,size: List.first(t),type: h}
	end
	def checkHex([]) do
		true
	end
	def checkHex([head|tail]) do
		allowed = ["0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f"]
		if head in allowed do
			checkHex(tail)
		else
			false
		end
	end
	defp checkId([]) do
		true
	end
	defp checkId([head|tail]) do
		illegal = ["@","_","!","?","&",".","[","]"]
		if head in illegal do
			false
		else
			checkId(tail)
		end
	end
	#just pass String.codepoints(string)
	#check if first symbol is letter
	defp checkFst([head|_tail]) do
		case Integer.parse(head) do
			{_num,""} -> false
			_ -> true
		end
	end
	defp checkType(string) do
		base = byte_size(string)-1
		last = binary_part(string,base,byte_size(string)-base)
		fst = binary_part(string,0,1)
		seg = binary_part(string,0,2)
		list = String.codepoints(string)
		hex = String.codepoints(binary_part(string, 0, base))
		if (length(list)>4) do
		mid = binary_part(string, 2, 2)
		else
		mid = "wut"
		end
		seg_list = ["cs","ds","ss","es","fs","gs"]
		|> (&List.delete_at(&1,(String.length(string)-1))).()
		if checkFst(String.codepoints(string)) do
			case last do
				"h" -> if checkHex(hex) do
					:hex
				else
					:wrong_lexem
				end
				"]"-> if (fst == "[") do
				:equation
				else if ((seg in seg_list) && (mid == ":[")) do
				:prefix
				end
				end
				"\""->
				:string
				":"->
				:label
				_ ->
				if checkId(list) do
					:identifier
				else
					:wrong_lexem
				end
			end
		else
			case last do
			   "h" -> if checkHex(hex) do
					 :hex
				else
					:identifier
				end
				":"->
				:label
				_ -> 
					if checkId(list) do
						:identifier
					else
						:wrong_lexem
					end			    
			end
		end
	end
end