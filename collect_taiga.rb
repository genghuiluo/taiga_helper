#!/usr/bin/env ruby

require 'json'
require 'rest-client'
require 'mysql2'

# taiga REST api
# https://taigaio.github.io/taiga-doc/dist/api.html#projects-list

API_ENDPOINT = '121.13.219.103'
AUTH_TOKEN = 'eyJ1c2VyX2F1dGhlbnRpY2F0aW9uX2lkIjo2OH0:1fDKFI:_4Tz0klpxU24qdkIZh5q_WWJ6yg'
PROJECT_ID = 46

def taiga_http_get(endpoint,hash=[],page=1)
	
	response = RestClient.get endpoint+"&page=#{page}", {'Content-Type':'application/json', 'Authorization':"Bearer #{AUTH_TOKEN}"}
	puts "[INFO] request: "+endpoint+"&page=#{page}"
	
	if response.code == 200 then
		new_hash = JSON.parse(response.body)
		if new_hash.size == 30 then
			# need to request next page, &page=2
			page = page+1
			new_hash = hash+new_hash
			taiga_http_get(endpoint,new_hash,page)
		else
			return hash+new_hash	
		end
	else
		puts "[ERROR] incorrect request for #{endpoint}"
		exit
	end

end

client = Mysql2::Client.new(:host => "localhost", :username => "root", :password => "1234", :database => "taiga_data")
escaped = client.escape("'")

# US
us_endpoint = "http://#{API_ENDPOINT}:3030/api/v1/userstories?project=#{PROJECT_ID}&status__is_closed=false"
us_hash = taiga_http_get(us_endpoint)
us_hash.each do |us|
	#puts "#{us['id']},#{us['subject']},#{us['milestone_name']},#{us['backlog_order']}"
	client.query("delete from user_story where id=#{us['id']}")
	client.query("insert into user_story values(#{us['id']},'#{us['subject']}','#{us['milestone_name']}',#{us['milestone_name']?false:true})")
end

# issue
issue_endpoint = "http://#{API_ENDPOINT}:3030/api/v1/issues?project=46"
issue_hash = taiga_http_get(issue_endpoint)
issue_hash.each do |issue|
	#puts "#{issue['id']},#{issue['subject']},#{issue['assigned_to']},#{issue['status']},#{issue['is_closed']},#{issue['type']},#{issue['created_date'][0..9]}"
	subject = issue['subject'].gsub "'",""
	client.query("delete from issue where id=#{issue['id']}")
	client.query("insert into issue values(#{issue['id']},'#{subject}',#{issue['assigned_to']},#{issue['is_closed']},#{issue['type']},'#{issue['created_date'][0..9]}')")
end

# user
user_endpoint = "http://#{API_ENDPOINT}:3030/api/v1/users?project=46"
user_hash = taiga_http_get(user_endpoint)
user_hash.each do |user|
	#puts "#{user['id']},#{user['full_name']}"
	client.query("delete from taiga_user where id=#{user['id']}")
	client.query("insert into taiga_user values(#{user['id']},'#{user['full_name']}')")
end

# task
task_endpoint = "http://#{API_ENDPOINT}:3030/api/v1/tasks?project=46"
task_hash = taiga_http_get(task_endpoint)
task_hash.each do |task|
	#puts "#{task['id']},#{task['user_story']},#{task['subject']},#{task['assigned_to']}"
	subject = task['subject'].gsub "'",""
	client.query("delete from task where id=#{task['id']}")
	#puts "insert into task values(#{task['id']},#{task['user_story']},'#{subject}',#{task['assigned_to'] || 'null'})"
	client.query("insert into task values(#{task['id']},#{task['user_story']},'#{subject}',#{task['assigned_to'] || 'null'})")
end

# issue type
issue_type_endpoint = "http://#{API_ENDPOINT}:3030/api/v1/issue-types?project=46"
issue_type_hash = taiga_http_get(issue_type_endpoint)
issue_type_hash.each do |issue_type|
	#puts "#{issue_type['id']},#{issue_type['name']}"
	client.query("delete from issue_type where id=#{issue_type['id']}")
	client.query("insert into issue_type values(#{issue_type['id']},'#{issue_type['name']}')")
end

