defmodule TwitterTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.HttpcRaw

  setup_all do
    :inets.start
    ExVCR.Config.cassette_library_dir("test/fixture/cassettes")
  end

  setup do
    client = Twitter.create(consumer_key, consumer_secret)
    {:ok, client: client}
  end

  test "#get_request_token/1 returns the consumers tokens", %{client: client} do
    use_cassette "request_token" do
      {:ok, tokens} = Twitter.get_request_tokens(client)
      assert(tokens == consumer_credentials)
    end
  end

  test "#get_access_token/2 returns client tokens", %{client: client} do
    use_cassette "client_access_token" do
      Twitter.set_request_tokens(client, consumer_token, consumer_secret)
      {:ok, tokens} = Twitter.get_access_tokens(client, verifier)
      assert(tokens == client_credentials)
    end
  end

  test "#get/2 returns the decoded JSON body of the response", %{client: client} do
    use_cassette "verify_token" do
      Twitter.set_access_tokens(client, client_token, client_token_secret)
      {:ok, result} = Twitter.get(client, '/account/verify_credentials.json')
      assert(97178399 == result["id"])
    end
  end

  defp consumer_key, do: 'GqIqgt4oiUX50yXXmcIcgsvHx'
  defp consumer_secret, do: 'X9Ea7YnG5tIJmRj9k1gWZ6nf6x3mZ7zi2NGO4fNjIuphUIrnqr'

  defp consumer_token, do: 'ppSZs1wjVRB9Qzn9rTO5AGdo0Q55MByr'
  defp consumer_token_secret, do: 'tTJQt5BshROmAjVKm2gNfuWHCNpJVMoK'

  defp consumer_credentials, do: {consumer_token, consumer_token_secret}

  defp verifier, do: 'tCiVGwgbaKgW7DxCEiYOTUe65qlDAd3p'

  defp client_token, do: '97178399-UKyCuDOmHeXBVn6SDtTipt0EuVC8LSPrgO3igOqEy'
  defp client_token_secret, do: '38POBYgidpMkKJlTv1HJKSQp3vDKv1JWjKXii4IHa2Adw'

  defp client_credentials, do: {client_token, client_token_secret}
end
