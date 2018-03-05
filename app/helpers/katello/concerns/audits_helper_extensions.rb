module Katello
  module Concerns
    module AuditsHelperExtensions
      extend ActiveSupport::Concern

      module Overrides
        MAIN_OBJECTS_FOR_AUDITS = %w(SyncPlan ActivationKey GpgKey Product HostCollection).freeze

        def id_to_label(name, change, truncate = true)
          return _("N/A") if change.nil?
          case name
          when "ancestry"
            label = change.blank? ? "" : change.split('/').map { |i| Hostgroup.find(i).name rescue _("NA") }.join('/')
          when 'last_login_on'
            label = change.to_s(:short)
          when /.*_id$/
            label = find_label_by_column(name, change)
          else
            label = (change.to_s == AuditExtensions::REDACTED) ? _(change.to_s) : change.to_s
          end
          label = _('[empty]') if label.blank?
          if truncate
            label = label.truncate(50)
          else
            label = label.strip.split("\n")[0]
          end
          label
        rescue
          _("N/A")
        end

        private

        def find_label_by_column(name, change)
          class_name = name.classify.gsub('Id', '')
          unless Object.const_defined?(class_name)
            class_name = 'GpgKey' if class_name.eql?('SslClientKey')
            class_name = "Katello::#{class_name}"
          end
          class_name.constantize.find(change).to_label
        end

        def main_object?(audit)
          type = audit.auditable_type.split("::").last rescue ''
          return super(audit) unless MAIN_OBJECTS_FOR_AUDITS.include?(type)
          MAIN_OBJECTS_FOR_AUDITS.include?(type)
        end
      end
      included do
        prepend Overrides
      end
    end
  end
end
