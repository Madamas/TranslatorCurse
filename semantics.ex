defmodule Semantics do
	def check_sem([lex|tail],seg1,seg2)do
		[first|[second|tail]] = lex
		if (first == true && second.type == "identifier") do
			[flag|[fst|[sec|tail]]] = lex
			if(sec.type == "segment")do
				case sec.name do
					"segment"->
					"ends"->
				end
			end
		else

		end
	end
end