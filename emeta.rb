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
end
