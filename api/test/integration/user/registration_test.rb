require 'test_helper'

class User::RegistrationTest < ActionDispatch::IntegrationTest
  test 'register success' do
    # prepare
    email = Faker::Internet.free_email
    password = Faker::Internet.password
    params = { email: email, password: password }

    # action
    post '/v1/user/register', params: params

    # check results
    assert_response :success
    json = JSON.parse(response.body)
    id = json['id']
    user = User::User.find_by_id(id)
    assert_not_nil user, 'The user does not exist'
    assert_equal user.email, email, 'Wrong email'

    # get code from email
    confirmation_email = ActionMailer::Base.deliveries.last
    text = confirmation_email.body.to_s
    string_to_find = ENV['SITE_CONFIRM_LINK'] + '/'
    regexp = Regexp.new(Regexp.escape(string_to_find) + '\w*')
    code = text.scan(regexp).first.to_s.gsub(string_to_find, '')

    # check token
    token = User::Token.where(code: code, token_type: User::Token::TYPE_CONFIRMATION).first
    assert_not_nil(token)
    token_user = token.user
    assert_equal token_user, user

    # check family
    assert_not_nil user.family
  end

  test 'register fail invalid params' do
    # prepare
    email = 'qwe'
    password = 'asd'
    params = { email: email, password: password }

    # action
    post '/v1//user/register', params: params

    # check results
    assert_response 422
    json = JSON.parse(response.body)
    assert_includes json['email'], 'is invalid'
    assert_includes json['password'], 'is too short (minimum is 6 characters)'
  end

  test 'register fail without params' do
    # action
    post '/v1//user/register'

    # check results
    assert_response 422
    json = JSON.parse(response.body)
    assert_includes json['email'], 'is invalid'
    assert_includes json['email'], 'can\'t be blank'
    assert_includes json['password'], 'is too short (minimum is 6 characters)'
    assert_includes json['password'], 'can\'t be blank'
  end

  test 'register fail email exists' do
    # prepare
    email = Faker::Internet.free_email
    password = Faker::Internet.password
    params = { email: email, password: password }
    post '/v1//user/register', params: params

    # action
    post '/v1//user/register', params: params


    # check results
    assert_response 422
    json = JSON.parse(response.body)
    assert_includes json['email'], 'has already been taken'
  end
end
