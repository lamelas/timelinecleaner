#!/usr/bin/env ruby
require 'Twitter'

backup_filename = "backup.txt"

begin
    client = Twitter::REST::Client.new do |config|
        config.consumer_key = "" # place your consumer key 
        config.consumer_secret = "" # place your consumer secret 
        config.access_token = "" # place oauth token 
        config.access_token_secret = "" # place oauth token secret
    end

    friend_ids = client.friend_ids

    puts "Backing up the users you follow. Just in case..."
    File.open(backup_filename, "a") do |file|
        friend_ids.each do |id|
            file.write("#{id}\n")
        end
    end

    puts "The IDs for all the users you follow where backed up to the file #{backup_filename}"

    following = friend_ids.to_h[:ids].length
    puts "You're following #{following} users"

    puts "Starting le grand Twitter unfollowing"
    friend_ids.each do |id|
        begin
            unfollowed_user = client.unfollow(id)
            following -= 1
            puts "Just unfollowed #{unfollowed_user.first.screen_name} (#{unfollowed_user.first.name}). #{following} left." if following > 0
            STDOUT.flush
            sleep(1.5)
        rescue Exception => e
            puts "An error ocurred when trying to unfollow user with ID #{id}"
        end
    end

    if following == 0
        puts "FREE AT LAST!"
    end

rescue => e
  p e.message
  p e.backtrace
end