defmodule TwitterTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.HttpcRaw

  setup_all do
    :inets.start
    ExVCR.Config.cassette_library_dir("test/fixture/cassettes")
    ExVCR.Config.format(:raw)
    :ok
  end

  test "#request_token/2 returns consumer's tokens from key & secret" do
    use_cassette "request_token" do
      {consumer, tokens} = Twitter.request_token(consumer_key, consumer_secret)
      assert(consumer == consumer)
      assert(tokens == consumer_credentials)
    end
  end

  test "#client_access_token/3 get client credentials using a consumer, consumer_credentials & verification code" do
    use_cassette "client_access_token" do
      tokens = Twitter.client_access_token(consumer, consumer_credentials, verifier)
      assert(tokens == client_credentials)
    end
  end

  test "#get/4 returns the decoded JSON body of the response" do
    use_cassette "verify_token" do
      result = Twitter.get('/account/verify_credentials.json', [], consumer, client_credentials)
      assert(97178399 == result["id"])
    end
  end

  defp consumer_key, do: 'GqIqgt4oiUX50yXXmcIcgsvHx'
  defp consumer_secret, do: 'X9Ea7YnG5tIJmRj9k1gWZ6nf6x3mZ7zi2NGO4fNjIuphUIrnqr'

  defp consumer_token, do: 'ppSZs1wjVRB9Qzn9rTO5AGdo0Q55MByr'
  defp consumer_token_secret, do: 'tTJQt5BshROmAjVKm2gNfuWHCNpJVMoK'

  defp consumer_credentials, do: {consumer_token, consumer_token_secret}
  defp consumer, do: {consumer_key, consumer_secret, :hmac_sha1}

  defp client_token, do: '97178399-UKyCuDOmHeXBVn6SDtTipt0EuVC8LSPrgO3igOqEy'
  defp client_token_secret, do: '38POBYgidpMkKJlTv1HJKSQp3vDKv1JWjKXii4IHa2Adw'

  defp verifier, do: 'tCiVGwgbaKgW7DxCEiYOTUe65qlDAd3p'

  defp client_credentials, do: {client_token, client_token_secret}
end
