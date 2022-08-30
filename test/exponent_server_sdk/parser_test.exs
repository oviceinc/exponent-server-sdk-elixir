defmodule ExponentServerSdk.ParserTest do
  use ExUnit.Case

  import ExponentServerSdk.Parser

  doctest ExponentServerSdk.Parser

  test ".parse should decode a successful response into a named struct" do
    response = %{
      body:
        "{ \"data\": {\"status\": \"ok\", \"id\": \"XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX\"} }",
      status_code: 200
    }

    expected = %{"status" => "ok", "id" => "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"}
    assert {:ok, expected} == parse(response)
  end

  test ".parse should return an error when response is 400" do
    response = %{body: "{ \"errors\": \"Error message\" }", status_code: 400}
    assert {:error, "Error message", 400} == parse(response)
  end

  test ".parse_list should decode into a list of named structs" do
    json = """
    {"data":
      [
        {"status": "ok", "id": "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"},
        {"status": "ok", "id": "YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY"}
      ]
    }
    """

    response = %{body: json, status_code: 200}

    expected = [
      %{"id" => "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX", "status" => "ok"},
      %{"id" => "YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY", "status" => "ok"}
    ]

    assert {:ok, expected} == parse_list(response)
  end

  @messages [
    %{
      body: "You got your first message",
      title: "Pushed!",
      to: "ExponentPushToken[XXXXXX-XXXXXXX-XXXXXXX-XXX-XXXXXXXXX]"
    },
    %{
      body: "You got your second message",
      title: "Pushed Again!",
      to: "ExponentPushToken[YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY]"
    }
  ]

  test ".put_missing_expo_push_token should add expo_push_token when individual messages has errors " do
    result = [
      %{
        "details" => %{
          "error" => "DeviceNotRegistered",
          "fault" => "developer"
        },
        "message" => "The recipient device is not registered with FCM.",
        "status" => "error"
      },
      %{
        "details" => %{
          "error" => "DeviceNotRegistered",
          "expoPushToken" => "ExponentPushToken[YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY]"
        },
        "message" =>
          "\"ExponentPushToken[YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY]\" is not a registered push notification recipient",
        "status" => "error"
      }
    ]

    assert put_missing_expo_push_token(result, @messages) == [
             %{
               "details" => %{
                 "error" => "DeviceNotRegistered",
                 "fault" => "developer",
                 "expoPushToken" => "ExponentPushToken[XXXXXX-XXXXXXX-XXXXXXX-XXX-XXXXXXXXX]"
               },
               "message" => "The recipient device is not registered with FCM.",
               "status" => "error"
             },
             %{
               "details" => %{
                 "error" => "DeviceNotRegistered",
                 "expoPushToken" => "ExponentPushToken[YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY]"
               },
               "message" =>
                 "\"ExponentPushToken[YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY]\" is not a registered push notification recipient",
               "status" => "error"
             }
           ]
  end

  test ".put_missing_expo_push_token should not fail when details is missing from individual messages errors" do
    result = [
      %{
        "message" => "The recipient device is not registered with FCM.",
        "status" => "error"
      },
      %{
        "message" =>
          "\"ExponentPushToken[YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY]\" is not a registered push notification recipient",
        "status" => "error"
      }
    ]

    assert put_missing_expo_push_token(result, @messages) == result
  end

  test ".put_missing_expo_push_token should return exact same error when request fails" do
    result = [
      %{
        "message" => "\"[0].to\" is required.",
        "code" => "VALIDATION_ERROR",
        "isTransient" => false
      }
    ]

    assert put_missing_expo_push_token(result, @messages) == [
             %{
               "message" => "\"[0].to\" is required.",
               "code" => "VALIDATION_ERROR",
               "isTransient" => false
             }
           ]
  end
end
