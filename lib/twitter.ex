defmodule Twitter do
  @request_token_url 'https://api.twitter.com/oauth/request_token'
  @access_token_url 'https://api.twitter.com/oauth/access_token'
  @authorize_url 'https://twitter.com/oauth/authorize'
  @prefix 'https://api.twitter.com/1.1'

  use GenServer

  # API

  def create(key, secret) do
    {:ok, pid} = GenServer.start(__MODULE__, {key, secret}, [])
    pid
  end

  def get_request_tokens(client) do
    GenServer.call(client, :get_request_tokens)
  end

  def authorize_url(client) do
    GenServer.call(client, :authorize_url)
  end

  def get_access_tokens(client, verifier) do
    GenServer.call(client, {:get_access_tokens, verifier})
  end

  def set_access_tokens(client, token, token_secret) do
    GenServer.call(client, {:set_access_tokens, token, token_secret})
  end

  def set_request_tokens(client, token, token_secret) do
    GenServer.call(client, {:set_request_tokens, token, token_secret})
  end

  def get(client, path, params \\ []) do
    GenServer.call(client, {:get, path, params})
  end

  # Callbacks

  def init({key, secret}) do
    consumer = {key, secret, :hmac_sha1}
    state = %{consumer: consumer, request_tokens: nil, tokens: nil}
    {:ok, state}
  end

  def handle_call(:get_request_tokens, _from, state) do
    {:ok, response} = :oauth.get(@request_token_url, [], state.consumer)
    request_token_params = :oauth.params_decode(response)
    request_token = :oauth.token(request_token_params)
    request_token_secret = :oauth.token_secret(request_token_params)
    next_state = %{state | request_tokens: {request_token, request_token_secret}}
    {:reply, {:ok, next_state.request_tokens}, next_state}
  end

  def handle_call(:authorize_url, _from, state) do
    {token, _token_secret} = state.request_tokens
    uri = :oauth.uri(@authorize_url, [{'oauth_token', token}])
    {:reply, {:ok, uri}, state}
  end

  def handle_call({:get_access_tokens, verifier}, _from, state) do
    {token, token_secret} = state.request_tokens
    params = [{'oauth_verifier', verifier}]
    {:ok, response} = :oauth.get(@access_token_url, params, state.consumer, token, token_secret)
    access_token_params = :oauth.params_decode(response)
    access_token = :oauth.token(access_token_params)
    access_token_secret = :oauth.token_secret(access_token_params)
    next_state = %{state | tokens: {access_token, access_token_secret}}
    {:reply, {:ok, next_state.tokens}, next_state}
  end

  def handle_call({:set_access_tokens, token, token_secret}, _from, state) do
    next_state = %{state | tokens: {token, token_secret}}
    {:reply, {:ok, next_state.tokens}, next_state}
  end

  def handle_call({:set_request_tokens, token, token_secret}, _from, state) do
    next_state = %{state | request_tokens: {token, token_secret}}
    {:reply, {:ok, next_state.request_tokens}, next_state}
  end

  def handle_call({:get, path, params}, _from, state) do
    url = @prefix ++ path
    {token, token_secret} = state.tokens
    {:ok, response} = :oauth.get(url, params, state.consumer, token, token_secret, [body_format: :binary])
    {{'HTTP/1.1', 200, 'OK'}, _headers, body} = response
    reply = JSEX.decode(body)
    {:reply, reply, state}
  end
end
