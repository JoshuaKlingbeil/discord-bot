module Commands
  # Mojang commands
  class Mojang < ::Command
    def allowed_methods
      %w(status)
    end

    # Returns the status of various Mojang Minecraft Service Servers
    def status
      # expect applicateion/json encoded response parsed to hash 
      response = HTTParty.get('http://status.mojang.com/check')
      send_status_embed(response.parsed_response)   
    end

	
    private
    
    
    # to get it done, just slams in "red|yellow|green" response as it's raw text for each server 
    # TODO : fancy that up a smidge with some Webhooks::EmbedFields
    def send_status_embed(data)
      NEWLINE = "\n"
      GREEN = 'green'
      YELLOW = 'yellow'
      RED = 'red'
      CODE_GREEN = '#197a18'    # copied from other use as green.
      CODE_YELLOW = '#246b11'   # pulled completely out of my ass.
      CODE_RED = '#7a1818'      # copied from other use as red.
      
      color_stator = CODE_GREEN # init our stator to green.  
      
      @event.channel.send_embed do |embed|
        embed.title = 'Mojang Servers:'
        # iterate our hash
        # should be something like key == "server fqdn" , value == "red|yellow|green"
        data.each do |key, value| 
          embed.description += '#{key} :  #{value}' + NEWLINE 
        
          # Red?  Well damn!
          color_stator = CODE_RED if value == RED
          next if color_stator == CODE_RED            #locked in on red, no way out now
          
          # Yellow? Meh... maybe...
          color_stator = CODE_YELLOW if value == YELLOW
          next if color_stator == CODE_YELLOW         #can only be yellow or red from here on 
          
          # Green? Supergreen!
        end #data.each 
        
        embed.color = color_stator
      end #@event..send_embed  
      
    end #def send_status_embed(data)
    
  end #class Mojang
  
end #module Commands

