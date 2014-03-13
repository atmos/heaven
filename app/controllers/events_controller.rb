class EventsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:create]

  def create
    request.body.rewind
    data = request.body.read

    guid  = request.headers['HTTP_X_GITHUB_DELIVERY']
    event = request.headers['HTTP_X_GITHUB_EVENT']

    if %w(deployment status ping).include?(event)
      Resque.enqueue(Receiver, request.ip, event, guid, data)
      render :status => 201, :json => "{}"
    else
      render :status => 404, :json => "{}"
    end
  end
end
