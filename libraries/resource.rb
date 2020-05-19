module Dhcp
  module Cookbook
    module ResourceHelpers
      def create_list_resource(directory)
        with_run_context(:root) do
          edit_resource(:directory, directory)
          edit_resource(:template, "#{directory}/list.conf") do
            cookbook 'dhcp'
            source 'list.conf.erb'

            owner new_resource.owner
            group new_resource.group
            mode new_resource.mode

            variables['files'] ||= []

            action :nothing
            delayed_action :create
          end
        end
      end

      def add_to_list_resource(directory, config_file)
        manage_list_resource(directory, config_file, :add)
      end

      def remove_from_list_resource(directory, config_file)
        manage_list_resource(directory, config_file, :remove)
      end

      private

      def manage_list_resource(directory, config_file, action)
        begin
          list = find_resource!(:template, "#{directory}/list.conf")
        rescue Chef::Exceptions::ResourceNotFound
          list = create_list_resource(directory)
        end

        files = list.variables['files']

        case action
        when :add
          files.push(config_file)
        when :remove
          files.delete(config_file) if files.include?(config_file)
        end
      end
    end
  end
end
