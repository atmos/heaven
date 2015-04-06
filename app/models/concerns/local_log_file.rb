# A module to include for easy access to writing to a transient filesystem
module LocalLogFile
  extend ActiveSupport::Concern
  include DeploymentTimeout

  def working_directory
    @working_directory ||= "/tmp/" + \
      Digest::SHA1.hexdigest([name_with_owner, github_token].join)
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
    File.open(stdout_file, "a") { |f| f.write(out.force_encoding("utf-8")) }
  end

  def log_stderr(err)
    File.open(stderr_file, "a") { |f| f.write(err.force_encoding("utf-8")) }
  end

  def execute_and_log(cmds, env = {})
    # Don't add single/double quotes around to any cmd in cmds.
    # For example,
    #   cmds = ["my_command", "'foo=bar lazy=true'"] will fail
    # The correct way is
    #   cmds = ["my_command", "foo=bar lazy=true"]
    @last_child = POSIX::Spawn::Child.new(env.merge("HOME" => working_directory), *cmds, execute_options)

    log_stdout(last_child.out)
    log_stderr(last_child.err)

    unless last_child.success?
      fail StandardError, "Task failed: #{cmds.join(" ")}"
    end

    last_child
  end

  def execute_options
    if terminate_child_process_on_timeout
      { :timeout => deployment_time_remaining - 2 }
    else
      {}
    end
  end

  def terminate_child_process_on_timeout
    ENV["TERMINATE_CHILD_PROCESS_ON_TIMEOUT"] == "1"
  end
end
