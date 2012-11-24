module EM::FTPD
  module Authentication

    def initialize
      @user = nil
      @requested_user = nil
      super
    end

    def logged_in?
      @user.nil? ? false : true
    end

    # handle the USER FTP command. This is a user attempting to login.
    # we simply store the requested user name as an instance variable
    # and wait for the password to be submitted before doing anything
    def cmd_user(param)
      send_param_required and return if param.nil?
      send_response("500 Already logged in") and return unless @user.nil?
      @requested_user = param
      send_response "331 OK, password required"
    end

    # handle the PASS FTP command. This is the second stage of a user logging in
    def cmd_pass(param)
      send_response "202 User already logged in" and return unless @user.nil?
      send_param_required and return if param.nil?
      send_response "530 password with no username" and return if @requested_user.nil?

      # return an error message if:
      #  - the specified username isn't in our system
      #  - the password is wrong

      @driver.authenticate(@requested_user, param) do |result|
        if result
          @name_prefix = "/"
          @user = @requested_user
          @requested_user = nil
          send_response "230 OK, password correct"
        else
          @user = nil
          send_response "530 incorrect login. not logged in."
        end
      end
    end

  end
end
