defmodule Twitter do
  @request_token_url 'https://api.twitter.com/oauth/request_token'
  @access_token_url 'https://api.twitter.com/oauth/access_token'
  @authorize_url 'https://twitter.com/oauth/authorize'
  @prefix 'https://api.twitter.com/1.1'

  def request_token(key, secret) do
    consumer = {key, secret, :hmac_sha1}
    {:ok, response} = :oauth.get(@request_token_url, [], consumer)
    request_token_params = :oauth.params_decode(response)
    request_token = :oauth.token(request_token_params)
    request_token_secret = :oauth.token_secret(request_token_params)
    request_tokens = {request_token, request_token_secret}
    {consumer, request_tokens}
  end

  def authorize_url(_request_tokens = {request_token, _request_token_secret}) do
    :oauth.uri(@authorize_url, [{'oauth_token', request_token}])
  end

  def access_token(consumer, request_tokens) do
    access_token(consumer, request_tokens, [])
  end

  def access_token(consumer, _request_tokens = {request_token, request_token_secret}, params) do
    {:ok, response} = :oauth.get(@access_token_url, params, consumer, request_token, request_token_secret)
    access_token_params = :oauth.params_decode(response)
    access_token = :oauth.token(access_token_params)
    access_token_secret = :oauth.token_secret(access_token_params)
    {access_token, access_token_secret}
  end

  def client_access_token(consumer, request_tokens, verifier) do
    params = [{'oauth_verifier', verifier}]
    access_token(consumer, request_tokens, params)
  end

  # Only use with json.
  def get(path, params, consumer, _access_tokens = {access_token, access_token_secret}) do
    url = @prefix ++ path
    {:ok, response} = :oauth.get(url, params, consumer, access_token, access_token_secret, [body_format: :binary])
    {{'HTTP/1.1', 200, 'OK'}, _headers, body} = response
    {:ok, decoded_body} = JSEX.decode(body)
    decoded_body
  end
end
