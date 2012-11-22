Prj
==========

Cd to your project the right way!

Prj chooses a project directory based on fuzzy matching


Installation:
-------------

Put this into your .zshrc (.bashrc)

```
function p() {
  builtin cd "$(prj $1)"
}
```

Put a project root directory into ~/.prj, i.e:

```
~/Projects
```

and run ```p letters_from_your_project_folder_name```


Usage:
------

```
cd some_project
```
