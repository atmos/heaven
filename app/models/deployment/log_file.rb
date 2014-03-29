class Deployment
  module LogFile
    def working_directory
      @working_directory ||= "/tmp/" + \
        Digest::SHA1.hexdigest([name_with_owner, token].join)
    end

    def checkout_directory
      "#{working_directory}/checkout"
    end

    def stdout_file
      "#{working_directory}/stdout.#{guid}.log"
    end

    def stderr_file
      "#{working_directory}/stderr.#{guid}.log"
    end

    def log_stdout(out)
      File.open(stdout_file, 'a') { |f| f.write(out) }
    end

    def log_stderr(err)
      File.open(stderr_file, 'a') { |f| f.write(err) }
    end
  end
end
