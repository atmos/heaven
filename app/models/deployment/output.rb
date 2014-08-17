class Deployment
  class Output
    include ApiClient
    attr_accessor :gist, :guid, :name, :number, :stderr, :stdout

    def initialize(name, number, guid)
      @guid   = guid
      @name   = name
      @number = number
      @stdout = ""
      @stderr = ""
    end

    def gist
      @gist ||= api.create_gist(create_params)
    end

    def create
      gist
    end

    def update
      api.edit_gist(gist.id, update_params)
    rescue Octokit::UnprocessableEntity
      Rails.logger.info "Unable to update #{gist.id}, shit's fucked up."
    rescue StandardError => e
      Rails.logger.info "Unable to update #{gist.id}, #{e.message}."
    end

    def url
      "https://gist.github.com/#{gist.id}"
    end

    private
      def create_params
        {
          :files       => { :stdout => {:content => "Deployment #{number} pending" } },
          :public      => false,
          :description => "Heaven number #{number} for #{name}"
        }
      end

      def update_params
        params = {
          :files  => { },
          :public => false
        }

        unless stderr.empty?
          params[:files].merge!(:stderr => { :content => stderr })
        end

        unless stdout.empty?
          params[:files].merge!(:stdout => { :content => stdout })
        end

        params
      end
  end
end
