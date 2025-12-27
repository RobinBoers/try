defmodule Try do
  @readme Path.expand("../README.md", __DIR__)
  @external_resource @readme
  @moduledoc @readme
             |> File.read!()
             |> String.split("<!-- DOCS HERE -->")
             |> List.last()
             |> String.trim()

  defmacro __using__(_) do
    quote do
      import Try, only: [def: 2, defp: 2, unwrap: 1, return: 1]
      import Kernel, except: [def: 2, defp: 2]
    end
  end

  defmodule Value do
    @moduledoc false
    defstruct [:data]
  end

  defmodule Exception do
    @moduledoc false
    defexception [:reason]

    @impl true
    def message(_), do: "something went very wrong in the try library"

    @impl true
    def exception(reason) do
      %__MODULE__{reason: reason}
    end
  end

  @doc false
  defmacro def(call, body) do
    wrapped = Keyword.update!(body, :do, &wrap/1)
    quote do: Kernel.def(unquote(call), unquote(wrapped))
  end

  @doc false
  defmacro defp(call, body) do
    wrapped = Keyword.update!(body, :do, &wrap/1)
    quote do: Kernel.defp(unquote(call), unquote(wrapped))
  end

  defp wrap(block) do
    block = Macro.prewalk(block, &transform_try/1)

    quote do
      try do
        unquote(block)
      rescue
        e in Try.Exception -> {:error, e.reason}
        e -> Kernel.reraise(e, __STACKTRACE__)
      catch
        %Try.Value{data: data} -> data
        other -> Kernel.throw(other)
      end
    end
  end

  defp transform_try({:try, meta, [arg]}) when not is_list(arg) do
    {:unwrap, meta, [arg]}
  end

  defp transform_try({:try, meta, [[{key, _} | _] = kw]}) when key != :do do
    {:unwrap, meta, [kw]}
  end

  defp transform_try(other), do: other

  defmacro unwrap(expr) do
    quote do
      case unquote(expr) do
        {:ok, value} -> value
        {:error, reason} -> raise Try.Exception, reason
      end
    end
  end

  defmacro return(expr) do
    quote do
      Kernel.throw(%Try.Value{data: unquote(expr)})
    end
  end
end
