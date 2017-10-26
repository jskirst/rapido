require 'active_support'
require 'active_support/core_ext'
require 'rapido/errors'

module Rapido
  module AppController
    extend ActiveSupport::Concern

    include Rapido::Errors

    included do
      rescue_from RecordNotFound do |e|
        render file: 'public/404', status: :not_found, layout: false
      end
    end

    def index
      @resource_collection = resource_collection
    end

    def show
      @resource = resource
    end

    def new
      @resource = owner.send(resource_class_name.pluralize).new
    end

    def create
      new_resource = build_resource
      if new_resource.save
        redirect_to after_create_path(new_resource)
      else
        flash[:error] = new_resource.errors.full_messages.join('. ')
        redirect_to new_resource
      end
    end

    def destroy
      resource.destroy
      redirect_to index_controller_path
    end

    def edit
      @resource = resource
    end

    def update
      resource.assign_attributes(resource_params)
      if resource.save
        redirect_to after_update_path(resource)
      else
        flash[:error] = resource.errors.full_messages.join('. ')
        resource.reload
        redirect_to edit_path(resource)
      end
    end

    private

    def resource_path(action, resource)
      keys = {
        controller: params[:controller],
        action: action,
        resource_lookup_param => resource.send(resource_lookup_param)
      }
      keys[owner_lookup_param] = owner.send(owner_lookup_field) if owner_lookup_param.present?
      url_for(keys)
    end

    def edit_path(resource)
      resource_path(:edit, resource)
    end

    def show_path(resource)
      resource_path(:show, resource)
    end

    def after_create_path(resource)
      show_path(resource)
    end

    def after_update_path(resource)
      show_path(resource)
    end
  end
end
