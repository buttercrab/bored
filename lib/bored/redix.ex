defmodule Bored.Redix do
  @moduledoc """
  Redix connection pool.

  Code base from: [link](https://github.com/whatyouhide/redix/blob/main/pages/Real-world%20usage.md)

  ## Examples

      iex> Supervisor.start_link([Bored.Redix], strategy: :one_for_one)
  """
  @moduledoc since: "0.1.0"

  @type error() :: atom() | Redix.Error.t() | Redix.ConnectionError.t()

  @pool_size 10

  @doc """
  Children specification of `Bored.redix`
  """
  @doc since: "0.1.0"
  @spec child_spec(uri :: String.t()) :: %{
          id: RedixSupervisor,
          type: :supervisor,
          start: {Supervisor, :start_link, {Supervisor.child_spec(), [strategy: :one_for_one]}}
        }
  def child_spec(uri) do
    # Specs for the Redix connections.
    children =
      for index <- 0..(@pool_size - 1) do
        Supervisor.child_spec({Redix, {uri, [name: :"redix_#{index}"]}}, id: {Redix, index})
      end

    # Spec for the supervisor that will supervise the Redix connections.
    %{
      id: RedixSupervisor,
      type: :supervisor,
      start: {Supervisor, :start_link, [children, [strategy: :one_for_one]]}
    }
  end

  @doc """
  Wraps `Redix.command` function
  """
  @doc since: "0.1.0"
  @spec command(command :: Redix.command()) ::
          {:ok, Redix.Protocol.redis_value()} | {:error, error()}
  def command(command) do
    Redix.command(:"redix_#{random_index()}", command)
  end

  @doc """
  Wraps `Redix.pipeline` function
  """
  @doc since: "0.1.0"
  @spec pipeline(commands :: [Redix.command()]) ::
          {:ok, [Redix.Protocol.redis_value()]} | {:error, error()}
  def pipeline(commands) do
    Redix.pipeline(:"redix_#{random_index()}", commands)
  end

  defp random_index() do
    Enum.random(0..(@pool_size - 1))
  end
end
