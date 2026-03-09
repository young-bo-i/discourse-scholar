# frozen_string_literal: true

module DiscourseScholar
  class Engine < ::Rails::Engine
    engine_name PLUGIN_NAME
    isolate_namespace DiscourseScholar
  end
end
