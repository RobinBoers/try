defmodule TryTest do
  use ExUnit.Case
  doctest Try

  defmodule Subject do
    use Try

    def basic_unwrap(result) do
      value = unwrap(result)
      value * 2
    end

    def basic_return(x) do
      if x == 0, do: return(:early)
      x + 1
    end

    def bare_try_syntax(result) do
      value = try result
      value * 3
    end

    def multiple_unwraps(a, b) do
      x = unwrap(a)
      y = unwrap(b)
      x + y
    end

    def nested_returns(x) do
      if x > 10 do
        if x > 20, do: return(:very_high)
        return(:high)
      end

      :low
    end

    def unwrap_in_case(result) do
      case unwrap(result) do
        :foo -> :bar
        other -> other
      end
    end

    def unwrap_in_cond(result) do
      cond do
        unwrap(result) > 5 -> :big
        true -> :small
      end
    end

    def mixed_return_and_unwrap(result, flag) do
      if flag, do: return(:early)
      x = unwrap(result)
      x * 2
    end

    def function_with_existing_rescue(x) do
      try do
        if x == 0, do: raise("boom")
        unwrap({:ok, x})
      rescue
        RuntimeError -> :rescued
      end
    end

    def function_with_existing_catch(x) do
      try do
        if x == 0, do: throw(:thrown)
        unwrap({:ok, x})
      catch
        :thrown -> :caught
      end
    end

    def function_with_both_rescue_and_catch(x) do
      try do
        cond do
          x == 0 -> raise("boom")
          x == 1 -> throw(:thrown)
          true -> unwrap({:ok, x})
        end
      rescue
        RuntimeError -> :rescued
      catch
        :thrown -> :caught
      end
    end

    def nested_try_blocks(result) do
      try do
        inner = unwrap(result)

        try do
          if inner == 0, do: raise("nested boom")
          inner * 2
        rescue
          RuntimeError -> :inner_rescued
        end
      rescue
        Try.Exception -> :outer_rescued
      end
    end

    def return_inside_rescue(x) do
      try do
        if x == 0, do: raise("boom")
        :normal
      rescue
        RuntimeError -> return(:rescued_early)
      end
    end

    def unwrap_inside_rescue(result, x) do
      try do
        if x == 0, do: raise("boom")
        :normal
      rescue
        RuntimeError -> unwrap(result)
      end
    end

    def multiple_guards(x) when x > 0 do
      unwrap({:ok, x})
    end

    def multiple_guards(x) when x < 0 do
      return(:negative)
    end

    def multiple_guards(_x), do: 0

    def pipeline_unwrap(result) do
      result
      |> unwrap()
      |> Kernel.*(2)
    end

    def with_statement(a, b) do
      with x <- unwrap(a),
           y <- unwrap(b) do
        x + y
      end
    end

    def error_in_middle(a, b, c) do
      x = unwrap(a)
      y = unwrap(b)
      z = unwrap(c)
      x + y + z
    end

    def return_various_types_int(x) do
      if x == 1, do: return(42)
      :default
    end

    def return_various_types_atom(x) do
      if x == 1, do: return(:atom_value)
      :default
    end

    def return_various_types_tuple(x) do
      if x == 1, do: return({:ok, :early})
      :default
    end

    def return_various_types_list(x) do
      if x == 1, do: return([1, 2, 3])
      :default
    end

    def deeply_nested_conditions(x) do
      if x > 0 do
        if x > 10 do
          if x > 20 do
            if x > 30, do: return(:very_deep)
            return(:deep)
          end

          return(:medium)
        end

        return(:shallow)
      end

      :default
    end

    def unwrap_with_function_calls(f) do
      result = f.()
      unwrap(result)
    end

    def reraise_non_try_exceptions(x) do
      if x == 0, do: raise(ArgumentError, "not a Try.Exception")
      x
    end

    def rethrow_non_value_throws(x) do
      if x == 0, do: throw(:regular_throw)
      x
    end

    def complex_expression_unwrap(a, b) do
      (unwrap(a) + unwrap(b)) * 2
    end

    def unwrap_in_list_comprehension(results) do
      for result <- results do
        unwrap(result)
      end
    end

    def return_in_enum(list) do
      Enum.each(list, fn x ->
        if x == 5, do: return(:found_five)
      end)

      :not_found
    end
  end

  describe "basic unwrap" do
    test "unwraps {:ok, value}" do
      assert Subject.basic_unwrap({:ok, 5}) == 10
    end

    test "returns {:error, reason} on error" do
      assert Subject.basic_unwrap({:error, :something}) == {:error, :something}
    end

    test "unwraps nested ok values" do
      assert Subject.basic_unwrap({:ok, 100}) == 200
    end
  end

  describe "basic return" do
    test "returns early when condition met" do
      assert Subject.basic_return(0) == :early
    end

    test "continues normal flow when no early return" do
      assert Subject.basic_return(5) == 6
    end
  end

  describe "bare try syntax" do
    test "bare try unwraps {:ok, value}" do
      assert Subject.bare_try_syntax({:ok, 3}) == 9
    end

    test "bare try returns error" do
      assert Subject.bare_try_syntax({:error, :bad}) == {:error, :bad}
    end
  end

  describe "multiple unwraps" do
    test "all succeed" do
      assert Subject.multiple_unwraps({:ok, 3}, {:ok, 7}) == 10
    end

    test "first fails" do
      assert Subject.multiple_unwraps({:error, :first}, {:ok, 7}) == {:error, :first}
    end

    test "second fails" do
      assert Subject.multiple_unwraps({:ok, 3}, {:error, :second}) == {:error, :second}
    end

    test "both fail, first error returned" do
      assert Subject.multiple_unwraps({:error, :first}, {:error, :second}) == {:error, :first}
    end
  end

  describe "nested returns" do
    test "very high value" do
      assert Subject.nested_returns(25) == :very_high
    end

    test "high value" do
      assert Subject.nested_returns(15) == :high
    end

    test "low value" do
      assert Subject.nested_returns(5) == :low
    end
  end

  describe "unwrap in case" do
    test "unwraps and matches case" do
      assert Subject.unwrap_in_case({:ok, :foo}) == :bar
      assert Subject.unwrap_in_case({:ok, :baz}) == :baz
    end

    test "error propagates" do
      assert Subject.unwrap_in_case({:error, :oops}) == {:error, :oops}
    end
  end

  describe "unwrap in cond" do
    test "unwraps and evaluates condition" do
      assert Subject.unwrap_in_cond({:ok, 10}) == :big
      assert Subject.unwrap_in_cond({:ok, 3}) == :small
    end

    test "error propagates from cond" do
      assert Subject.unwrap_in_cond({:error, :bad}) == {:error, :bad}
    end
  end

  describe "mixed return and unwrap" do
    test "return triggers early" do
      assert Subject.mixed_return_and_unwrap({:ok, 5}, true) == :early
    end

    test "unwrap succeeds when no return" do
      assert Subject.mixed_return_and_unwrap({:ok, 5}, false) == 10
    end

    test "error propagates when no early return" do
      assert Subject.mixed_return_and_unwrap({:error, :bad}, false) == {:error, :bad}
    end
  end

  describe "existing rescue blocks" do
    test "inner rescue handles its exception" do
      assert Subject.function_with_existing_rescue(0) == :rescued
    end

    test "Try.Exception still propagates as error" do
      assert Subject.function_with_existing_rescue(5) == 5
    end
  end

  describe "existing catch blocks" do
    test "inner catch handles its throw" do
      assert Subject.function_with_existing_catch(0) == :caught
    end

    test "unwrap still works" do
      assert Subject.function_with_existing_catch(5) == 5
    end
  end

  describe "both rescue and catch" do
    test "rescue handles exception" do
      assert Subject.function_with_both_rescue_and_catch(0) == :rescued
    end

    test "catch handles throw" do
      assert Subject.function_with_both_rescue_and_catch(1) == :caught
    end

    test "unwrap works normally" do
      assert Subject.function_with_both_rescue_and_catch(5) == 5
    end
  end

  describe "nested try blocks" do
    test "inner rescue handles inner exception" do
      assert Subject.nested_try_blocks({:ok, 0}) == :inner_rescued
    end

    test "outer rescue handles Try.Exception" do
      assert Subject.nested_try_blocks({:error, :bad}) == :outer_rescued
    end

    test "normal flow when no exceptions" do
      assert Subject.nested_try_blocks({:ok, 5}) == 10
    end
  end

  describe "return inside rescue" do
    test "return from rescue block" do
      assert Subject.return_inside_rescue(0) == :rescued_early
    end

    test "normal flow when no exception" do
      assert Subject.return_inside_rescue(5) == :normal
    end
  end

  describe "unwrap inside rescue" do
    test "unwrap succeeds in rescue" do
      assert Subject.unwrap_inside_rescue({:ok, 42}, 0) == 42
    end

    test "unwrap fails in rescue" do
      assert Subject.unwrap_inside_rescue({:error, :bad}, 0) == {:error, :bad}
    end

    test "normal flow when no exception" do
      assert Subject.unwrap_inside_rescue({:ok, 42}, 5) == :normal
    end
  end

  describe "multiple guards" do
    test "positive triggers first clause" do
      assert Subject.multiple_guards(5) == 5
    end

    test "negative triggers return" do
      assert Subject.multiple_guards(-3) == :negative
    end

    test "zero triggers default" do
      assert Subject.multiple_guards(0) == 0
    end
  end

  describe "pipeline unwrap" do
    test "unwrap in pipeline succeeds" do
      assert Subject.pipeline_unwrap({:ok, 7}) == 14
    end

    test "unwrap in pipeline fails" do
      assert Subject.pipeline_unwrap({:error, :pipe}) == {:error, :pipe}
    end
  end

  describe "with statement" do
    test "both unwrap succeed" do
      assert Subject.with_statement({:ok, 3}, {:ok, 5}) == 8
    end

    test "first unwrap fails" do
      assert Subject.with_statement({:error, :a}, {:ok, 5}) == {:error, :a}
    end

    test "second unwrap fails" do
      assert Subject.with_statement({:ok, 3}, {:error, :b}) == {:error, :b}
    end
  end

  describe "error in middle of sequence" do
    test "all succeed" do
      assert Subject.error_in_middle({:ok, 1}, {:ok, 2}, {:ok, 3}) == 6
    end

    test "first fails" do
      assert Subject.error_in_middle({:error, :a}, {:ok, 2}, {:ok, 3}) == {:error, :a}
    end

    test "middle fails" do
      assert Subject.error_in_middle({:ok, 1}, {:error, :b}, {:ok, 3}) == {:error, :b}
    end

    test "last fails" do
      assert Subject.error_in_middle({:ok, 1}, {:ok, 2}, {:error, :c}) == {:error, :c}
    end
  end

  describe "return various types" do
    test "return integer" do
      assert Subject.return_various_types_int(1) == 42
      assert Subject.return_various_types_int(0) == :default
    end

    test "return atom" do
      assert Subject.return_various_types_atom(1) == :atom_value
      assert Subject.return_various_types_atom(0) == :default
    end

    test "return tuple" do
      assert Subject.return_various_types_tuple(1) == {:ok, :early}
      assert Subject.return_various_types_tuple(0) == :default
    end

    test "return list" do
      assert Subject.return_various_types_list(1) == [1, 2, 3]
      assert Subject.return_various_types_list(0) == :default
    end
  end

  describe "deeply nested conditions" do
    test "very deep" do
      assert Subject.deeply_nested_conditions(35) == :very_deep
    end

    test "deep" do
      assert Subject.deeply_nested_conditions(25) == :deep
    end

    test "medium" do
      assert Subject.deeply_nested_conditions(15) == :medium
    end

    test "shallow" do
      assert Subject.deeply_nested_conditions(5) == :shallow
    end

    test "default" do
      assert Subject.deeply_nested_conditions(-5) == :default
    end
  end

  describe "unwrap with function calls" do
    test "unwraps result from function" do
      f = fn -> {:ok, 42} end
      assert Subject.unwrap_with_function_calls(f) == 42
    end

    test "propagates error from function" do
      f = fn -> {:error, :func_error} end
      assert Subject.unwrap_with_function_calls(f) == {:error, :func_error}
    end
  end

  describe "non-Try exceptions" do
    test "re-raises ArgumentError" do
      assert_raise ArgumentError, "not a Try.Exception", fn ->
        Subject.reraise_non_try_exceptions(0)
      end
    end

    test "normal flow when no exception" do
      assert Subject.reraise_non_try_exceptions(5) == 5
    end
  end

  describe "non-value throws" do
    test "re-throws regular throw" do
      assert catch_throw(Subject.rethrow_non_value_throws(0)) == :regular_throw
    end

    test "normal flow when no throw" do
      assert Subject.rethrow_non_value_throws(5) == 5
    end
  end

  describe "complex expressions" do
    test "unwrap in arithmetic expression" do
      assert Subject.complex_expression_unwrap({:ok, 3}, {:ok, 5}) == 16
    end

    test "first error propagates" do
      assert Subject.complex_expression_unwrap({:error, :a}, {:ok, 5}) == {:error, :a}
    end
  end

  describe "list comprehension" do
    test "all succeed" do
      results = [{:ok, 1}, {:ok, 2}, {:ok, 3}]
      assert Subject.unwrap_in_list_comprehension(results) == [1, 2, 3]
    end

    test "error stops comprehension" do
      results = [{:ok, 1}, {:error, :bad}, {:ok, 3}]
      assert Subject.unwrap_in_list_comprehension(results) == {:error, :bad}
    end
  end

  describe "return in enum" do
    test "finds five and returns early" do
      assert Subject.return_in_enum([1, 2, 5, 6]) == :found_five
    end

    test "no five returns default" do
      assert Subject.return_in_enum([1, 2, 3]) == :not_found
    end
  end
end
