defmodule Raygun.Format do

  @moduledoc """
  This module builds payloads of error messages that Raygun will understand.
  These functions return maps of data which will be encoding as JSON prior
  to submission to Raygun.
  """

  @raygun_version Mix.Project.config[:version]

  @doc """
  Builds an error payload that Raygun will understand for a string.
  """
  def message_payload(msg, opts) do
    %{
      occurredOn: now,
      details:
        details
        |> Dict.merge( environment )
        |> Dict.merge( user(opts) )
        |> Dict.merge( custom(opts) )
        |> Dict.merge( %{error: %{ message: msg } } )
    }
  end

  @doc """
  Builds an error payload that Raygun will understand for an exception and its
  corresponding stacktrace.
  """
  def stacktrace_payload(stacktrace, exception, opts) do
    %{
      occurredOn: now,
      details:
        details
        |> Dict.merge( err(stacktrace, exception) )
        |> Dict.merge( environment )
        |> Dict.merge( user(opts) )
        |> Dict.merge( custom(opts) )
    }
  end

  @doc """
  Builds an error payload that Raygun will understand for an exception that was
  caught in our Plug.
  """
  def conn_payload(conn, stacktrace, exception, opts) do
    %{
      occurredOn: now,
      details:
        details
        |> Dict.merge( err(stacktrace, exception) )
        |> Dict.merge( environment )
        |> Dict.merge( request(conn) )
        |> Dict.merge( response(conn) )
        |> Dict.merge( user(opts) )
        |> Dict.merge( custom(opts) )
    }
  end

  @doc """
  Return custom information. Tags are configured per application via config and
  user custom data can be provided per error.
  """
  def custom(opts) do
    %{
      tags: Raygun.Util.get_env(:raygun,:tags),
		  userCustomData: Enum.into(opts |> Keyword.delete(:user), %{})
    }
  end

  @doc """
  Get the logged in user from the opts if one is provided.
  If not, it gets the system user if one is specified.
  """
  def user(opts) do
    if Keyword.has_key?(opts, :user) and Keyword.get(opts, :user) do
      %{user: Keyword.get(opts,:user)}
    else
      if Raygun.Util.get_env(:raygun, :system_user) do
        %{user: Raygun.Util.get_env(:raygun, :system_user)}
      else
        %{}
      end
    end
  end

  @doc """
  Return a map of information about the environment in which the bug was encountered.
  """
  def environment do
    # disk_free_spaces = case :disksup.start_link do
    #   {:ok, _pid} ->
    #     disks = :disksup.get_disk_data
    #     for {_mount_point, capacity, percent_used} <- disks do
    #       ((100-percent_used)/100) * capacity
    #     end
    #   _ -> []
    # end
    disk_free_spaces = []

    {:ok, hostname} = :inet.gethostname
    hostname = hostname |> List.to_string
    {os_type, os_flavor} = :os.type
    os_version = "#{os_type} - #{os_flavor}"
    architecture = :erlang.system_info(:system_architecture) |> List.to_string
    sys_version = :erlang.system_info(:system_version) |> List.to_string
    processor_count = :erlang.system_info(:logical_processors_online)
    memory_used = :erlang.memory(:total)
    %{environment: %{
        osVersion: os_version,
        architecture: architecture,
        packageVersion: sys_version,
        processorCount: processor_count,
        totalPhysicalMemory: memory_used,
        deviceName: hostname,
        diskSpaceFree: disk_free_spaces,
      }
    }
  end

  @doc """
  Returns deatils about the client and server machine.
  """
  def details do
    {:ok, hostname} = :inet.gethostname
    hostname = hostname |> List.to_string

    %{
    		machineName: hostname,
    		version: @raygun_version,
    		client: %{
    			name: Raygun.Util.get_env(:raygun, :client_name),
    			version: Raygun.Util.get_env(:raygun, :client_version),
    			clientUrl: Raygun.Util.get_env(:raygun, :url),
    		}
    }
  end

  @doc """
  Get the current time in ISO 8601 format.

  If you see an error sending messages to Raygun that looks like:
  ```
  :ets.lookup(:tzdata_current_release, :release_version)
  ```
  then you need to add :tzdata to your list of applications in your mix.exs file.
  """
  def now do
    {:ok, datetime} = Timex.Date.now |> Timex.DateFormat.format("{ISOz}")
    datetime
  end

  @doc """
  Given a Plug Conn return a map containing information about the request.
  """
  def request(conn) do
    %{request: %{
        hostName: conn.host,
        url: "#{Atom.to_string(conn.scheme)}://#{conn.host}:#{conn.port}#{conn.request_path}",
        httpMethod: conn.method,
        iPAddress: conn.remote_ip |> :inet.ntoa |> List.to_string,
        queryString: Plug.Conn.fetch_query_params(conn).query_params,
        form: Plug.Parsers.call(conn, []).params,
        headers: Raygun.Util.format_headers(conn.req_headers),
        rawData: %{}
      }
    }
  end

  @doc """
  Given a Plug Conn return a map containing information about the response.
  """
  def response(conn) do
    %{response: %{
        statusCode: conn.status
      }
    }
  end

  @doc """
  Given a stacktrace and an exception, return a map with the error data.
  """
  def err(stacktrace, error) do
    s0 = Enum.at(stacktrace, 0) |> stacktrace_entry
    %{error: %{
        innerError: nil,
        data: %{fileName: s0.fileName, lineNumber: s0.lineNumber, function: s0.methodName},
        className: s0.className,
        message: Exception.message(error),
        stackTrace: stacktrace(stacktrace)
      }
    }
  end

  @doc """
  Given a stacktrace return a list of maps for the frames.
  """
  def stacktrace(s) do
    s |> Enum.map(&stacktrace_entry/1)
  end

  @doc """
  Given a stacktrace frame, return a map with the information in a structure
  that Raygun will understand.
  """
  def stacktrace_entry({function, arity_or_args, location}) do
    stacktrace_entry {__MODULE__, function, arity_or_args, location}
  end
  def stacktrace_entry({module, function, arity_or_args, location}) do
    %{
      lineNumber: Raygun.Util.line_from(location),
      className: Raygun.Util.mod_for(module),
      fileName: Raygun.Util.file_from(location),
      methodName: Raygun.Util.function_and_arity(function,arity_or_args)
    }
  end

end
