Create Microservices in Rails by pretty much just writing regular Rails code.

![build status](https://travis-ci.org/stitchfix/stitches.svg?branch=master)

This gem provides:

* transparent API key authentication.
* router-level API version based on headers.
* a way to document your microservice endpoints via acceptance tests.
* structured errors, buildable from invalid Active Records, Exceptions, or by hand.

This, plus much of what you get from Rails already, means you can create a microservice Rails application by just writing the
same Rails code you write today.  Instead of rendering web views, you render JSON (which is built into Rails).

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
> bin/rails generate rspec:install
> bin/rails generate apitome:install
> bin/rails generate stitches:api
> bundle exec rake db:migrate
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
        errors: Stitches::Errors.from_active_record(widget) 
      }, status: 422
    end
  end

private

  def widget_params
    params.require(:widget).permit(:name, :type, :sub_type)
  end
end
```

If you think there's nothing special about this—you are correct.  This is the vanillaest of vanilla Rails controllers, with a few
notable exceptions:

* We aren't checking content type.  A stitches-based microservice always uses JSON and refuses to route requests for non-JSON to
you, so there's zero need to use `respond_to` and friends.
* The error-building is structured and reliable.
* This is an authenticated request.  No request without proper authentication will be routed here, so you don't have to worry
about it in your code.
* This is a versioned request.  While the URL will *not* contain `v1` in it, the `Accept` header will require a version and get
routed here.  If you make a V2, it's just a new controller and this concern is handled at the routing layer.

All this means that the Rails skills of you and your team can be directly applied to building microservices.  You don't have to make a bunch of boring decisions about auth, versioning, or content-types.  It also means you can start deploying and creating microservices with little friction.  No need to deal with a complex DSL or new programming language to get yourselves going with Microservices.

## More Info

See [the wiki](https://github.com/stitchfix/stitches/wiki/Setup) for how to setup stitches.

* [Stitches Features](https://github.com/stitchfix/stitches/wiki/Features-of-Stitches) include:
  - Authorization via API key
  - Versioned requests via HTTP content types
  - Structured Errors
  - ISO 8601-formatted dates
* The [Generator](https://github.com/stitchfix/stitches/wiki/Generator) sets up some code in your app, so you can start writing
APIs using vanilla Rails idioms:
  - a "ping" controller that can vaidate your app is working
  - version routing based on content-type (requests for V2 use the same URL, but are serviced by a different controller)
  - An ApiClient Active Record
  - Acceptance tests that can produce API documentation as they test your app.
* Stitches provides [testing support](https://github.com/stitchfix/stitches/wiki/Testing)


## Developing

Although `Stitches.configuration` is global, do not depend directly on that in your logic.  Instead, allow all classes to receive a configuration object in their constructor.  This makes the classes easier to deal with and change, without incurring much of a real cost to development.  Global symbols suck, but are convienient.  This is how you make the most of it.

---

Provided with love by your friends at [Stitch Fix Engineering](http://technology.stitchfix.com)

![stitches](https://s3.amazonaws.com/stitchfix-stitches/stitches.png)
