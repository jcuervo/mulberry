require 'rubygems'
require 'sinatra/base'

require 'mulberry'
require 'lib/builder/css_maker'
require 'app'

module Mulberry
  class Server < Sinatra::Base

    def initialize
      super

      @mulberry_app = settings.app
      @helper = @mulberry_app.helper

      @index_template = 'index.html'.to_sym
      @iframe_template = 'iframe.html'.to_sym
      @source_dir = @mulberry_app.source_dir
      @js_build_name = 'dev'
    end

    private

    #####################
    # Helpers
    #####################
    def self.mulberry_file_path(*args)
      File.join(Mulberry::Directories.root, *args)
    end

    def mulberry_file_path(*args)
      Mulberry::Server.mulberry_file_path(*args);
    end

    def self.app_file_path(*args)
      File.join(TouraAPP::Directories.root, 'toura_app', *args)
    end

    def app_file_path(*args)
      Mulberry::Server.app_file_path(*args);
    end

    #####################
    # Settings
    #####################

    disable :logging

    set :raise_errors => true
    set :root, app_file_path('.')
    set :public_folder, app_file_path('www')
    set :views, TouraAPP::Templates.root
    set :host, 'localhost'

    #####################
    # Tours
    #####################
    get '/' do
      redirect "/ios/phone/"
    end

    get "/:os/:type/" do
      haml @index_template, :locals => {
        :body_onload        => "readyFn()",
        :include_jquery     => @mulberry_app.config['jQuery'] || @mulberry_app.config['jquery'],
        :include_dev_config => true,
        :device_type        => params[:type] || 'phone',
        :device_os          => params[:os] || 'ios'
      }
    end

    get '/:os/:type/develop.html' do
      haml @iframe_template
    end

    #####################
    # CSS
    #####################
    get '/:os/:type/css/base.css' do
      content_type 'text/css'
      @helper.create_css
    end

    get '/:os/:type/css/resources/*' do
      send_file File.join(
        @helper.theme_dir,
        'resources',
        params[:splat].first
      )
    end

    #####################
    # JavaScript
    #####################

    # dojo files have to come from the built js
    get '/:os/:type/javascript/dojo/*' do
      content_type 'text/javascript'
      send_file mulberry_file_path(
        'js_builds',
        @js_build_name,
        "dojo",
        params[:splat].first
      )
    end

    get '/:os/:type/javascript/dijit/*' do
      content_type 'text/javascript'
      send_file mulberry_file_path(
        "js_builds",
        @js_build_name,
        "dijit",
        params[:splat].first
      )
    end

    # nls (i18n) files have to come from the built js
    get '/:os/:type/javascript/toura/nls/*' do
      content_type 'text/javascript'
      nls_file = mulberry_file_path(
        "js_builds",
        @js_build_name,
        "toura",
        "nls",
        params[:splat].first
      )

      if File.exists? nls_file
        send_file nls_file
      else
        '{}'
      end
    end

    get '/:os/:type/javascript/toura/app/TouraConfig.js' do
      content_type 'text/javascript'
      device_type = params[:type] || 'phone'
      os = params[:os] || 'ios'

      TouraAPP::Generators.config os, device_type,
        {
          "id" => @mulberry_app.id,
          "build" => Time.now.to_i,
          "skip_version_check" => true,
          "debug" => true
        }
    end

    get '/:os/:type/javascript/toura/app/DevConfig.js' do
      content_type 'text/javascript'

      dev_config = app_file_path(
        'javascript',
        'toura',
        'app',
        'DevConfig.js'
      )

      if File.exists? dev_config
        send_file dev_config
      else
        ''
      end
    end

    get '/:os/:type/javascript/client/*' do
      content_type 'text/javascript'
      send_file File.join(
        @source_dir,
        'javascript',
        params[:splat].first
      )
    end

    get '/:os/:type/javascript/*' do
      content_type 'text/javascript'
      send_file app_file_path(
        "javascript",
        params[:splat].first
      )
    end

    #####################
    # Data
    #####################
    get '/:os/:type/data/*' do
      content_type "text/javascript"

      begin
        case params[:splat].first
        when 'tour.js'
          TouraAPP::Generators.data(@helper.data)
        when 'templates.js'
          "toura.templates = #{JSON.pretty_generate(TouraAPP::Generators.page_templates @helper.templates)};"
        end
      rescue RuntimeError => e
        puts "ERROR: #{e.to_s}"
      end
    end

    #####################
    # Media
    #####################
    get '/:os/:type/media/manifest.js' do
      "toura.app.manifest = {};"
    end

    get '/:os/:type/media/*' do
      send_file File.join(
        @source_dir,
        "assets",
        params[:splat].first
      )
    end

    #####################
    # Resources
    #####################
    get '/:os/:type/*' do
      send_file app_file_path(
        "www",
        params[:splat].first
      )
    end
  end
end
