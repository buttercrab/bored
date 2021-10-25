defmodule Bored.Api do
  @moduledoc """
  Wrap over `Bored.Scrap` with cache Redis database
  """
  @moduledoc since: "0.1.0"

  @prob_info_timeout 60 * 60 * 24

  defp get_prob_info(prob_id) do
    with {:ok, [title, is_eng, tier]} <-
           Bored.Redix.pipeline([
             ["GET", "problem.#{prob_id}.title"],
             ["GET", "problem.#{prob_id}.is_eng"],
             ["GET", "problem.#{prob_id}.tier"]
           ]) do
      {:ok,
       %{
         id: prob_id,
         title: title,
         is_eng: if(is_eng == "1", do: true, else: false),
         tier: tier
       }}
    end
  end

  defp update_prob_info(prob_id) do
    with {:ok, info} <- Bored.Scrap.prob_info(prob_id),
         {:ok, _} <-
           Bored.Redix.pipeline([
             ["SET", "problem.#{prob_id}.title", info.title, "EX", "#{@prob_info_timeout}"],
             ["SET", "problem.#{prob_id}.is_eng", if(info.is_eng, do: "1", else: "0")],
             ["SET", "problem.#{prob_id}.tier", info.tier]
           ]) do
      {:ok, info}
    end
  end

  @doc """
  Gets problem information from Baekjoon & SolvedAc.
  """
  @doc since: "0.1.0"
  @spec prob_info(prob_id :: integer()) ::
          {:ok, %{id: integer(), title: String.t(), is_eng: true | false, tier: String.t()}}
          | {:error,
             Redix.Error.t()
             | Redix.ConnectionError.t()
             | HTTPoison.Error.t()
             | String.t()}
          | :error
  def prob_info(prob_id) do
    with {:ok, exists} <- Bored.Redix.command(["EXISTS", "problem.#{prob_id}.title"]) do
      if exists == 1,
        do: get_prob_info(prob_id),
        else: update_prob_info(prob_id)
    end
  end

  @user_info_timeout 60

  defp update_user_info(user_id) do
    with {:ok, info} <- Bored.Scrap.user_info(user_id),
         {:ok, _} <-
           Bored.Redix.pipeline([
             ["SET", "user.#{user_id}.tier", info.tier, "EX", "#{@user_info_timeout}"],
             ["DEL", "user.#{user_id}.solved"],
             ["SADD", "user.#{user_id}.solved"] ++ info.solved
           ]) do
      {:ok, info}
    end
  end

  @doc """
  Gets user tier from Baekjoon & SolvedAc.
  """
  @doc since: "0.1.0"
  @spec user_tier(user_id :: String.t()) ::
          {:ok, String.t()}
          | {:error,
             Redix.Error.t()
             | Redix.ConnectionError.t()
             | HTTPoison.Error.t()
             | String.t()}
          | :error
  def user_tier(user_id) do
    with {:ok, exists} <- Bored.Redix.command(["EXISTS", "user.#{user_id}.tier"]) do
      if exists == 1,
        do: Bored.Redix.command(["GET", "user.#{user_id}.tier"]),
        else: with({:ok, info} <- update_user_info(user_id), do: {:ok, info.tier})
    end
  end

  defp get_user_solved(user_id, prob_id) do
    with {:ok, res} <-
           Bored.Redix.command(["SISMEMBER", "user.#{user_id}.solved", prob_id]) do
      {:ok, res == 1}
    end
  end

  @doc """
  Checks if user solved the problem from Baekjoon & SolvedAc.
  """
  @doc since: "0.1.0"
  @spec user_solved(user_id :: String.t(), prob_id :: integer()) ::
          {:ok, boolean()}
          | {:error,
             Redix.Error.t()
             | Redix.ConnectionError.t()
             | HTTPoison.Error.t()
             | String.t()}
          | :error
  def user_solved(user_id, prob_id) do
    with {:ok, exists} <- Bored.Redix.command(["EXISTS", "user.#{user_id}.tier"]) do
      if exists == 1 do
        get_user_solved(user_id, prob_id)
      else
        with {:ok, _} <- update_user_info(user_id) do
          get_user_solved(user_id, prob_id)
        end
      end
    end
  end

  @doc """
  Generates random problem in given tier range from SolvedAc.
  """
  @doc since: "0.1.0"
  @spec rand_prob(tier :: {String.t(), String.t()}) ::
          {:ok, [integer()]}
          | {:error, HTTPoison.Error.t() | String.t()}
          | :error
  def rand_prob(tier) do
    Bored.Scrap.rand_prob(tier)
  end
end
