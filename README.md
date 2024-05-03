# Introduction

Stoplight is a build monitoring tool that is largely based off [greenscreen](https://github.com/martinjandrews/greenscreen), but is much improved and expandable. To quickly name a few, Stoplight has:

- built-in support for [GoCD](https://www.gocd.org/)
- built-in support for [Jenkins](http://www.jenkis-ci.org)
- built-in support for [Travis-CI](http://travis-ci.org)
- custom provider support
- reusable DSL

Stoplight is designed to be displayed on large television screens or monitors. It automatically resizes to fill the maximum real estate the screen can offer.

And: It's (still) one of the most beautiful build monitors out there IMO.

## Installation

### Configure the target server

1 Create a config file `config/servers.yml` with your desired server types e.g. thoughtworks_go, jenkins

Example:

```yaml
-
  type: 'thoughtworks_go'
  url: http://127.0.0.1:8153
  projects:
    - /.*::.*::.*/ #To show only jobs and not stages
```

You can override these values with environment variables. This makes it easier to run it in a container context e.g. Kubernetes, OpenShift etc:

```text
STOPLIGHT_USERNAME
STOPLIGHT_PASSWORD
STOPLIGHT_SERVER_URL
```

Please note that user credentials _must_ be provided with the ENV variables. The `username` and `password` options in the file will _not_ work.

The URL can be overridden with the `STOPLIGHT_SERVER_URL` ENV variable or can be set in the config file.

For cloud usage we recommend using the ENV variable. See [12factorApp](https://12factor.net/config) for context.

All servers must specify a `type` option within the `config/servers.yml` file.
This tells Stoplight what provider it should use (see below).

2 Run the service

2.1 Docker Compose (recommended)

- Make sure you've adjusted the `environment` parameters in the `docker-compose.yml`
- Run this command to start the service:

```shell
docker-compose up
```

2.2 Docker

- Run this command to build the Docker image:

```shell
docker build -t stoplight .
```

- Now you can start the container:

```shell
docker run -it -p 5000:5000 -v $PWD/config/servers.yml:/usr/src/app/config/servers.yml --name stoplight stoplight
```

If your CI server requires username and password for authentication run docker like this:

```shell
docker run --env STOPLIGHT_USERNAME="<name>" --env STOPLIGHT_PASSWORD="<password>" -it -p 5000:5000 -v $PWD/config/servers.yml:/usr/src/app/config/servers.yml --name stoplight stoplight
```

2.3 Ruby native

Stoplight is a Rack application, so you'll need to install Ruby and Rubygems before you can run Stoplight. **Stoplight requires Ruby 1.9.x**.

Start by cloning the application repository:

```shell
git clone git@github.com:customink/stoplight.git
```

And then bundle all the application's dependencies:

```shell
bundle install
```

3 Open this address in your browser: `http://localhost:5000/`. Type `t` to toggle the project list.

## Demo

If you want to get up and running quickly and just see what Stoplight looks like, add the following to your configuration file. It will pull data from the public repos of the Travis CI project itself:

```yaml
-
  type: 'travis'
  url: https://api.travis-ci.org
  build_url: https://travis-ci.org
  owner_name: travis-ci
```

Start the server with the `rackup` command:

```shell
rackup ./config.ru
```

Navigate to `http://localhost:9292` and check it out! You should see the status of a bunch of builds. The screen will refresh every 15 seconds to keep itself up to date.

For example, if you are using Jenkins CI, your provider is `Jenkins` and the server type is `jenkins`.

If you are using the Jenkins [`folders` plugin](https://www.cloudbees.com/products/cloudbees-jenkins-platform/team-edition/features/folders-plugin), the job handling slightly changes and you need to specify the `jenkins_folders` type.

## FAQ

### How can I filter projects?

If you have a lot of projects, you may want to selective display them on Stoplight. Luckily, this is just a simple configuration option. To ignore certain projects, just add the `ignored_projects` field to the config. It even supports regular expressions:

```yml
-
  type: 'travis'
  url: 'http://api.travis-ci.org'
  ignored_projects:
    - /^rails-(.*)$/
    - some_other_project
```

Conversely, you can choose to only show certain projects with the `projects` option:

```yml
-
  type: 'thoughtworks_go'
  url: https://gocd.example.com
  projects:
    - /.*::.*::.*/ #To show only jobs and not stages
```

## My server is not yet supported. How can I support it?

If you were using a custom server, the configuration might look like:

```yaml
-
  type: 'my_server'
  url: '...'
```

This would look for a provider named `MyServer` under `lib/stoplight/providers`. For more information on writing a custom provider, see the **Providers** part in Contributing section.

## Contributing

The development environment is configured with all kinds of goodies like Spork, Guard, and Foreman. If you're developing, just run `foreman start` and code! As you write tests and code, Guard will run the tests, Spork will make it fast, and Growl will tell you if they passed or failed!

## Providers

One of the larger goals of Stoplight was to server the open source community. As more Continuous Integration servers emerge, we needed a common DSL for interacting with them. This all arose when we wanted to add Travis CI support to Greenscreen. Greenscreen was written for CI's that conform to a standard that doesn't even exist anymore. Stoplight doesn't care how the data comes in from the provider!

A `Provider` is really just a ruby class that defines two methods:

```ruby
class MyProvider < Provider
  def provider
    'my provider'
  end

  def projects
    # logic here
  end
end
```

The `provider` method is just a utility method that returns the name of the provider. The `projects` method is the "magical" method. This is where a developer parses the data into the given specification. You should take a look in `lib/stoplight/providers/sample.rb` for a good starting point.

## Views/Styles/Layouts

If you are looking to change the design, add styles or javascripts, you'll need to know a little bit about the architecture of the application.

- **All** javascript should be written in coffeescript. The coffeescript files live in `app/assets/javascripts`. They are compiled to `public/javascripts`.
- **All** css should be written in scss + compass. The scss files live in `app/assets/stylesheets`. They are compiled to `public/stylesheets`.

## Credits

- GreenScreen was original developed by [martinjandrews](https://github.com/martinjandrews/greenscreen/).
- The former version of GreenScreen was a fork of the updates made by [rsutphin](https://github.com/rsutphin/greenscreen/).
- This version of Stoplight was written by [sethvargo](https://github.com/sethvargo)
