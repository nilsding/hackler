# hacklerer

Basic API-only app running a Hackler in `worker` mode backed by Sidekiq.

## Requirements

- Valkey/Redis

## Deployment

Run both the Rails server, and Sidekiq.

```
rails server
bundle exec sidekiq
```
