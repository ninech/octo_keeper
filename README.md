# OctoKeeper

This is a little command line tool which allows you to manage access to your Github organization's repositories.

We at nine.ch use it to automatically set team permissions for all our repositories.

## Installation

Install it with:

    $ gem install octo_keeper

## Usage

Create a new Github access token [https://github.com/settings/tokens](https://github.com/settings/tokens).

Make sure your token has `repo` and `admin:org` permissions.

Set an environment variable with you Github access token:

    $ export OCTOKEEPER_ACCESS_TOKEN=<token>

Then you can fetch a list of your teams with the following command:

    $ octo-keeper teams list --org ninech

Or you can apply permissions to all repositories for one team:

    $ octo-keeper apply --org ninech 12345 pull

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ninech/octo_keeper.
