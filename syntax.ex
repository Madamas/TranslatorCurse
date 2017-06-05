defmodule Syntax do
	def checkSyntax(lex) do
		syntax = parseRules("syntax.md")
		list = Enum.map lex, fn str ->
			string = Enum.map str, fn x->
				case x.name do
					"cli"-> x.name
					"mov"-> x.name
					"xor"-> x.name
					"cmp"-> x.name
					"int"-> x.name
					"idiv"-> x.name
					"xchg"-> x.name
					"jcxz"-> x.name
					"end"-> x.name
					"ends"-> x.name
					"db"-> x.name
					_ -> x.type
				end
			end
		end
		analysis = Enum.map list, fn str ->
			Enum.member?(syntax, str)
		end
		analysis
	end
	defp parseRules(path) do
		{atom,pid} = File.open path,[:utf8]
		syntax = case  atom do
		   :error -> IO.puts "error"
		   :ok ->  fileHandle pid,[]
		end
		syntax
	end
	defp fileHandle(pid,syntax) do
		string = IO.read pid,:line
		case string do
			:eof -> File.close pid
			syntax
			_ ->
				string = Regex.replace(~r/\n/,string,"", global: true)
				|> (&Regex.split(~r{\ },&1,trim: true)).()
				syntax = stringHandle(string,syntax)
				fileHandle(pid,syntax)
		end
	end
	defp stringHandle(list,syntax) do
		syntax ++ [list]
	end
end