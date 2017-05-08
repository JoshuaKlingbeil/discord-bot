# Create the base command class
class Command
  def allowed_methods
    %w()
  end

  def initialize(event, run_method, options)
    @event   = event
    @options = options
    @method  = run_method
    @config  = YAML.load_file('config.yml')
  end

  # Run the command if it is an allowed method
  def run
    send(@method) if allowed_methods.include? @method
  end

  def is_admin?
    @config['admins'].include? @event.user.id
  end
end

# Load all of our commands
require './commands/server.rb'
