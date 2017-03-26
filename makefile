TARGET = curse

.PHONY: all clean

all: $(TARGET)

Elixir.MyCurse.beam: mycurse.ex
	elixirc mycurse.ex

Elixir.Dictionary.beam: dictionary.ex
	elixirc dictionary.ex

clean:
	rm -rvf $(TARGET) *.beam

$(TARGET): Elixir.MyCurse.beam Elixir.Dictionary.beam
	iex