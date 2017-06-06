module OctoKeeper
  class Team
    # looks for a team by slug
    def self.from_slug(organization, slug, client: Octokit::Client.new)
      client.org_teams(organization).find { |team| team.slug == slug }
    end
  end
end
