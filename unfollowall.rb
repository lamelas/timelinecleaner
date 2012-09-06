#!/usr/bin/env ruby
require 'Twitter'

backup_filename = "backup.txt"

begin
	Twitter.configure do |config|
	  config.consumer_key = "" # place your consumer key 
	  config.consumer_secret = "" # place your consumer secret 
	  config.oauth_token = "" # place oauth token 
	  config.oauth_token_secret = "" # place oauth token secret
	end

	puts "Backing up the users you follow. Just in case..."
	file = File.open(backup_filename, "a")
	Twitter.friend_ids.each do |id|
		file.write("#{id}\n")
	end

	puts "The IDs for all the users you follow where backed up to the file #{backup_filename}"

	following = Twitter.friend_ids.all.length
	puts "You're following #{following} users"

	rate_limit_status = Twitter.rate_limit_status
	puts "#{rate_limit_status.remaining_hits} Twitter API request(s) remaining for the next #{((rate_limit_status.reset_time - Time.now) / 60).floor} minutes and #{((rate_limit_status.reset_time - Time.now) % 60).round} seconds"
	puts "When the API limit is reached, this script just quits"

	puts "Starting le grand Twitter unfollowing"
	Twitter.friend_ids.each do |id|
		begin
			
			if rate_limit_status.remaining_hits == 0
				puts "Reached API request limit. Going to sleep for #{((rate_limit_status.reset_time - Time.now) / 60).floor + 1.0}. You can stop this script at any time and resume later."
				sleep(((rate_limit_status.reset_time - Time.now) / 60).floor + 1.0) 
			end

			unfollowed_user = Twitter.unfollow(id)
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
	else
		puts "You're still following #{following} users. The API will reset in #{((rate_limit_status.reset_time - Time.now) / 60).floor} minutes and #{((rate_limit_status.reset_time - Time.now) % 60).round} seconds"
	end
rescue => e
  p e.message
  p e.backtrace
end
