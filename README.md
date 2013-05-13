Prj
==========

Cd to your project the right way!

Prj chooses a project directory based on fuzzy matching.

It finds a project directory (a directory with .git/ inside) such that it's name
contains supplied letters in particular order. The search is scoped by projects root
directory, which is specified in ~/.prj (Default: ~/Projects). See Installation & Configuration section.

Installation & Configuration:
-----------------------------
1. Install the gem:
  ```gem install prj```
  If you are using RVM, it's recommended to install the gem into global gemset for each installed ruby.

2. ([oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh) users) Put [``scripts/zsh/prj.plugin.zsh``](https://github.com/v-yarotsky/prj/blob/master/scripts/zsh/prj.plugin.zsh) into ``~/.oh-my-zsh/custom/plugins/prj/prj.plugin.zsh``

3. Put a project root directory name into ~/.prj, i.e:
   ```
   ~/Projects
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

