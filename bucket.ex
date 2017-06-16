defmodule Bucket do
  @doc """
  Starts a new bucket.
  """
  def start_link do
    :ets.new(:id_table, [:duplicate_bag,:public])
  end

  @doc """
  Gets a value from the `bucket` by `key`.
  """
  def get(bucket, key) do
    :ets.lookup(bucket, key)
  end

  @doc """
  Puts the `value` for the given `key` in the `bucket`.
  """
  def put(bucket, key, value) do
    :ets.insert(bucket,{key,value})
  end
end