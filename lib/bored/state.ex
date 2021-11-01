defmodule Bored.State do
  @moduledoc """
  State of the server
  """
  @moduledoc since: "0.1.0"

  use GenServer

  @type users() :: %{String.t() => boolean()}
  @type state() :: %{
          prob_id: Bored.prob_id(),
          users: users(),
          tier: Bored.tier_range()
        }

  @doc """
  `start_link` function of `Bored.State`
  """
  @doc since: "0.1.0"
  def start_link(_args) do
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
  Add an user
  """
  @doc since: "0.1.0"
  @spec add_user(user_id :: Bored.user_id()) :: :ok
  def add_user(user_id) do
    GenServer.cast(__MODULE__, {:add_user, user_id})
  end

  @doc """
  Delete an user
  """
  @doc since: "0.1.0"
  @spec del_user(user_id :: Bored.user_id()) :: :ok
  def del_user(user_id) do
    GenServer.cast(__MODULE__, {:del_user, user_id})
  end

  @doc """
  Get tier
  """
  @doc since: "0.1.0"
  @spec get_tier() :: Bored.tier_range()
  def get_tier() do
    GenServer.call(__MODULE__, :tier)
  end

  @doc """
  Set tier range of random problem
  """
  @doc since: "0.1.0"
  @spec set_tier(tier :: Bored.tier_range()) :: :ok
  def set_tier(tier) do
    GenServer.cast(__MODULE__, {:set_tier, tier})
  end

  @doc """
  Handles the calls

  - `:curr_prob`: gets current problem id
  - `:user_list`: gets current state of users
  - `:tier`: gets current tier range
  """
  @doc since: "0.1.0"
  @spec handle_call(:curr_prob, _from :: GenServer.from(), state :: state()) ::
          {:reply, Bored.prob_id()}
  @impl true
  def handle_call(:curr_prob, _from, state) do
    {:reply, state.prob_id, state}
  end

  @doc since: "0.1.0"
  @spec handle_call(:user_list, _from :: GenServer.from(), state :: state()) :: {:reply, users()}
  @impl true
  def handle_call(:user_list, _from, state) do
    {:reply, state.users, state}
  end

  @doc since: "0.1.0"
  @spec handle_call(:tier, _from :: GenServer.from(), state :: state()) ::
          {:reply, Bored.tier_range()}
  @impl true
  def handle_call(:tier, _from, state) do
    {:reply, state.tier, state}
  end

  defp any_user_solved(state, prob_id) do
    state.users
    |> Enum.map(fn {user_id, _} -> Bored.Api.user_solved(user_id, prob_id) end)
    |> Enum.reduce(fn x, acc -> x or acc end)
  end

  defp new_rand_prob_impl(state) do
    Bored.Api.rand_prob(state.tier)
    |> Enum.reduce(0, fn x, acc ->
      if acc == 0 and !any_user_solved(state, x), do: x, else: acc
    end)
  end

  defp new_rand_prob(state) do
    prob_id = new_rand_prob_impl(state)

    unless prob_id == 0 do
      prob_id
    else
      new_rand_prob(state, 1)
    end
  end

  defp new_rand_prob(state, cnt) do
    if cnt == 20 do
      0
    else
      prob_id = new_rand_prob_impl(state)

      unless prob_id == 0 do
        prob_id
      else
        new_rand_prob(state, cnt + 1)
      end
    end
  end

  defp update_user_impl(state) do
    users =
      for {id, solved} <- state.users, into: %{} do
        unless solved do
          case Bored.Api.user_solved(id, state.prob_id) do
            {:ok, solved} -> {id, solved}
            _ -> {id, false}
          end
        else
          {id, true}
        end
      end

    prob_id =
      if users
         |> Enum.reduce(fn x, acc -> x and acc end) do
        new_rand_prob(state)
      else
        state.prob_id
      end

    {:noreply, %{state | prob_id: prob_id, users: users}}
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

  @doc since: "0.1.0"
  @spec handle_cast({:set_tier, tier :: Bored.tier_range()}, state :: state()) ::
          {:noreply, state()}
  @impl true
  def handle_cast({:set_tier, tier}, state) do
    {:noreply, %{state | tier: tier}}
  end

  @doc since: "0.1.0"
  @spec handle_cast({:add_user, user_id :: Bored.user_id()}, state :: state()) ::
          {:noreply, state()}
  @impl true
  def handle_cast({:add_user, user_id}, state) do
    {:noreply,
     %{
       state
       | users: Map.put(state.users, user_id, Bored.Api.user_solved(user_id, state.prob_id))
     }}
  end

  @doc since: "0.1.0"
  @spec handle_cast({:del_user, user_id :: Bored.user_id()}, state :: state()) ::
          {:noreply, state()}
  @impl true
  def handle_cast({:del_user, user_id}, state) do
    {:noreply, %{state | users: Map.delete(state.users, user_id)}}
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
