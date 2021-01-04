# google_pubsub_grpc

API wrapper around [Google Pub Sub gRPC protocol](https://cloud.google.com/pubsub/docs/reference/rpc). Code in `lib/google/pubsub/v1/pubsub.pb.ex` is generated using the `protoc` utility. Check [protobuf-elixir package](https://github.com/tony612/protobuf-elixir) for more details, if interested.

The only thing this package adds to the auto-generated client code is a few helper methods.

## Installation

Add the following to your `mix.exs`:

```elixir
def deps do
  [
    {:goth, "~> 1.2.0"},
    {:cowlib, "~> 2.9.0", override: true},
    {:google_protos, "~> 0.1.0"},
    {:grpc, github: "elixir-grpc/grpc", override: true},
    {:google_pubsub_grpc, "~> 0.1.0"}
  ]
end
```

## Configuration

Set the environment variable `GOOGLE_APPLICATION_CREDENTIALS` to point to a gcloud credentials file.

The [goth package](https://github.com/peburrows/goth) shows more ways to configure access, e.g.:
```elixir
config :goth, json: File.read!(System.get_env("GOOGLE_APPLICATION_CREDENTIALS"))
```

After configuration, Google project id is available by calling helper functions `Google.Pubsub.GRPC.project_id()` or `Google.Pubsub.GRPC.full_project_id()` (with `"projects/"` prepended to it.

## Emulator Support

Method `Google.Pubsub.GRPC.channel` checks environment variable `PUBSUB_EMULATOR_HOST` and if present (e.g. `localhost:8787`) uses its value as the server endpoint.

```elixir
{:ok, channel} = Google.Pubsub.GRPC.channel()
```

To define Google project id for the emulator use goth configuration like so:
```elixir
config :goth, json: nil, project_id: "emulator-project-id"
```

## API Usage

Note that project id, topic and subscription names are passed to the grpc client in their "full" form, e.g. `"projects/my-project/topics/my-topic"`. There are a couple of helper functions in the `Google.Api.PubSub.GRPC` module to convert between the full form and its shorter variant, e.g. `"my-topic"`.

To get a channel (connection to server):
```elixir
{:ok, channel} = Google.Pubsub.GRPC.channel()
```
Additional options are `interceptors` and `accepted_compressors`:
```elixir
{:ok, channel} = Google.Pubsub.GRPC.channel(interceptors: [GRPC.Logger.Client])
{:ok, channel} = Google.Pubsub.GRPC.channel(interceptors: [{GRPC.Logger.Client, level: :info}]
{:ok, channel} = Google.Pubsub.GRPC.channel(accepted_compressors: [GRPC.Compressor.Gzip])
```

To get the list of topics:
```elixir
request =
  Google.Pubsub.V1.ListTopicsRequest.new(project: Google.Pubsub.GRPC.full_project_id())

{:ok, response} = channel |> Google.Pubsub.V1.Publisher.Stub.list_topics(request)
```

To get topic's details:
```elixir
request =
  Google.Pubsub.V1.GetTopicRequest.new(
    topic: Google.Pubsub.GRPC.full_topic_name("my-topic")
  )

{:ok, response} = channel |> Google.Pubsub.V1.Publisher.Stub.get_topic(request)
```

To create a new topic:
```elixir
{:ok, topic} =
  channel
  |> Google.Pubsub.V1.Publisher.Stub.create_topic(%Google.Pubsub.V1.Topic{
    name: Google.Pubsub.GRPC.full_topic_name("my-topic")
  })
```

To delete a topic:
```elixir
{:ok, _} =
  channel
  |> Google.Pubsub.V1.Publisher.Stub.delete_topic(%Google.Pubsub.V1.Topic{
    name: Google.Pubsub.GRPC.full_topic_name("my-topic")
  })

```

To create a new subscription on a topic:
```elixir
{:ok, subscription} =
  channel
  |> Google.Pubsub.V1.Subscriber.Stub.create_subscription(%Google.Pubsub.V1.Subscription{
    topic: Google.Pubsub.GRPC.full_topic_name("my-topic"),
    name: Google.Pubsub.GRPC.full_subscription_name("my-subscription")
  })

```

To delete a subscription:
```elixir
request = %Google.Pubsub.V1.DeleteSubscriptionRequest{
  subscription: Google.Pubsub.GRPC.full_subscription_name("my-subscription")
}
{:ok, _} = channel |> Google.Pubsub.V1.Subscriber.Stub.delete_subscription(request)

```

To publish a message on a topic:
```elixir
message = %Google.Pubsub.V1.PubsubMessage{data: "string"}

request = %Google.Pubsub.V1.PublishRequest{
  topic: Google.Pubsub.GRPC.full_topic_name("my-topic"),
  messages: [message]
}

{:ok, response} = channel |> Google.Pubsub.V1.Publisher.Stub.publish(request)
```

To pull messages from a subscription:
```elixir
request = %Google.Pubsub.V1.PullRequest{
  subscription: Google.Pubsub.GRPC.full_subscription_name("my-subscription"),
  max_messages: 10
}
{:ok, response} = channel |> Google.Pubsub.V1.Subscriber.Stub.pull(request)

```

To acknowledge received messages:
```elixir
request = %Google.Pubsub.V1.AcknowledgeRequest{
  subscription: Google.Pubsub.GRPC.full_subscription_name("my-subscription"),
  ack_ids: Enum.map(messages, fn m -> m.ack_id end)
}
{:ok, response} = channel |> Google.Pubsub.V1.Subscriber.Stub.acknowledge(request)
'``
