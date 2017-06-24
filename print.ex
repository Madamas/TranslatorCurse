defmodule Print do
	def listing(lex,pid)do
		{:ok, opid} = File.open "assembly.lst",[:write]
		Enum.map lex, fn(string)->
			fst = List.first(string)
			[{flag,msg,bytes}|tail] = fst
			if(flag == :true or flag == :warning)do
			IO.write(opid,((Hexate.encode(bytes,4))<>" "))
			end
			Enum.map tail, fn(x)->
				IO.write opid, "#{x.name} "
			end
			if(flag == :error or flag == :warning)do
			IO.write opid,"\n"<>msg<>" "
			end
			IO.write opid,"\n"
		end
	end
end