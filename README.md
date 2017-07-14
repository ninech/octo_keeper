[![Build Status](https://travis-ci.org/ninech/octo_keeper.svg?branch=master)](https://travis-ci.org/ninech/octo_keeper)
[![Code Climate](https://codeclimate.com/github/ninech/octo_keeper/badges/gpa.svg)](https://codeclimate.com/github/ninech/octo_keeper)

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

    $ octo-keeper teams apply --org ninech 12345 pull

### Github Webhook

Start the webhook server to receive Github organization webhooks:

    $ export OCTOKEEPER_GITHUB_SECRET=super-secret
    $ octo-keeper webhook start --config config.yml

Now you can enter the following webhook on Github.com (https://github.com/organizations/your_organization_name/settings/hooks):

    http://hostname:4567

Choose `application/json` as the content type.

In the above example you will have to add the secret `super-secret`. You can run the webhook server without a shared secret, but that is not recommended.

## Docker

Octo-Keeper can be run in its own Docker container. You can link the configuration file into the container as a volume.

    # build the image from this repository. Or skip this line if you want to pull it from the registry.
    $ docker build . -t ninech/octo-keeper

    $ docker run --name octo-keeper \
                 -p 4567:4567 \
                 -v $(pwd)/config.example.yml:/home/octo-keeper/config.yml \
                 -e OCTOKEEPER_GITHUB_SECRET=super-secret \
                 -e OCTOKEEPER_ACCESS_TOKEN=secret-token \
                 ninech/octo-keeper

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

There is a sample event json to post to the webhook server.

```sh
$ bin/octo-keeper webhook start
# With HTTPie
$ http --json POST localhost:4567 < spec/fixtures/example-repository-create-event.json
# With Curl
$ curl -X POST http://localhost:4567/ -d @spec/fixtures/example-repository-create-event --header "Content-Type: application/json"

# Using a Github secret
$ export OCTOKEEPER_GITHUB_SECRET=super-secret
$ bin/octo-keeper webhook start
$ http --json POST localhost:4567 X-Hub-Signature:sha1=d1ee402dd2742b6646f564bffb5f5f7fe81742c3 < spec/fixtures/example-repository-create-event.json
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ninech/octo_keeper.
