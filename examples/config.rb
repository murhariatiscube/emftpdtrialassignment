require './fake'

#missing = %w[ACCESS_KEY_ID SECRET_ACCESS_KEY BUCKET].reject { |name| ENV[name] }
#raise "missing env variables: #{missing}" unless missing.empty?


driver     FakeFTPDriver
port ENV['PORT']
#driver_args 1, 2
#user      "ftp"
#group     "ftp"
daemonise false
name      "fakeftp"
pid_file  "/var/run/fakeftp.pid"
