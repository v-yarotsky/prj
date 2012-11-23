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

2. Put the following snippet into your .zshrc (.bashrc)
   ```
   function p() {
     builtin cd "$(prj $1)"
   }
   ```

3. Put a project root directory name into ~/.prj, i.e:
   ```
   ~/Projects
   ```

Usage:
------
```p letters_from_your_project_folder_name```

