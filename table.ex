defmodule Table do
  @doc """
  Starts a new bucket.
  """
  def start_link do
    :ets.new(:id_table, [:duplicate_bag,:public])
  end

  def close_link(bucket)do
    :ets.delete(bucket)
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

  def delete(bucket,key)do
    :ets.delete(bucket,key)
  end

  def update(bucket,key,value)do
    delete(bucket,key)
    put(bucket,key,value)
  end
end