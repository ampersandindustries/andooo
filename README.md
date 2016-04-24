## Andooo
[![Build Status](https://travis-ci.org/ampersandindustries/andooo.svg?branch=master)](https://travis-ci.org/ampersandindustries/andooo)

## Welcome :rocket::rocket::rocket:

This is a fork of the membership application app written by members of [Double Union](http://doubleunion.org/), a feminist hacker/makerspace for women in San Francisco. That app is called Arooo (after A Room Of One's Own). AndConf + Arooo = Andooo. :100:

It's being used by [AndConf](https://www.andconf.io/), an intersectional feminist code retreat and unconference to manage applications to attend the conference.


## How to Contribute

We use [GitHub issues](https://github.com/ampersandindustries/andooo/issues) for feature development and bug tracking, so take a look for things that you can work on, and comment with any questions you have about half-baked issues.

## Development setup

If you are new to Rails, follow the [RailsBridge Installfest instructions](http://installfest.railsbridge.org/installfest/) for getting your environment set up.

0. Fork the repo (click the Fork button above), and clone your fork to your local machine. [Here's a GitHub tutorial](https://help.github.com/articles/fork-a-repo/) about how to do so.

1. Standard Rails app setup
    * `cp config/database.example.yml config/database.yml`
    * Optional: edit database.yml if you want to change advanced things
    * `rake db:create`
    * `rake db:migrate`
    * `rake db:test:prepare`

1. Set up an application for OAuth: http://github.com/settings/applications/new
    * Application name: Whatever you want
    * Homepage URL: http://localhost:3000
    * Authorization callback URL: http://localhost:3000/auth/github/callback

1. `cp config/application.example.yml config/application.yml`

1. Edit config/application.yml
    * Set `GITHUB_CLIENT_KEY` and `GITHUB_CLIENT_SECRET` to the Client ID and
      Client Secret from your Github application
    * Don't forget to restart your Rails server so it can see your shiny new GitHub key & secret

## Specs

Write specs! Yay! Especially for anything involving authorization walls.

Run `rake db:test:prepare` after you pull or make any changes to the app, generally.

Make sure `bundle exec rspec` passes before pushing your changes.

## Rails console

Development: `$ bundle exec rails console`

Production: `$ heroku run rails console`

## Populate development database

To add a bunch of users to your dev database, you can use `bundle exec rake
populate:users`. They will have random states.

## Contributing

If you are new to GitHub, you can [use this guide](http://railsbridge.github.io/bridge_troll/) for help making a pull request.

1. Fork it
1. Get it running
1. Create your feature branch

  ```
  git checkout -b my-new-feature
  ```

1. Write your code and specs
1. Commit your changes

  ```
  git commit -am 'Add some feature'
  ```

1. Push to the branch

  ```
  git push origin my-new-feature
  ```

1. Create a new Pull Request, linking to the GitHub issue url the Pull Request is fixing in the description
1. If you find bugs, have feature requests or questions, please file an issue.


## License

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the LICENSE.txt file for the full license.
