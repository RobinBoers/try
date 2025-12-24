# Try

<!-- DOCS HERE -->

Black-magic fuckery that implements early returns using the `return` and `try` keywords in Elixir.

```elixir
defmodule MyModule do
  use Try

  def wibble() do
    value = try wobble()
    {:ok, value * 2}
  end

  def wobble() do
    x = :rand.uniform(10)

    if x < 5 do
      return {:error, :lower_than_5}
    end

    {:ok, x}
  end
end
```
