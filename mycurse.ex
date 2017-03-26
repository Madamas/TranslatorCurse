defmodule MyCurse do
#use Dict
	def init do
		path = IO.gets "what\'s the path "
		path = Regex.replace(~r/\n/,path,"")
		lex = file path
		lex = Dictionary.addProp(lex)
		lex
	end
	defp file(path) do
		{atom, asm} = File.open path,[:utf8]
		lex = case atom do
			:error -> IO.puts "error"
			:ok -> fileHandle asm,[]
		end
		lex
	end
	defp fileHandle(pid,lex) do
		string = IO.read pid,:line
		case string do
			:eof -> File.close pid
			lex
			_ ->
				string = Regex.replace(~r/\t/,string,"", global: true)
				string = String.trim_trailing(string)
				string = Regex.split(~r{;},string,[parts: 2])
				lex = stringHandle(string,lex)
				fileHandle(pid,lex)
		end

	end
	defp stringHandle([head|_tail],lex) do
		str = Regex.split(~r{,},head, include_captures: true, trim: true)
		str = Enum.map str, fn(x) -> tokenHandle x end
		lex ++ str
	end

	defp tokenHandle(lexemm) do
		string = Regex.replace(~r/\"/,lexemm,"", global: true)
		string = Regex.split(~r{(\[|\]|\+|\*|\ )},string, include_captures: true, trim: true)
		Enum.map string, fn x -> [%{name: String.downcase(x),type: :unknown,size: "size"}] end
	end
end