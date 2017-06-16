TARGET = curse

.PHONY: all clean

all: $(TARGET)

Elixir.MyCurse.beam: mycurse.ex
	elixirc mycurse.ex

Elixir.Dictionary.beam: dictionary.ex
	elixirc dictionary.ex

Elixir.Syntax.beam: syntax.ex
	elixirc syntax.ex

Elixir.Bucket.beam: bucket.ex
	elixirc bucket.ex

clean:
	rm -rvf $(TARGET) *.beam

$(TARGET): Elixir.MyCurse.beam Elixir.Dictionary.beam Elixir.Syntax.beam Elixir.Bucket.beam
	iex