defmodule RaygunTest do
  use ExUnit.Case
  import :meck

  defmodule MyAppError do
    defexception [:message]
  end

  setup do
    new([HTTPoison, Poison])
    on_exit(fn -> unload() end)
    :ok
  end

  test "report_stacktrace with successful response" do
    response = %HTTPoison.Response{status_code: 202}

    expect(Raygun.Format, :stacktrace_payload, [:stacktrace, :error, []], :payload)
    expect(Poison, :encode!, [:payload], :json)
    expect(HTTPoison, :post, ["https://api.raygun.io/entries", :json, :_, []], {:ok, response})

    assert Raygun.report_stacktrace(:stacktrace, :error) == :ok
  end
end
