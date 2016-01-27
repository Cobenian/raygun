defmodule Raygun.FormatTest do
  use ExUnit.Case

  defmodule Error do
    defexception [:message]
  end

  test "stacktrace_payload" do
    stacktrace = [
      {RaygunTest, :"test report_stacktrace", 1, [file: 'test/raygun_test.exs', line: 30]},
      {ExUnit.Runner, :exec_test, 2, [file: 'lib/ex_unit/runner.ex', line: 253]},
      {:timer, :tc, 1, [file: 'timer.erl', line: 166]},
      {ExUnit.Runner, :"-spawn_test/3-fun-1-", 3, [file: 'lib/ex_unit/runner.ex', line: 201]}
    ]

    error = %{
      className: "Elixir.RaygunTest",
      data: %{fileName: "test/raygun_test.exs", function: "test report_stacktrace/1", lineNumber: 30},
      innerError: nil,
      message: "error_message",
      stackTrace: [
        %{ className: "Elixir.RaygunTest", fileName: "test/raygun_test.exs", lineNumber: 30, methodName: "test report_stacktrace/1"},
        %{className: "Elixir.ExUnit.Runner", fileName: "lib/ex_unit/runner.ex", lineNumber: 253, methodName: "exec_test/2"},
        %{className: "timer", fileName: "timer.erl", lineNumber: 166, methodName: "tc/1"},
        %{className: "Elixir.ExUnit.Runner", fileName: "lib/ex_unit/runner.ex", lineNumber: 201, methodName: "-spawn_test/3-fun-1-/3"}
      ]
    }

    format = Raygun.Format.stacktrace_payload(stacktrace, %Error{message: "error_message"}, [])
    assert ^error = format.details.error
  end
end

