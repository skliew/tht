require 'spec_helper'
require_relative '../../app'

describe URL do

  it 'saves long url (more than 50 characters) correctly' do
    url = URL.first_or_create(
      :long_url => 'https://google.com.my/what?123&123&123&24231545145123412342134123421521342134'
    )
    result = url.save
    expect(result).to eq(true)
  end

  it 'converts an id correctly' do
    result = URL.id_to_code(1)
    expect(result).to eq('b')
  end

  it 'converts a code correctly' do
    result = URL.code_to_id('b')
    expect(result).to eq(1)
  end

  it 'converts to and from an ID correctly' do
    id = 100
    code = URL.id_to_code(id)
    result = URL.code_to_id(code)
    expect(result).to eq(id)

    id = 63
    code = URL.id_to_code(id)
    result = URL.code_to_id(code)
    expect(result).to eq(id)

    code = "1583"
    id = URL.code_to_id(code)
    result = URL.id_to_code(id)
    expect(result).to eq(code)
  end

  it 'raises an exception if an invalid code is given' do
    code = "&*&^"
    expect { id = URL.code_to_id(code) }.to raise_error(ArgumentError)
  end

end
