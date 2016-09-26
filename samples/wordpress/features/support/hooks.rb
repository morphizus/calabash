require 'calabash'

Before do |scenario|
  if scenario.respond_to?(:scenario_outline)
    scenario = scenario.scenario_outline
  end

  AppLifeCycle.on_new_scenario(scenario)

  cal.start_app(uia_strategy: :host)
end

After do

end

Before('@log_in') do
  Login.ensure_logged_in
end

module AppLifeCycle
  DEFAULT_RESET_BETWEEN = :features # Filled in by calabash generate
  DEFAULT_RESET_METHOD = :clear # Filled in by calabash generate

  RESET_BETWEEN = if Calabash::Environment.variable('RESET_BETWEEN')
                    Calabash::Environment.variable('RESET_BETWEEN').downcase.to_sym
                  else
                    DEFAULT_RESET_BETWEEN
                  end

  RESET_METHOD = if Calabash::Environment.variable('RESET_METHOD')
                   Calabash::Environment.variable('RESET_METHOD').downcase.to_sym
                 else
                   DEFAULT_RESET_METHOD
                 end

  def self.on_new_scenario(scenario)
    # Ensure the app is installed at the beginning of the test,
    # if we never reset
    if @last_feature.nil? && RESET_BETWEEN == :never
      cal.ensure_app_installed
    end

    if should_reset?(scenario)
      reset
    end

    @last_feature = scenario.feature
  end

  private

  def self.should_reset?(scenario)
    if scenario.source_tag_names.include?('@always_reset')
      return true
    end

    case RESET_BETWEEN
      when :scenarios
        true
      when :features
        scenario.feature != @last_feature
      when :never
        false
      else
        raise "Invalid reset between option '#{RESET_BETWEEN}'"
    end
  end

  def self.reset
    @logged_in = false

    case RESET_METHOD
      when :reinstall
        cal.install_app
      when :clear
        cal.ensure_app_installed
        cal.clear_app_data
      when '', nil
        raise 'No reset method given'
      else
        raise "Invalid reset method '#{RESET_METHOD}'"
    end
  end
end
