class EventsController < ApplicationController
  def create
    request.body.rewind
    data = request.body.read

    guid  = request.headers['HTTP_X_GITHUB_DELIVERY']
    event = request.headers['HTTP_X_GITHUB_EVENT']

    if %w(deployment ping).include?(event)
      Resque.enqueue(Receiver, event, guid, data)
      render :status => 201, :json => "{}"
    else
      render :status => 404, :json => "{}"
    end
  end
end
