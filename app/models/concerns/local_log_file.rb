# A module to include for easy access to writing to a transient filesystem
module LocalLogFile
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
    @last_child = POSIX::Spawn::Child.new(env.merge("HOME" => working_directory), *cmds)
    log_stdout(last_child.out)
    log_stderr(last_child.err)
    last_child
  end
end
