defmodule MyCurse do
	def init do
		path = IO.gets "what\'s the path "
		lex = Regex.replace(~r/\n/,path,"")
		|>file()
		|>Dictionary.addProp
		{lex,pid} = Dictionary.make_const lex
		lex = Dictionary.const_correct lex,pid
		sendMidData lex
		{what,pid} = Syntax.check_syntax(lex)
		what = Semantics.count_bytes(what,pid)
		#IO.inspect what,label: "what"
		Print.listing(what,pid)
		#Syntax.align_intervals what,pid
		#Table.get pid,"error"
		#lex
		#IO.inspect what
	end
	defp sendMidData(what) do
		{:ok, opid} = File.open "out.md",[:write]
		Enum.map what, fn str ->
			#IO.inspect str,label: "INTERMEDIATE"
			Enum.map str, fn x ->
				#IO.inspect x, label: "INSIDE"
				IO.write opid, "#{x.name}"<>" "<>x.type<>"\n"
			end
			IO.puts opid, ""
		end
		File.close opid
	end
	defp file(path) do
		{atom, asm} = File.open path,[:utf8]
		lex = case atom do
			:error -> IO.puts "error"
			:ok -> fileHandle asm,[],1
		end
		lex
	end
	defp fileHandle(pid,lex,num) do
		string = IO.read pid,:line
		case string do
			:eof -> File.close pid
			lex
			_ ->
				string = Regex.replace(~r/\t/,string,"", global: true)
				|>String.trim_trailing()
				|> (&Regex.split(~r{;},&1,[parts: 2])).()
				lex = stringHandle(string,lex,num)
				fileHandle(pid,lex,num+1)
		end

	end
	defp stringHandle([head|_tail],lex,num) do
		#\[|\]|\+|\*| just in case if you need this in future (don't forget to add this into regex)
		str = Regex.split(~r{(\,|\=)},head, include_captures: true, trim: true)
		|> (&for x <- &1, do: Regex.split(~r{\ },x,trim: true)).()
		|> List.flatten()
		|> Enum.map(fn x -> %{name: String.downcase(x),type: :unknown,size: "size",string: num} end)
		if (str == []) do
			lex
		else
			lex ++ [str]
		end
	end
end
