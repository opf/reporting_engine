require 'rails/engine'

module ReportingEngine
  class Engine < ::Rails::Engine
    engine_name :reportingengine

    config.autoload_paths += Dir["#{config.root}/lib/"]

    initializer 'reportingengine.precompile_assets' do
      Rails.application.config.assets.precompile += %w(reporting_engine.css reporting_engine.js)
    end

    initializer 'check mysql version' do
      connection = ActiveRecord::Base.connection
      adapter_name = connection.adapter_name.to_s.downcase.to_sym
      if [:mysql, :mysql2].include?(adapter_name)
        # The reporting engine is incompatible with the
        # following mysql versions due to a bug in MySQL itself:
        # 5.6.0 - 5.6.12
        # 5.7.0 - 5.7.1
        # see https://www.openproject.org/issues/967 for details.
        required_patch_levels = { "5.6" => 13, "5.7" => 2 }

        mysql_version = connection.show_variable("VERSION")
        release_version, patch_level = mysql_version.match(/(\d*\.\d*)\.(\d*)/).captures
        required_patch_level = required_patch_levels[release_version]

        if required_patch_level && (patch_level.to_i < required_patch_level)
          raise "MySQL #{mysql_version} is not supported. Version #{release_version} \
                 requires patch level >= #{required_patch_level}."
        end
      end
    end

    config.to_prepare do
      require 'reporting_engine/patches'
      require 'reporting_engine/patches/big_decimal_patch'
      require 'reporting_engine/patches/to_date_patch'
      #We have to require this here because Ruby will otherwise find Date
      #as Object::Date and Rails wont autoload Widget::Filters::Date
      require_dependency 'widget/filters/date'
    end
  end
end
