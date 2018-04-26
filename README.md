Prj
==========

[![Build Status](https://travis-ci.org/v-yarotsky/prj.png?branch=master)](https://travis-ci.org/v-yarotsky/prj)
[![Code Climate](https://codeclimate.com/github/v-yarotsky/prj.png)](https://codeclimate.com/github/v-yarotsky/prj)
[![Gem Version](https://badge.fury.io/rb/prj.png)](http://badge.fury.io/rb/prj)

Cd to your project the right way!

Prj chooses a project directory based on fuzzy matching.

It finds a project directory (a directory with .git/ or other vcs directory inside) such that it's name
contains supplied letters in given order. The search is scoped by projects root
directory, which is specified in ~/.prj.yml config file (Default: ~/Projects).
See Installation & Configuration section.

*now even faster with C extension*

Installation & Configuration:
-----------------------------
1. Install the gem:

   ```gem install prj```

2. Configure your shell:
  * ([oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh) users) Put [scripts/zsh/prj.plugin.zsh](https://raw.github.com/v-yarotsky/prj/master/scripts/zsh/prj.plugin.zsh) into ``~/.oh-my-zsh/custom/plugins/prj/prj.plugin.zsh``.
   Don't forget to enable the plugin in ~/.zshrc

  * (bash users) Add the following snippet to your .bash_profile:

        function p() {
            builtin cd "$(prj $1)"
        }

3. Put a project root directory name into ~/.prj.yml, i.e:
   ```
   projects_root: ~/Projects
   case_sensitive: false                 # default: true
   search_nested_repositories: false     # default: false (slower if true)
   vcs_directories:                      # default: [.git]
     - .git
     - .svn
     - .hg
   ```

Usage:
------

With the following directory structure
```
~/
  Projects/
    my_super_project/
    rails/
    love_hate_unicorns/
```
You can reach ``~/Projects/my_super_project`` with ```p msp```

