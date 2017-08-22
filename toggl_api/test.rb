#!/usr/bin/env ruby

require 'json'
require 'rest-client'
require 'base64'
require 'csv'

API_TOKEN = '0eb025f381a5ac7be7a4177c3004bc0b'
auth =  Base64.encode64("#{API_TOKEN}:api_token")
puts "[LOG] start at #{Time.now.strftime("%d/%m/%Y %H:%M")}, decode auth: #{auth}"

response = RestClient.get "https://www.toggl.com/api/v8/workspaces", {'Content-Type': 'application/json', 'Authorization': "Basic #{auth}"}
puts "[LOG] request workspaces, http response code: #{response.code}"

workspace_hash = JSON.parse(response.body)
CSV.open("toggl.csv","w") do |csv|
	csv << ['description','project','user','duration','start','end']
	workspace_hash.each do |workspace|
		puts "[LOG] workspace_id: #{workspace['id']}, workspaces_name: #{workspace['name']}"
		report_response	= RestClient.get "https://toggl.com/reports/api/v2/details.json?user_agent=luogh@chinacscs.com&workspace_id=#{workspace['id']}", {'Content-Type': 'application/json', 'Authorization': "Basic #{auth}"}
		puts "[LOG] request detail report, http response code: #{report_response.code}"
		report_hash = JSON.parse(report_response.body)
		total_page = report_hash['total_count']/50 + 1
		puts "[LOG] report has #{total_page} pages"	
		report_hash['data'].each do |t|
			if t['description'] && t['project'] && t['user'] && t['dur'] > 60000 # >1min
				csv << [t['description'],t['project'],t['user'],t['dur'],t['start'],t['end']]
			end
		end
		# next page	
		if total_page >1 
			(total_page..2).each do |page|
				puts "[LOG] jump to page:#{page}"	
				report_response	= RestClient.get "https://toggl.com/reports/api/v2/details.json?user_agent=luogh@chinacscs.com&workspace_id=#{workspace['id']}&page=#{page}", {'Content-Type': 'application/json', 'Authorization': "Basic #{auth}"}
		
				puts "[LOG] http response code: #{report_response.code}"
				report_hash = JSON.parse(report_response.body)
				report_hash['data'].each do |t|
					if t['description'] && t['project'] && t['user'] && t['dur'] > 60000 # >1min
						csv << [t['description'],t['project'],t['user'],t['dur'],t['start'],t['end']]
					end
				end
			end
		end
	end
end
puts "============== END ================="
