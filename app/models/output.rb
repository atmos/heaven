class Output
  attr_accessor :name, :number, :token

  def initialize(number, name, token)
    @name   = name
    @token  = token
    @number = number
  end

  def api
    @api ||= Octokit::Client.new(:access_token => token)
  end

  def create
    params = {
      :files       => { 'clone' => {:content => "Deployment #{number} pending" } },
      :public      => false,
      :description => "HerokuDeploy number #{number} for #{name}"
    }
    @gist = api.create_gist(params)
  end

  def update(stdout, stderr)
    params = {
      'clone'  => { :content => nil },
      'stdout' => { :content => stdout },
      'stderr' => { :content => stderr }
    }
    api.edit_gist(@gist.id, :public => false, :files => params)
  rescue Octokit::UnprocessableEntity
    Rails.logger.info "Unable to update #{@gist.id}, shit's fucked up."
  end

  def url
    "https://gist.github.com/#{@gist.id}"
  end
end
