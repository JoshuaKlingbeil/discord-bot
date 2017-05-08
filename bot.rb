require 'discordrb'
require 'yaml'
require 'minestat'
require 'httparty'
require './commands/command.rb'

config = YAML.load_file('config.yml')

bot = Discordrb::Commands::CommandBot.new(token:     config['discord']['token'],
                                          prefix:    config['discord']['prefix'],
                                          client_id: config['discord']['client_id'])

#  Grab all commands
command_files = Dir['./commands/*.rb']

# Clean up the file names, remove the extensions and ignore command.rb
commands = command_files.map do |file_name|
  next if file_name == './commands/command.rb'

  file_name.split('/').last.gsub('.rb', '').to_sym
end

# Go through each command file we have
commands.each do |command|
  puts command
  bot.command(command) do |event, run_method, *options|
    return nil unless run_method

    # Initialize the current command and run it
    current_command = Object.const_get("Commands::#{command.capitalize}")
    current_command.new(event, run_method, options).run
  end
end

# Clean up any flipped tables
bot.message(content: '(╯°□°）╯︵ ┻━┻') do |event|
  event.respond '┬─┬﻿ ノ( ゜-゜ノ)'
end

bot.message(content: 'what\'s my user id?') do |event|
  event.respond event.user.id
end

puts 'Bot is alive.'
bot.run
