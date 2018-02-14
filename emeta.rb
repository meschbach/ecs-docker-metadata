require 'sinatra'
require 'httparty'

class EMeta < Sinatra::Base
	get "/" do
		"OK"
	end

	get "/instance" do
		HTTParty.get( "http://169.254.169.254/latest/meta-data/instance-id", timeout: 1 ).body
	end

	get "/iam" do
		HTTParty.get( "http://169.254.169.254/latest/meta-data/iam/info", timeout: 1 ).body
	end

	get "/pkcs7" do
		HTTParty.get( "http://169.254.169.254/latest/dynamic/instance-identity/pkcs7", timeout: 1 ).body
	end

	get "/env" do
		content_type 'text/plain'
		`env`
	end

	get "/ecs" do
		content_type 'text/plain'
		url = "http://169.254.170.2" + ENV['AWS_CONTAINER_CREDENTIALS_RELATIVE_URI']
		body = HTTParty.get( url, timeout: 1 ).body
		url + "\n" + body
	end

	get "/vault" do
		# Nonce
		nonce = File.read( ENV['NONCE_FILE'] ).strip! if ENV['NONCE_FILE']
		nonce = ENV['NONCE'] if ENV['NONCE']

		# Hosts
		hosts = [ ENV['VAULT_HOST'] ] if ENV['VAULT_HOST']
		if ENV['VAULT_HOSTS_FILE']
			vault_hosts_file = File.read( ENV['VAULT_HOSTS_FILE'] )
			hosts = vault_hosts_file.split( "\n" ).map { |line| line.split( " " )[0] }
		end

		# Certificate
		pkcs7 = HTTParty.get( 'http://169.254.169.254/latest/dynamic/instance-identity/pkcs7' ).body.split( "\n" ).join("")

		url = "https://" + hosts[0] + ":8200" + "/v1/auth/aws-ec2/login"
		body = HTTParty.post( url,
			:body => {
				:role => "engine-role",
				:nonce => nonce,
				:pkcs7 => pkcs7
			}.to_json,
			:headers => { 'Content-Type' => 'application/json' },
			:verify => false
		).body

		content_type 'application/json'
		{
			:url => url,
			:inputs => {
				:hosts => hosts,
				:nonce => nonce,
				:pkcs7 => pkcs7
			},
			:body => body
		}.to_json
	end
end
