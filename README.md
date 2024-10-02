# Hackler

> **Hackler**, da (/ˈhaklɐ/)
>
> _(Austria, informal) hard worker_

A cursed approach to background jobs.  **Here be dragons.**

Imagine you have a Rails app deployed to a web host that can **only** run Rack
applications backed by a MySQL database.  There's no possibility to spin up
any form of containerised application (podman, docker), and no possibility to
drop into a shell (configure systemd units by hand, run stuff in a tmux/screen
session), nothing.

As long as you don't need any form of background processing, this is fine.

However, once you want to make use of background jobs you'll run into a few
challenges:

- Most (if not all) in-process adapters will lose their enqueued jobs when
  the app is restarted, this is not suitable for production.
- Pretty much every other adapter requires either another process running
  that's separate from the main app.  Remember, our web host can only run
  Rack-based apps!
- Most Active Job adapters usually require a specific database or message bus
  too, be it PostgreSQL, Redis, RabbitMQ, beanstalkd, ... but all we have is
  a basic MySQL.
- Running the extra worker process on another server requires access to the
  main database, and the additional database the job library needs, this
  complicates the configuration of those databases (firewalls, VPNs, ACLs)...
  and on a shared web host you might not be able to expose the MySQL as you
  wish.
- Running the extra worker process on another server requires an exact copy of
  the app you're currently running, complicating deployment even further.
- Trying to start the extra worker process as part of the Rack app is even
  more cursed than whatever this mess is.  Not to mention that restarts are
  going to get interesting...
- Let's face it: there are no other background job processors out there that
  are cooler than Sidekiq.
- And migrating the app to another host is not a possibility either.

So what can we do?

Of course, we'll let our Rails web app talk to another Rails web app that can
make use of a real job processor, all over HTTP.  *Obviously*.

## Sounds cursed, I'm in!

In the end you'll end up with two Rails apps.

One is your usual web app that will make use of a new kind of Active Job
adapter.  Let's call it... `rails-web`.

The other one is a barebones Rails app that can use any other Active Job
adapter you like (yay, Sidekiq!).  This one does not need access to the code
or database of `rails-web`, and therefore doesn't really care what jobs you
throw at it.  I'll call that one `rails-worker`.

Whenever `rails-web` wants to enqueue an Active Job job, the `:hackler`
adapter will create a new `Hackler::Job` record and perform a HTTP POST
request to `rails-worker`, which will then enqueue a very basic job in the
adapter chosen by that app (probably `:sidekiq`).  The basic job only has two
parameters: a base callback URL and the job ID.

Once the job processor framework used by `rails-worker` decides to enqueue the
job, the `rails-worker` makes a HTTP POST request to `rails-web`, which
fetches the stored job information from its database and runs the job.  If
it's successful that job record is gone from the database.  Should the job
fail however, the `rails-worker` process will automagically™ capture the
exception thrown by the job and re-raise it on the `rails-worker` side.

Of course, not everyone can access those HTTP endpoints exposed by Hackler,
so a shared secret must be defined on both ends.  Some hashed value based on
that and the job info will be sent with each request.

Is this a good idea?  Probably not, longer running jobs might block some
incoming requests.  Should be fine for quick jobs though, like sending out
emails.

Is this extra cursed?  **_Heck yea!_**

## Installation

Add the gem to your Gemfile:

```bash
$ bundle add hackler
```

In your main web app, install and configure Hackler:

```bash
$ bin/rails generate hackler:install
```

Make sure to edit `shared_secret`, `web_base_url`, and `worker_base_url` in
`config/initializers/hackler.rb`.

----

To install and configure Hackler in the worker app you first need to configure
an Active Job adapter.  One that actually processes these jobs.  I can't
remember which one I liked best, but I think some numbers will do fine as
well...

```ruby
# config/application.rb

class Application < Rails::Application
  # ...
  config.active_job.queue_adapter = 62060811362.to_s(36).to_sym
```

Then, install and configure Hackler:

```bash
$ bin/rails generate hackler:worker_install
```

Make sure to set `shared_secret` in `config/initializers/hackler.rb` to the
same value as on the web setup.

----

You are now ready to run the two Rails apps simultaneously!  Use one terminal
per command:

```bash
# in your web app directory:
bin/rails server

# in your worker app directory:
bin/rails server -p 4000
bundle exec sidekiq
```

This repository contains an example Rails app with Sidekiq as its job backend
at `/hacklerer`.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## That's cool and all, but should I use this?

Probably not.  If you do, please let me know why.

As of now this library is a proof-of-concept.  Or a prototype.  Or an art
project.  I mean, I didn't even bother with tests yet...
