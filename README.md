# Docker Rails with Pronto For Gitlab CI

## What will happen?

![Pronto messages posted to gitlab](https://raw.githubusercontent.com/muhammet/docker-rails/master/pronto_result_0.png)

![Pronto started a discussion on commit](https://raw.githubusercontent.com/muhammet/docker-rails/master/pronto_result_1.png)

The [Docker Rails](https://github.com/newsdev/docker-rails) with additions to support pronto gem for gitlab ci.

## What is pronto?

[A code review tool.](https://github.com/prontolabs/pronto)

## Included Packages
package|version
:---|:---
[ruby](https://www.ruby-lang.org/)|2.4.1
[cmake](https://cmake.org/)|3.4.3
[libssh](http://www.libssh2.org/)|1.6.0
[node](https://nodejs.org/)|~~8.1.2~~ 10.12.0
[libgit2](https://github.com/libgit2/libgit2) | master

## Add pronto to your Gemfile

```
gem 'pronto'
gem 'pronto-brakeman', require: false
gem 'pronto-flay', require: false
gem 'pronto-rails_best_practices', require: false
gem 'pronto-rails_schema', require: false
gem 'pronto-rubocop', require: false
```

[More Runners](https://github.com/prontolabs/pronto#runners)

## Example `.gitlab-ci.yml`

```
# image: "muhammet/docker-rails-with-pronto:latest" node v8.1.2
image: "svtek/docker-rails-with-pronto:latest" # node v10.12.0
services:
  - mysql:latest
  - redis:latest

variables:
  # Configure mysql environment variables (https://hub.docker.com/r/_/mysql/)
  MYSQL_DATABASE: blah
  MYSQL_ROOT_PASSWORD: blah

stages:
  - review

before_script:  
  - gem install bundler --no-ri --no-rdoc
  - bundle install --jobs $(nproc) "${FLAGS[@]}"

review:
  stage: review
  tags:
    - ruby
    - linux
  script:
    - PRONTO_GITLAB_API_PRIVATE_TOKEN=YOUR_PRIVATE_TOKEN pronto run -f gitlab -c origin/master

```

**Note:** *If you get an error in GitLab runner like: Either installing with `--full-index` or running `bundle update i18n-tasks`* replace the `gem install bundler --no-ri --no-rdoc` line with `gem install bundler --no-ri --no-rdoc --version 1.14.6`


## Authors
| [<img src="https://pbs.twimg.com/profile_images/1331045707961274368/-YifJbqn_400x400.jpg" width="100px;"/>](https://twitter.com/sahin)   | [Sahin Boydas](https://twitter.com/sahinboydas)<br/><br/><sub>Founder @ [RemoteTeam.com](https://www.remoteteam.com)</sub><br/> [![LinkedIn][1.1]][1]| [<img src="https://avatars1.githubusercontent.com/u/989759?s=460&v=4" width="100px;"/>](https://github.com/muhammet)   | [Muhammet](https://github.com/muhammet)<br/><br/><sub>Developer @ [MojiLaLa](http://mojilala.com)</sub><br/> [![Github][2.1]][2] | [<img src="https://avatars1.githubusercontent.com/u/8470005?s=460&v=4" width="100px;"/>](https://github.com/sadikay)   | [Sadik](https://github.com/sadikay)<br/><br/><sub>Backend Engineer @ [MojiLaLa](http://mojilala.com)</sub><br/> [![Github][3.1]][3]
| - | :- | - | :- | - | :- |

[1.1]: https://www.kingsfund.org.uk/themes/custom/kingsfund/dist/img/svg/sprite-icon-linkedin.svg (linkedin icon)
[1]: https://www.linkedin.com/in/sahinboydas
[2.1]: http://i.imgur.com/9I6NRUm.png (github.com/muhammet)
[2]: http://www.github.com/muhammet
[3.1]: http://i.imgur.com/9I6NRUm.png (github.com/sadikay)
[3]: http://www.github.com/sadikay

Many thanks to [@newsdev](https://github.com/newsdev) for [Docker Rails](https://github.com/newsdev/docker-rails) project.
