Create Microservices in Rails by pretty much just writing regular Rails code.

This gem provides:

- transparent API key authentication.
- router-level API version based on headers.
- a way to document your microservice endpoints via acceptance tests.
- structured errors, buildable from invalid Active Records, Exceptions, or by hand.

This, plus much of what you get from Rails already, means you can create a microservice Rails application by just writing the
same Rails code you write today. Instead of rendering web views, you render JSON (which is built into Rails).

## To install

Add to your `Gemfile`:

```ruby
gem 'stitches'
```

Then:

```
bundle install
```

Then, set it up:

```
> bin/rails generate stitches:api
> bundle exec rake db:migrate
```

### Upgrading from an older version

- When upgrading to version 4.0.0 and above you may now take advantage of an in-memory cache

You can enabled it like so

```ruby
Stitches.configure do |config|
  config.max_cache_ttl = 5  # seconds
  config.max_cache_size = 100  # how many keys to cache
end
```

You can also set a leniency for disabled API keys, which will allow old API keys to continue to be used if they have a
`disabled_at` field set as long as the leniency is not exceeded. Note that if the `disabled_at` field is not populated
the behavior will remain the same as it always was, and the request will be denied when the `enabled` field is set to
`true`. If Stitches allows a call due to leniency settings, a log message will be generated with a severity depending on
how long ago the API key was disabled.

```ruby
Stitches.configure do |config|
  config.disabled_key_leniency_in_seconds = 3 * 24 * 60 * 60 # Time in seconds, defaults to three days
  config.disabled_key_leniency_error_log_threshold_in_seconds = 2 * 24 * 60 * 60 # Time in seconds, defaults to two days
end
```

If a disabled key is used within the `disabled_key_leniency_in_seconds`, it will be allowed.

Anytime a disabled key is used a log will be generated. If it is before the
`disabled_key_leniency_error_log_threshold_in_seconds` it will be a warning log message, if it is after that, it will be
an error message. `disabled_key_leniency_error_log_threshold_in_seconds` should never be a greater number than
`disabled_key_leniency_in_seconds`, as this provides an escallating series of warnings before finally disabling access.

- If you are upgrading from a version older than 3.3.0 you need to run three generators, two of which create database
  migrations on your `api_clients` table:

  ```
  > bin/rails generate stitches:add_enabled_to_api_clients
  > bin/rails generate stitches:add_deprecation
  > bin/rails generate stitches:add_disabled_at_to_api_clients
  ```

- If you are upgrading from a version between 3.3.0 and 3.5.0 you need to run two generators:

  ```
  > bin/rails generate stitches:add_deprecation
  > bin/rails generate stitches:add_disabled_at_to_api_clients
  ```

- If you are upgrading from a version between 3.6.0 and 4.0.2 you need to run one generator:

  ```
  > bin/rails generate stitches:add_disabled_at_to_api_clients
  ```

## Example Microservice Endpoint

Suppose we wish to allow our consumers to create Widgets

```ruby
class Api::V1::WidgetsController < ApiController
  def create
    widget = Widget.create(widget_params)
    if widget.valid?
      head 201
    else
      render json: {
        errors: Stitches::Errors.from_active_record_object(widget)
      }, status: 422
    end
  end

private

  def widget_params
    params.require(:widget).permit(:name, :type, :sub_type)
  end
end
```

If you think there's nothing special about this—you are correct. This is the vanillaest of vanilla Rails controllers, with a few
notable exceptions:

- We aren't checking content type. A stitches-based microservice always uses JSON and refuses to route requests for non-JSON to
  you, so there's zero need to use `respond_to` and friends.
- The error-building is structured and reliable.
- This is an authenticated request. No request without proper authentication will be routed here, so you don't have to worry
  about it in your code.
- This is a versioned request. While the URL will _not_ contain `v1` in it, the `Accept` header will require a version and get
  routed here. If you make a V2, it's just a new controller and this concern is handled at the routing layer.

All this means that the Rails skills of you and your team can be directly applied to building microservices. You don't have to make a bunch of boring decisions about auth, versioning, or content-types. It also means you can start deploying and creating microservices with little friction. No need to deal with a complex DSL or new programming language to get yourselves going with Microservices.

## More Info

See [the wiki](https://github.com/stitchfix/stitches/wiki/Setup) for how to setup stitches.

- [Stitches Features](https://github.com/stitchfix/stitches/wiki/Features-of-Stitches) include:
  - Authorization via API key
  - Versioned requests via HTTP content types
  - Structured Errors
  - ISO 8601-formatted dates
  - Deprecation using the `Sunset` header
  - An optional ApiKey cache to allow mostly DB free APIs
- The [Generator](https://github.com/stitchfix/stitches/wiki/Generator) sets up some code in your app, so you can start writing
  APIs using vanilla Rails idioms:
  - a "ping" controller that can validate your app is working
  - version routing based on content-type (requests for V2 use the same URL, but are serviced by a different controller)
  - An ApiClient Active Record
  - Acceptance tests that can produce API documentation as they test your app.
- Stitches provides [testing support](https://github.com/stitchfix/stitches/wiki/Testing)

## API Key Caching

Since version 4.0.0, stitches now has the ability to cache API keys in
memory for a configurable amount of time. This may be an improvement for
some applications.

You must configure the API Cache for it be used.

```ruby
Stitches.configure do |config|
  config.max_cache_ttl = 5  # seconds
  config.max_cache_size = 100  # how many keys to cache
end
```

Your cache size should be
larger then the number of consumer keys your service has.

## Developing

Although `Stitches.configuration` is global, do not depend directly on that in your logic. Instead, allow all classes to receive a configuration object in their constructor. This makes the classes easier to deal with and change, without incurring much of a real cost to development. Global symbols suck, but are convenient. This is how you make the most of it.

Also, the integration test does a lot of "testing the implementation", but since Rails generators are notorious for silently
failing with a successful result, we have to make sure that the various `inject_into_file` calls are actually working. Do not do
any fancy refactors here, just keep it up to date.

## Releases

See the release process for open source gems in the Stitch Fix engineering wiki under technical topics.

---

Provided with love by your friends at [Stitch Fix Engineering](http://technology.stitchfix.com)
