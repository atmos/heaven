require "spec_helper"

describe "Heaven::Notifier::Flowdock" do

  before :all do
    ENV["FLOWDOCK_USER_API_TOKEN"] = "acdcabbacd01234567890"
    ENV["FLOWDOCK_USER_NAME"] = "Heaven test"
    ENV["FLOWDOCK_USER_EMAIL"] = "heaven.invalid@example.com"
    ENV["FLOWDOCK_USER_AVATAR"] = "http://example.com/imaginary.jpg"
    ENV["FLOWDOCK_FLOW_TOKENS"] = '{"example":"example_token","example2":"example2_token"}'
  end

  before :each do
    # Stub flow get
    stub_request(:get, "https://#{ENV["FLOWDOCK_USER_API_TOKEN"]}:@api.flowdock.com/v1/flows/find?id=example")
      .with(:headers => { "Accept" => "application/json", "Content-Type" => "application/json" })
      .to_return(
        :status => 200,
        :body => '{"web_url":"https://www.flowdock.com/app/example/main"}',
        :headers => { "Content-Type" => "application/json" })
    stub_request(:get, "https://api.github.com/repos/atmos/my-robot/deployments?environment=production&page=1")
      .to_return(:status => 200, :body => "[]", :headers => { "Content-Type" => "application/json" })
  end

  it "handles pending notifications" do
    n = Heaven::Notifier::Flowdock.new(fixture_data_with_flowdock_notify("deployment-pending"))
    # Stub posting to threads api
    stub_request(:post, "https://api.flowdock.com/messages").with(
      :body => JSON.generate(
        :flow_token => "example_token",
        :event => "activity",
        :external_thread_id => "heaven:deployment:atmos:my-robot:123456",
        :thread => {
          :title => "Deployment #123456 of my-robot to production",
          :body => "<p>Deploying from hubot-deploy-v0.6.0</p>",
          :external_url => "https://gist.github.com/fa77d9fb1fe41c3bb3a3ffb2c",
          :status => {
            :value => "pending",
            :color => "yellow"
          },
          :fields => [
            { :label => "Repository", :value => "<a href='https://github.com/atmos/my-robot'>atmos/my-robot</a>" },
            { :label => "Deployment", :value => "123456 (<a href='https://gist.github.com/fa77d9fb1fe41c3bb3a3ffb2c'>output</a>)" },
            {
              :label => "Deployed ref",
              :value => "<a href='https://github.com/atmos/my-robot/tree/break-up-notifiers'>break-up-notifiers</a> @ " + \
                "<a href='https://github.com/atmos/my-robot/commits/daf81923c94f7513ac840fa4fcc0dfcc11f32f74'>daf81923</a>"
            },
            { :label => "Environment", :value => "production" },
            { :label => "Previous deployment", :value => "No previous deployments" },
            { :label => "Application", :value => "my-robot" }
          ]
        },
        :title => "Started deploying my-robot to production.",
        :author => {
          :name => "Heaven test",
          :avatar => "http://example.com/imaginary.jpg",
          :email => "heaven.invalid@example.com"
        },
        :tags => ["deploy", "production", "my-robot", "pending"]
      )
    ).to_return(:status => 201, :headers => { "Content-Type" => "application/json" }, :body => '{"thread_id":"generated_thread"}')
    # Stub final chat message
    stub_request(:post, "https://#{ENV["FLOWDOCK_USER_API_TOKEN"]}:@api.flowdock.com/v1/messages")
      .with(:headers => { "Accept" => "application/json", "Content-Type" => "application/json" }, :body => JSON.generate(
        :content => "Deployment started: https://www.flowdock.com/app/example/main/threads/generated_thread",
        :thread_id => "original_thread",
        :flow => "example",
        :tags => [],
        :event => "message"
      ))
      .to_return(:status => 200, :body => "")
    n.deliver(n.default_message)
  end

  it "handles successful deployment statuses" do
    n = Heaven::Notifier::Flowdock.new(fixture_data_with_flowdock_notify("deployment-success"))
    # Stub posting to threads api
    stub_request(:post, "https://api.flowdock.com/messages").with(
      :body => JSON.generate(
        :flow_token => "example_token",
        :event => "activity",
        :external_thread_id => "heaven:deployment:atmos:my-robot:11627",
        :thread => {
          :title => "Deployment #11627 of my-robot to production",
          :body => "<p>Deploying from hubot-deploy-v0.6.0</p>",
          :external_url => "https://gist.github.com/fa77d9fb1fe41c3bb3a3ffb2c",
          :status => {
            :value => "success",
            :color => "green"
          },
          :fields => [
            { :label => "Repository", :value => "<a href='https://github.com/atmos/my-robot'>atmos/my-robot</a>" },
            { :label => "Deployment", :value => "11627 (<a href='https://gist.github.com/fa77d9fb1fe41c3bb3a3ffb2c'>output</a>)" },
            {
              :label => "Deployed ref",
              :value => "<a href='https://github.com/atmos/my-robot/tree/break-up-notifiers'>break-up-notifiers</a> @ " + \
                "<a href='https://github.com/atmos/my-robot/commits/daf81923c94f7513ac840fa4fcc0dfcc11f32f74'>daf81923</a>"
            },
            { :label => "Environment", :value => "production" },
            { :label => "Previous deployment", :value => "No previous deployments" },
            { :label => "Application", :value => "my-robot" }
          ]
        },
        :title => "my-robot deployed with ref break-up-notifiers to production.",
        :author => {
          :name => "Heaven test",
          :avatar => "http://example.com/imaginary.jpg",
          :email => "heaven.invalid@example.com"
        },
        :tags => ["deploy", "production", "my-robot", "success"]
      )
    ).to_return(:status => 201, :headers => { "Content-Type" => "application/json" }, :body => '{"thread_id":"generated_thread"}')
    n.deliver(n.default_message)
  end

  it "handles failure deployment statuses" do
    n = Heaven::Notifier::Flowdock.new(fixture_data_with_flowdock_notify("deployment-failure"))
    # Stub posting to threads api
    stub_request(:post, "https://api.flowdock.com/messages").with(
      :body => JSON.generate(
        :flow_token => "example_token",
        :event => "activity",
        :external_thread_id => "heaven:deployment:atmos:my-robot:123456",
        :thread => {
          :title => "Deployment #123456 of my-robot to production",
          :body => "<p>Deploying from hubot-deploy-v0.6.0</p>",
          :external_url => "https://gist.github.com/fa77d9fb1fe41c3bb3a3ffb2c",
          :status => {
            :value => "failure",
            :color => "red"
          },
          :fields => [
            { :label => "Repository", :value => "<a href='https://github.com/atmos/my-robot'>atmos/my-robot</a>" },
            { :label => "Deployment", :value => "123456 (<a href='https://gist.github.com/fa77d9fb1fe41c3bb3a3ffb2c'>output</a>)" },
            {
              :label => "Deployed ref",
              :value => "<a href='https://github.com/atmos/my-robot/tree/break-up-notifiers'>break-up-notifiers</a> @ " + \
                "<a href='https://github.com/atmos/my-robot/commits/daf81923c94f7513ac840fa4fcc0dfcc11f32f74'>daf81923</a>"
            },
            { :label => "Environment", :value => "production" },
            { :label => "Previous deployment", :value => "No previous deployments" },
            { :label => "Application", :value => "my-robot" }
          ]
        },
        :title => "Failed deploying my-robot to production.",
        :author => {
          :name => "Heaven test",
          :avatar => "http://example.com/imaginary.jpg",
          :email => "heaven.invalid@example.com"
        },
        :tags => ["deploy", "production", "my-robot", "failure"]
      )
    ).to_return(:status => 201, :headers => { "Content-Type" => "application/json" }, :body => '{"thread_id":"generated_thread"}')
    n.deliver(n.default_message)
  end

  def fixture_data_with_flowdock_notify(file)
    raw_data = JSON.parse(fixture_data(file))
    raw_data["deployment"]["payload"]["notify"] = {
      :adapter => "flowdock",
      :room => "example",
      :user => "chat_user",
      :thread_id => "original_thread"
    }
    JSON.generate(raw_data)
  end
end
