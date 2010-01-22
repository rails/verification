require 'rubygems'
require 'test/unit'
require 'active_support'
require 'action_controller'
require File.dirname(__FILE__) + '/../lib/action_controller/verification'

# Extracted this code from action_controller/abstract_unit.rb
module SetupOnce
  extend ActiveSupport::Concern

  included do
    cattr_accessor :setup_once_block
    self.setup_once_block = nil

    setup :run_setup_once
  end

  module ClassMethods
    def setup_once(&block)
      self.setup_once_block = block
    end
  end

  private
    def run_setup_once
      if self.setup_once_block
        self.setup_once_block.call
        self.setup_once_block = nil
      end
    end
end

class ActiveSupport::TestCase
  include SetupOnce

  # Hold off drawing routes until all the possible controller classes
  # have been loaded.
  setup_once do
    ActionController::Routing::Routes.draw do |map|
      match ':controller(/:action(/:id))'
    end
  end
end

class ActionController::IntegrationTest < ActiveSupport::TestCase
  def self.build_app(routes = nil)
    ActionDispatch::Flash
    ActionDispatch::MiddlewareStack.new { |middleware|
      middleware.use "ActionDispatch::ShowExceptions"
      middleware.use "ActionDispatch::Callbacks"
      middleware.use "ActionDispatch::ParamsParser"
      middleware.use "ActionDispatch::Cookies"
      middleware.use "ActionDispatch::Flash"
      middleware.use "ActionDispatch::Head"
    }.build(routes || ActionController::Routing::Routes)
  end

  self.app = build_app
end