require 'base64'

class Deployment
  attr_accessor :api, :guid, :payload, :token, :output, :status

  def initialize(guid, payload, token)
    @guid    = guid
    @token   = token
    @payload = payload

    @api    = Octokit::Client.new(:access_token => token)
    @output = Deployment::Output.new(app_name, number, guid, token)
    @status = Deployment::Status.new(token, name_with_owner, number)
  end

  def data
    @data ||= JSON.parse(payload)
  end

  def redis
    Heaven.redis
  end

  def number
    data['id']
  end

  def http_options
    {
      :url     => "https://api.heroku.com",
      :headers => {
        "Accept"        => "application/vnd.heroku+json; version=3",
        "Content-Type"  => "application/json",
        "Authorization" => Base64.encode64(":#{ENV['HEROKU_API_KEY']}")
      }
    }
  end

  def http
    @http ||= Faraday.new(http_options) do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end

  def post_build
    response = http.post do |req|
      req.url "/apps/#{app_name}/builds"
      req.body = JSON.dump(:source_blob => {:url => archive_link})
    end
    JSON.parse(response.body)
  end

  def build_id
    @build_id ||= post_build['id']
  end

  def sha
    data['sha'][0..7]
  end

  def name_with_owner
    data['repository']['full_name']
  end

  def custom_payload
    @custom_payload ||= data['payload']
  end

  def custom_payload_config
    custom_payload && custom_payload['config']
  end

  def environment
    custom_payload && custom_payload.fetch("environment", "production")
  end

  def app_name
    return nil unless custom_payload_config
    environment == "staging" ?
      custom_payload_config['heroku_staging_name'] :
      custom_payload_config['heroku_name']
  end

  def archive_link
    @archive_link ||= api.archive_link(name_with_owner, :ref => sha)
  end

  def log(line)
    Rails.logger.info "#{app_name}-#{guid}: #{line}"
  end

  def execute
    log build_id
  end

  def started
    output.create
    status.output = output.url
    status.pending!
  end

  def completed
    successful = true
    output.update("", "")
    status.complete!(successful)
  end

  def completed?
    @status.completed?
  end

  def run!
    started
    execute
    completed
  rescue StandardError => e
    Rails.logger.info e.message
  ensure
    status.failure! unless completed?
  end
end
