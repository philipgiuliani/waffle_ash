defmodule Waffle.Ash.Type do
  use Ash.Type

  require Logger

  @filename_with_timestamp ~r{^(.*)\?(\d+)$}

  @impl Ash.Type
  def constraints(),
    do: [
      definition: [
        type: :any,
        doc: "The definition to use for processing/storing the file"
      ]
    ]

  @impl Ash.Type
  def storage_type, do: :string

  @impl Ash.Type
  def cast_input(nil, _), do: {:ok, nil}

  def cast_input(%{file_name: file, updated_at: updated_at}, constraints) do
    cast_input(%{"file_name" => file, "updated_at" => updated_at}, constraints)
  end

  def cast_input(%{"file_name" => file, "updated_at" => updated_at}, _) do
    {:ok, %{file_name: file, updated_at: updated_at}}
  end

  def cast_input(args, constraints) do
    case constraints[:definition].store(args) do
      {:ok, file} ->
        {:ok,
         %{file_name: file, updated_at: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)}}

      {:error, message} = error when is_binary(message) ->
        log_error(error)
        {:error, [message: message]}

      {:error, [message: message]} = error ->
        log_error(error)
        {:error, [message: message]}

      error ->
        log_error(error)
        :error
    end
  end

  @impl Ash.Type
  def cast_stored(value, _) do
    {file_name, gsec} =
      case Regex.match?(@filename_with_timestamp, value) do
        true ->
          [_, file_name, gsec] = Regex.run(@filename_with_timestamp, value)
          {file_name, gsec}

        _ ->
          {value, nil}
      end

    updated_at =
      case gsec do
        gsec when is_binary(gsec) ->
          gsec
          |> String.to_integer()
          |> :calendar.gregorian_seconds_to_datetime()
          |> NaiveDateTime.from_erl!()

        _ ->
          nil
      end

    {:ok, %{file_name: file_name, updated_at: updated_at}}
  end

  @impl Ash.Type
  def dump_to_native(nil, _), do: {:ok, nil}

  def dump_to_native(%{file_name: file_name, updated_at: nil}, _) do
    {:ok, file_name}
  end

  def dump_to_native(%{file_name: file_name, updated_at: updated_at}, _) do
    gsec = :calendar.datetime_to_gregorian_seconds(NaiveDateTime.to_erl(updated_at))
    {:ok, "#{file_name}?#{gsec}"}
  end

  def dump_to_native(%{"file_name" => file_name, "updated_at" => updated_at}, constraints) do
    dump_to_native(%{file_name: file_name, updated_at: updated_at}, constraints)
  end

  defp log_error(error), do: Logger.error(inspect(error))

  def graphql_input_type(_), do: :string
  def graphql_type(_), do: :string
end
