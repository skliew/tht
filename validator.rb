require 'uri'

# Validate URL as parameter
class ValidUrl < Grape::Validations::Base
  def validate_param!(attr_name, params)
    parser = URI::Parser.new
    uri = parser.parse(params[attr_name])
    unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
      full_name = @scope.full_name(attr_name)
      raise Grape::Exceptions::Validation,
            params: [full_name],
            message: 'must be a valid URL'
    end
  end
end
