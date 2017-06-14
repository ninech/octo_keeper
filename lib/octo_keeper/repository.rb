module OctoKeeper
  class Repository
    attr_reader :full_name, :name, :owner

    def initialize(attributes = {})
      @full_name = attributes['full_name']
      @name      = attributes['name']
      @owner     = attributes.dig 'owner', 'login'
    end

    def team_permissions
      OctoKeeper.config.repository_config(full_name)['permissions'] || {}
    end
  end
end
