class Deployment
  class Output
    include ApiClient
    attr_accessor :gist, :guid, :name, :number, :outs

    def initialize(name, number, guid)
      @guid   = guid
      @name   = name
      @number = number
      @outs = {
        :stderr => "",
        :stdout => "",
      }
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

        outs.each do |channel, out|
          unless out.empty?
            params[:files].merge!(channel => { :content => out })
          end
        end

        params
      end
  end
end
