ExponentServerSdk
========

**This is an oVice fork of the original [ExponentServerSdk](https://github.com/rdrop/exponent-server-sdk-elixir) project which is heavily outdated and does not support newer Elixir versions.**

_Some tests may fail because the library doesn't mock API calls but executes them with incorrect tokens instead_

Use to send push notifications to Exponent Experiences from an Elixir/Phoenix server.

## Installation

ExponentServerSdk is currently able to push single and multiple messages to the Expo Server and retrieve message delivery statuses from a list of IDs.

All HTTPoison Post Request body are automatically GZIP compressed.

You can install from Github:

```elixir
def deps do
  [{:exponent_server_sdk, git: "https://github.com/oviceinc/exponent-server-sdk-elixir.git"}]
end
```

and run `mix deps.get`.

Now, list the `:exponent_server_sdk` application as your application dependency:

```elixir
def application do
  [extra_applications: [:exponent_server_sdk]]
end
```
## Fork's features

This fork supports setting up an access token to be used as bearer token when communication with Expo's APIs. [More in here.](https://docs.expo.dev/push-notifications/sending-notifications/#additional-security)

It's done by setting up a similar module config:

```elixir
config :exponent_server_sdk,
       :access_token,
       System.get_env("EXPO_ACCESS_TOKEN", "MY_ACCESS_TOKEN")
```

## Usage


### Notifications

The `ExponentServerSdk.PushNotification` is responsible for sending the messages and hits the latest version of the api.

#### Single Message:

```elixir

# Create a single message map
message = %{
    to: "ExponentPushToken[XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX]",
    title: "Pushed!",
    body: "You got your first message"
  }

# Send it to Expo
{:ok, response} = ExponentServerSdk.PushNotification.push(message)

# Example Response
{:ok, %{"status" => "ok", "id" => "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"}}
```

#### Multiple Messages:
```elixir

# Create a list of message maps (auto chunks list into lists of 100)
message_list = [
  %{
    to: "ExponentPushToken[XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX]",
    title: "Pushed!",
    body: "You got your first message"
  },
  %{
    to: "ExponentPushToken[YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY]",
    title: "Pushed Again!",
    body: "You got your second message"
  }
]

# Send it to Expo
{:ok, response} = ExponentServerSdk.PushNotification.push_list(messages)

# Example Response
{:ok,[ %{"status" => "ok", "id" => "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"}, %{"status" => "ok", "id" => "YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY"} ]}
```

#### Get Messages Delivery Statuses:
```elixir

# Create a list of message ids
ids = ["XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX", "YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY"]

# Send it to Expo
{:ok, response} = ExponentServerSdk.PushNotification.get_receipts(ids)

# Example Response
{:ok,[ %{ "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX": %{ "status": "ok" }, "YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY": %{ "status": "ok" } } ]}
```

The complete format of the messages can be found [here.](https://docs.expo.io/versions/latest/guides/push-notifications#message-format)

## Contributing

See the [CONTRIBUTING.md](CONTRIBUTING.md) file for contribution guidelines.

## License
ExponentServerSdk is licensed under the MIT license. For more details, see the `LICENSE`
file at the root of the repository. It depends on Elixir, which is under the
Apache 2 license.

### Inspiration
[ex_twilio](https://github.com/danielberkompas/ex_twilio)

[hex]: http://hex.pm
