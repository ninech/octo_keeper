require_relative 'base'

module OctoKeeper
  module GithubEventHandlers
    class Repository < Base
      private

      def entrypoint
        logger.info %(Received "#{action}" event for repository #{repository.full_name}.)

        handle_repository_created if action == 'created'
        "OK"
      end

      def repository
        @repository ||= OctoKeeper::Repository.new payload['repository']
      end

      def action
        payload['action']
      end

      def handle_repository_created
        repository.team_permissions.each_pair do |team_slug, permission|
          team = Team.from_slug(repository.owner, team_slug, client: OctoKeeper.octokit_client)
          if team
            save_permissions(team, permission)
          else
            logger.warn "Team #{team_slug} was not found. Cannot set permissions."
          end
        end
      end

      def save_permissions(team, permission)
        OctoKeeper.octokit_client.add_team_repository(team.id, repository.full_name, permission: permission)
        logger.info "Added #{permission} permission for team #{team.slug} on #{repository.name}."
      rescue StandardError => e
        raise ProcessingError, 500, "Setting permissions for team #{team.slug} failed: #{e.message}"
      end
    end
  end
end
