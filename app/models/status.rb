class Status
  attr_accessor :number, :nwo, :output, :token
  def initialize(token, nwo, number)
    @nwo    = nwo
    @token  = token
    @number = number
  end

  def api
    @api ||= Octokit::Client.new(:access_token => @token)
  end

  def pending!
    api.create_deployment_status(nwo, number, 'pending', {:target_url => output})
  end

  def complete!(successful)
    state = successful ? "success" : "failure"
    api.create_deployment_status(nwo, number, state, {:target_url => output})
  end
end
