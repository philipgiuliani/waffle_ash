defmodule Waffle.Ash.CastAttachments do
  use Ash.Resource.Change

  def change(changeset, args_to_fields, _) do
    Ash.Changeset.before_action(changeset, fn changeset ->
      args_to_fields
      |> Enum.reject(fn {argument, _} ->
        is_nil(Ash.Changeset.get_argument(changeset, argument))
      end)
      |> Enum.reduce(changeset, fn {argument, attribute}, changeset ->
        case Ash.Changeset.get_argument(changeset, argument) do
          %Plug.Upload{} = upload ->
            Ash.Changeset.force_change_attribute(changeset, attribute, {upload, changeset.data})

          %{filename: filename, path: path} when is_binary(filename) and is_binary(path) ->
            upload = %{filename: filename, path: String.trim(path)}
            Ash.Changeset.force_change_attribute(changeset, attribute, {upload, changeset.data})
        end
      end)
    end)
  end
end
