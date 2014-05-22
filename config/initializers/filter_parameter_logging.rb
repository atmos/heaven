param_keys =  [:branches, :commit, :config, :context, :deployment, :description, :environment, :id, :name, :password, :payload, :ref, :repository, :sender, :sha, :state, :target_url]
Rails.application.config.filter_parameters += param_keys
