module Stitches
  # A container for error messages you intend to send as a response to an API request.
  # The canonical error format is a list of all errors that occured, with each error consistent of a code
  # (useful for programmatic logic based on error condition) and a message (useful for displaying to
  # either a log or a human, as documented by the API).
  #
  # The general usage of this is:
  #
  #     type.json do
  #       render json: {
  #           errors: Stitches::Errors.new([
  #             Stitches::Error.new(code: "name_required", message: "The name is required")
  #             Stitches::Error.new(code: "numeric_age", message: "The age should be a number")
  #           ])
  #         },
  #         status: 404
  #     end
  #
  # More likely, you will create these from an exception or from an ActiveRecord::Base.
  #
  # == Exceptions
  #
  # If you create exceptions for the various known errors in your app, you can rely
  # on the logic in +from_exception+ to generate your code and message.
  #
  #     rescue BadPaymentTypeError => ex
  #       Stitches::Errors.from_exception(ex)
  #     end
  #
  # This will create an errors array with one element, which is an error with code "bad_payment_type"
  # and the message of whatever the exception message was.
  #
  # So, by judicious use and naming of your exceptions, you could do something like this in your controller:
  #
  #     rescue_from MyAppSpecificExceptionBase do |ex|
  #       render json: { errors: Stitches::Errors.from_exception(ex) }, status: 400
  #     end
  #
  # And the codes will match the hierarchy of exceptions inheriting from +MyAppSpecificExceptionBase+.
  #
  # == ActiveRecord
  #
  # You can also create errors from an ActiveRecord object:
  #
  #     person = Person.create(params)
  #     if person.valid?
  #       render json: { person: person }, status: 201
  #     else
  #       render json: { errors: Stitches::Errors.from_active_record_object(person)
  #     end
  #
  # This will create one error for each field of the main object.  The code will be "field_invalid" and
  # the message will a comma-joined list of what's wrong with that field, e.g. "Amount can't be blank, Amount must be a number".
  #
  # Remember, for APIs, you don't want to send bad user data directly to the API, so this mechanism isn't designed for form fields and
  # all the other things Rails gives you.  It's for the API client to be able to tell the programmer what went wrong.
  class Errors
    include Enumerable

    def self.from_exception(exception)
      code = exception.class.name.underscore.gsub(/_error$/,'')
      self.new([
        Error.new(
          code: code,
          message: exception.message
        )
      ])
    end

    def self.from_active_record_object(object)
      errors = object.errors.to_hash.map { |field,errors|
        code = "#{field}_invalid".parameterize
        message = if object.send(field).respond_to?(:errors)
                    object.send(field).errors.full_messages.sort.join(', ')
                  else
                    object.errors.full_messages_for(field).sort.join(', ')
                  end
        Stitches::Error.new(code: "#{field}_invalid".parameterize, message: message)
      }
      self.new(errors)
    end

    def initialize(individual_errors)
      @individual_errors = individual_errors
    end

    def size
      @individual_errors.size
    end

    def each
      if block_given?
        @individual_errors.each do |error|
          yield error
        end
      else
        @individual_errors.each
      end
    end
  end
end