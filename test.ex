defmodule Test do
	def kek do
	map1 = %{name: "data", size: "size", type: :unknown}
	map2 = %{name: "eax", size: "size", type: :unknown}
	map3 = %{name: "cmp", size: "size", type: :unknown}
	map4 = %{name: "23h", size: "size", type: :unknown}
	map5 = %{name: "a23h", size: "size", type: :unknown}
	map6 = %{name: "23", size: "size", type: :unknown}
	list = [[[map1]],[[map2],[map3]],[[map4],[map5],[map6]]]
	IO.inspect list, label: "before"
	path = Regex.replace(~r/\n/,"dict.md","")
	dict = file path
	list = Enum.map list, fn str ->
		Enum.map str, fn [x]->
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
				1 ->
					[kek]
				_ ->
				case checkType(x.name) do
					:hex -> %{x | size: "0", type: "hexadecimal"}
					:identifier -> %{x | size: "4", type: "identifier"}
					:wrong_lexem -> %{x | size: "0", type: "wrong_lexem"}				
				end
			end
		end
	end
	 #list = List.flatten(list)
	 list = Enum.reject(list,fn x -> x == nil  end) 
	 list = Enum.uniq list
	IO.inspect list, label: "Out"
	end
	defp file(path) do
		{atom, asm} = File.open path,[:utf8]
		dict = case atom do
			:error -> IO.puts "error"
			:ok -> fileHandle asm,[]
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
				string = Regex.split(~r{;},string)
				lex = stringHandle(string,lex)
				fileHandle(pid,lex)
		end
		#lex
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
	defp checkHex([]) do
		true
	end
	defp checkHex([head|tail]) do
		allowed = ["0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f"]
		if head in allowed do
			checkHex(tail)
		else
			false
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
		list = String.codepoints string
		list = List.delete_at list,String.length(string)-1
		if checkFst(String.codepoints(string)) do
			case last do
				"h" -> if checkHex(list) do
					:hex
				end
				_ -> :identifier
			end
		else
			case last do
			   "h" -> if checkHex(list) do
					 :hex
				end
				_ -> :wrong_lexem			    
			end
		end
	end
end