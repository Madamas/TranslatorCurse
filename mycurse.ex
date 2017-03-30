defmodule MyCurse do
	def init do
		path = IO.gets "what\'s the path "
		lex = Regex.replace(~r/\n/,path,"")
		|>file()
		|>Dictionary.addProp
		sendMidData lex
		lex
	end
	defp sendMidData(what) do
		{:ok, opid} = File.open "out.md",[:write]
		Enum.map what, fn str ->
			Enum.map str, fn [x] ->
				IO.write opid, "\"#{x.name}\""<>" "<>x.type<>"\n"
			end
			IO.puts opid, ""
		end
		File.close opid
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
				|>String.trim_trailing()
				|> (&Regex.split(~r{;},&1,[parts: 2])).()
				lex = stringHandle(string,lex)
				fileHandle(pid,lex)
		end

	end
	defp stringHandle([head|_tail],lex) do
		str = Regex.replace(~r/\"/,head,"", global: true)
		|> (&Regex.split(~r{(\[|\]|\+|\*|\ |\,)},&1, include_captures: true, trim: true)).()
		|> Enum.map(fn x -> [%{name: String.downcase(x),type: :unknown,size: "size"}] end)
		lex ++ [str]
	end
end