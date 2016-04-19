require 'spec_helper'
require_relative '../../app'

describe URL do

  it 'saves long url (more than 50 characters) correctly' do
    url = URL.first_or_create(
      :long_url => 'https://google.com.my/what?123&123&123&24231545145123412342134123421521342134'
    )
    result = url.save
    expect(result).to equal(true)
  end

end
