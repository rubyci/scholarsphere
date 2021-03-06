# frozen_string_literal: true

module Dashboard
  module Form
    class BaseController < ::Dashboard::BaseController
      private

        def resource_klass
          case params[:resource_klass]
          when 'work_version'
            WorkVersion
          when 'collection'
            Collection
          else
            @resource.class
          end
        end

        def process_response(on_error:)
          respond_to do |format|
            if save_resource
              format.html do
                redirect_upon_success
              end
            else
              format.html { render on_error }
            end
          end
        end

        def show_footer?
          false
        end

        def save_and_exit?
          params.key?(:save_and_exit)
        end

        def publish?
          params.key?(:publish)
        end

        def finish?
          params.key?(:finish)
        end

        def redirect_upon_success
          if save_and_exit?
            redirect_to resource_path(@resource.uuid), notice: "#{@resource.model_name.human} was successfully updated."
          else
            redirect_to next_page_path
          end
        end

        def next_page_path
          raise NotImplementedError, 'You must implement this method in your controller subclass'
        end

        helper_method :cancel_path
        def cancel_path
          if @resource.present? && @resource.persisted?
            resource_path(@resource.uuid)
          else
            dashboard_root_path
          end
        end

        helper_method :param_key
        def param_key
          resource_klass.model_name.param_key
        end

        def save_resource(index: true)
          @resource.indexing_source = if (publish? || finish? || save_and_exit?) && index
                                        SolrIndexingJob.public_method(:perform_now)
                                      else
                                        null_indexer
                                      end
          @resource.save
        end

        def null_indexer
          Proc.new { nil }
        end
    end
  end
end
