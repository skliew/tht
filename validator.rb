require 'uri'

class ValidUrl < Grape::Validations::Base
  def validate_param!(attr_name, params)
    parser = URI::Parser.new
    uri = parser.parse(params[attr_name])
    unless (uri.kind_of?(URI::HTTP) or uri.kind_of?(URI::HTTPS))
      fail Grape::Exceptions::Validation, params: [@scope.full_name(attr_name)], message: 'must be a valid URL'
    end
  end
end
