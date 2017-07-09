You'll be in stitches at how easy it is to get your API service up and running!

![build status](https://travis-ci.org/stitchfix/stitches.svg?branch=master)

This gem provides:

* Rails plugin to handle api key and versioned requests
* Generator to get you set up and validate your API before you write any code
* Spec helpers to use when building your API

## To install

Add to your `Gemfile`:

```ruby
gem 'stitches'
```

Then:

```
bundle install
```

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
