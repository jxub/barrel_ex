defmodule Mix.Tasks.Fix do
  use Mix.Task

  @shortdoc "Fixes version number fetched incorrectly by mix in a package"

  @moduledoc """
  Run without any argument:

  ```
  $ mix fix
  ```
  """

  def run(_args) do
    Mix.shell().cmd(~s(rm -r ./_build/))
    Mix.shell().cmd(~s(sed -i "s/1.2.0/2.0.1/g" ./deps/hooks/mix.exs))
    Mix.shell().cmd(~s(mix compile))
  end
end
