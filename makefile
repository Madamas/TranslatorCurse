TARGET = curse

.PHONY: all clean

all: $(TARGET)

Elixir.MyCurse.beam: mycurse.ex
	elixirc mycurse.ex

Elixir.Dictionary.beam: dictionary.ex
	elixirc dictionary.ex

Elixir.Syntax.beam: syntax.ex
	elixirc syntax.ex

Elixir.Table.beam: table.ex
	elixirc table.ex

Elixir.Semantics.beam: semantics.ex
	elixirc semantics.ex

clean:
	rm -rvf $(TARGET) *.beam

$(TARGET): Elixir.MyCurse.beam Elixir.Dictionary.beam Elixir.Syntax.beam Elixir.Table.beam
	iex