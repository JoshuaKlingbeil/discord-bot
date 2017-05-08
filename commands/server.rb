module Commands
  # Server commands
  class Server < ::Command
    def allowed_methods
      %w(status list command)
    end

    # Returns the status of a server
    def status
      server = @options.first&.downcase || ''
      selected_server = @config.dig('servers', server)

      # End early if no server was found, and let the user know
      return "No server found matching '#{server}'" unless selected_server

      server_stats = MineStat.new(selected_server['host'], selected_server['port'])
      send_status_embed(server_stats)
    end

    # Returns a list of all servers
    def list
      send_info_embed
    end

    def command
      return nil unless is_admin?

      server = @options.first&.downcase || ''
      command = @options[1..-1].join(' ') || ''
      server_config = @config.dig('servers', server)

      data = {
        host: server_config['host'],
        port: server_config['rcon']['port'],
        password: server_config['rcon']['password'],
        command: command
      }

      header = { 'Content-Type': 'application/x-www-form-urlencoded' } 

      # Make the request
      data = HTTParty.post('http://api.solaracraft.com/server/command', body: data, headers: header);

      send_command_embed(data.parsed_response)
    end

    private

    def send_command_embed(data)
      embed_color = data['stauts'] != 'success' ? '#197a18' : '#7a1818'
      @event.channel.send_embed do |embed|
        embed.title = 'Server response'
        embed.description = data['response']
        embed.color = embed_color
      end
    end

    def send_info_embed
      @event.channel.send_embed do |embed|
        @config['servers'].each do |server_name, server_info|
          info = server_info.
                 reject { |key, value| key == 'rcon' }.
                 map { |key, value| "**#{key}:** #{value}" }.
                 join("\n")

          embed.add_field(name: server_name.capitalize, value: info, inline: false)
        end
      end
    end

    # Create a fancy discord embed object
    def send_status_embed(server_stats)
      server_color   = server_stats.online ? '#197a18' : '#7a1818'
      players_online = server_stats.current_players || 0

      @event.channel.send_embed do |embed|
        embed.title = server_stats.motd
        embed.description = server_stats.online ? 'Online' : 'Offline'
        embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "#{players_online} players online",
                                                            icon_url: 'http://ryanbeasse.com/players.png')
        embed.color = server_color
      end
    end
  end
end
