require 'spec_helper'
require 'rack/test'
require_relative '../../app'

describe UrlShortener::API do

  include Rack::Test::Methods

  def app
    UrlShortener::API
  end

  it 'shows status' do
    get '/api/status'
    expect(last_response.status).to eq(200)
  end

  it 'should report an error given when given no parameters' do
    get '/api/url'
    expect(last_response.status).to eq(422)
    expect(last_response.body.to_json).to match(/bad URI/)
  end

  it 'should report an error given an invalid shortUrl' do
    get '/api/url', { shortUrl: '1234' }
    expect(last_response.status).to eq(422)
    expect(JSON.parse(last_response.body)['error']).to eq('shortUrl must be a valid URL')
  end

  it 'should report an error given an invalid shortUrl' do
    get '/api/url', { shortUrl: 'http://local/r/2' }
    expect(last_response.status).to eq(422)
    expect(JSON.parse(last_response.body)['error']).to match(/is not recognizable/)
  end

  it 'creates shortened URL' do
    post '/api/url', { longUrl: "http://google.com" }
    # 201 indicates resource successfully created
    expect(last_response.status).to eq(201)
    base_url = last_request.base_url
    expect(JSON.parse(last_response.body)['shortUrl']).to eq(base_url + '/r/b')

    post '/api/url', { longUrl: "http://google.com.my" }
    # 201 indicates resource successfully created
    expect(last_response.status).to eq(201)
    base_url = last_request.base_url
    expect(JSON.parse(last_response.body)['shortUrl']).to eq(base_url + '/r/c')
  end

  it 'reuses the created shortURL' do
    post '/api/url', { longUrl: "http://google.com" }
    # 201 indicates resource successfully created
    expect(last_response.status).to eq(201)
    base_url = last_request.base_url
    expect(JSON.parse(last_response.body)['shortUrl']).to eq(base_url + '/r/b')

    url = last_request.base_url + '/r/b'
    get '/api/url', { shortUrl: url }
    expect(last_response.status).to eq(200)
    expect(JSON.parse(last_response.body)['longUrl']).to eq('http://google.com')
  end

  it 'reports and error when given no longUrl' do
    post '/api/url'
    expect(last_response.status).to eq(422)
    expect(last_response.body).to match(/bad URI/)
  end

  it 'should fail when given an invalid URL' do
    post '/api/url', { longUrl: "12341234" }
    # 201 indicates resource successfully created
    expect(last_response.status).to eq(422)
  end

  it 'should fail when given an URL longer than 255 characters' do
    url = 'http://developers.jollypad.com/fb/index.php?dmmy=1&fb_sig_in_iframe=1&fb_sig_iframe_key=8e296a067a37563370ded05f5a3bf3ec&fb_sig_locale=bg_BG&fb_sig_in_new_facebook=1&fb_sig_time=1282749119.128&fb_sig_added=1&fb_sig_profile_update_time=1229862039&fb_sig_expires=1282755600&fb_sig_user=761405628&fb_sig_session_key=2.IuyNqrcLQaqPhjzhFiCARg__.3600.1282755600-761405628&fb_sig_ss=igFqJKrhJZWGSRO__Vpx4A__&fb_sig_cookie_sig=a9f110b4fc6a99db01d7d1eb9961fca6&fb_sig_ext_perms=user_birthday,user_religion_politics,user_relationships,user_relationship_details,user_hometown,user_location,user_likes,user_activities,user_interests,user_education_history,user_work_history,user_online_presence,user_website,user_groups,user_events,user_photos,user_videos,user_photo_video_tags,user_notes,user_about_me,user_status,friends_birthday,friends_religion_politics,friends_relationships,friends_relationship_details,friends_hometown,friends_location,friends_likes,friends_activities,friends_interests,friends_education_history,friends_work_history,friends_online_presence,friends_website,friends_groups,friends_events,friends_photos,friends_videos,friends_photo_video_tags,friends_notes,friends_about_me,friends_status&fb_sig_country=bg&fb_sig_api_key=9f7ea9498aabcd12728f8e13369a0528&fb_sig_app_id=177509235268&fb_sig=1a5c6100fa19c1c9b983e2d6ccfc05ef'
    post '/api/url', { longUrl: url }
    expect(last_response.status).to eq(422)
  end

end
