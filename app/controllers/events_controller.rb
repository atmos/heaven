class EventsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:create]

  def create
    if Verifier.valid?(request.ip)
      guid  = request.headers['HTTP_X_GITHUB_DELIVERY']
      event = request.headers['HTTP_X_GITHUB_EVENT']

      if %w(deployment status ping).include?(event)
        request.body.rewind
        data = request.body.read

        Resque.enqueue(Receiver, event, guid, data)
        render :status => 201, :json => "{}"
      else
        render :status => 404, :json => "{}"
      end
    else
      Rails.logger.info "Invalid IP posting to the app, #{request.ip}"
      render :status => 404, :json => "{}"
    end
  end
end
