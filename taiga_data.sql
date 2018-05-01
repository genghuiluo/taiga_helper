-- ddl of taiga_data

drop database if exists taiga_data;

create database taiga_data;

use taiga_data;

drop table if exists user_story;

create table user_story (
	id int,
	subject nvarchar(500),
	sprint varchar(50),
	is_backlog bool -- true is in backlog
) character set utf8;

create table issue (
	id int,
	subject nvarchar(500),
	assigned_to int,
	is_closed bool,
	type int,
	created_date timestamp
) character set utf8;

create table taiga_user (
	id int,
	full_name nvarchar(100)
) character set utf8;

create table task (
	id int,
	story_id int,
	subject nvarchar(500),
	assigned_to int
) character set utf8;

create table issue_type (
	id int,
	issue_type varchar(20)
) character set utf8;	
