defmodule Bored.State do
  @moduledoc """
  State of the server
  """
  @moduledoc since: "0.1.0"

  @type users() :: [{String.t(), boolean()}]
  @type state() :: %{
          prob_id: Bored.prob_id(),
          users: users(),
          tier: Bored.tier_range()
        }

  @doc """
  `start_link` function of `Bored.State`
  """
  @doc since: "0.1.0"
  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Initial function that sets the state
  """
  @doc since: "0.1.0"
  @spec init(_args :: term()) :: state()
  @impl true
  def init(_args) do
    schedule_update()
    {:ok, %{prob_id: 0, users: [], tier: {"Bronze V", "Ruby I"}}}
  end

  @doc """
  Get current problem id
  """
  @doc since: "0.1.0"
  @spec curr_prob() :: Bored.prob_id()
  def curr_prob() do
    GenServer.call(__MODULE__, :curr_prob)
  end

  @doc """
  Get user_list
  """
  @doc since: "0.1.0"
  @spec user_list() :: users()
  def user_list() do
    GenServer.call(__MODULE__, :user_list)
  end

  @doc """
  Update status of user solved
  """
  @doc since: "0.1.0"
  @spec update_user() :: :ok
  def update_user() do
    GenServer.cast(__MODULE__, :update_user)
  end

  @doc """
  Handles the calls

  - `:curr_prob`: gets current problem id
  - `:user_list`: gets current state of users
  """
  @doc since: "0.1.0"
  @spec handle_call(:curr_prob, state :: state()) :: {:reply, Bored.prob_id()}
  @impl true
  def handle_call(:curr_prob, state) do
    {:reply, state.prob_id, state}
  end

  @doc since: "0.1.0"
  @spec handle_call(:user_list, state :: state()) :: {:reply, users()}
  @impl true
  def handle_call(:user_list, state) do
    {:reply, state.users, state}
  end

  defp update_user_impl(state) do
    users =
      state.users
      |> Enum.map(fn {id, solved} ->
        unless solved do
          case Bored.Api.user_solved(id, state.prob_id) do
            {:ok, solved} -> {id, solved}
            _ -> {id, false}
          end
        else
          {id, true}
        end
      end)

    prob_id =
      if users |> Enum.reduce(fn x, acc -> x and acc end) do
        List.first(Bored.Api.rand_prob())
      else
        state.prob_id
      end

    {:noreply, %{prob_id: prob_id, users: users}}
  end

  @doc """
  Handles the `:update_user` call
  """
  @doc since: "0.1.0"
  @spec handle_cast(:update_user, state :: state()) :: {:noreply, state()}
  @impl true
  def handle_cast(:update_user, state) do
    update_user_impl(state)
  end

  @doc """
  Handles the repeat call `:update`
  """
  @doc since: "0.1.0"
  @spec handle_info(:update, state :: state()) :: {:noreply, state()}
  @impl true
  def handle_info(:update, state) do
    schedule_update()
    update_user_impl(state)
  end

  @user_update_time 60 * 1000

  defp schedule_update() do
    Process.send_after(self(), :update, @user_update_time)
  end
end
