#include <ruby.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <fts.h>

void Init_finder();

VALUE prj_finder_initialize(VALUE self, VALUE projectsRoot, VALUE vcsDirectories);

VALUE prj_finder_find_project_directories(VALUE self);
VALUE traverse_projects_root(VALUE self, char *projectsRoot, VALUE (*callback)(VALUE self, const FTS *fs, const FTSENT *parent, const FTSENT *child));
VALUE collect_project(VALUE self, const FTS *fs, const FTSENT *parent, const FTSENT *child);
char * normalize_path(char *path);
VALUE is_vcs_dir(VALUE self, const char *dir);

VALUE Prj, PrjFinder;

void Init_finder() {
  Prj = rb_define_module("Prj");
  PrjFinder = rb_define_class_under(Prj, "Finder", rb_cObject);
  rb_define_method(PrjFinder, "initialize", prj_finder_initialize, 2);
  rb_define_method(PrjFinder, "find_project_directories", prj_finder_find_project_directories, 0);
  rb_define_private_method(PrjFinder, "traverse_projects_root", traverse_projects_root, 0);
}

VALUE prj_finder_initialize(VALUE self, VALUE projectsRoot, VALUE vcsDirectories) {
  VALUE file, expandedProjectsRoot;
  file = rb_const_get(rb_cObject, rb_intern("File"));
  expandedProjectsRoot = rb_funcall(file, rb_intern("expand_path"), 1, rb_check_string_type(projectsRoot));

  rb_iv_set(self, "@root", expandedProjectsRoot);
  rb_iv_set(self, "@vcs_directories", rb_check_array_type(vcsDirectories));
  rb_iv_set(self, "@project_directories", rb_ary_new());
  return self;
}

VALUE prj_finder_find_project_directories(VALUE self) {
  VALUE result;
  VALUE root;

  result = rb_iv_get(self, "@project_directories");
  root   = rb_iv_get(self, "@root");

  if (RARRAY_LEN(result) == 0) {
    traverse_projects_root(self, StringValueCStr(root), &collect_project);
  }

  return result;
}

VALUE traverse_projects_root(VALUE self, char *projectsRoot, VALUE (*callback)(VALUE self, const FTS *fs, const FTSENT *parent, const FTSENT *child)) {
  FTS *fs        = NULL;
  FTSENT *child  = NULL;
  FTSENT *parent = NULL;

  char *paths[] = { projectsRoot, NULL };
  fs = fts_open(paths, FTS_COMFOLLOW | FTS_LOGICAL | FTS_NOSTAT | FTS_SEEDOT, NULL);

  if (fs != NULL) {
    while ((parent = fts_read(fs)) != NULL) {
      child = fts_children(fs, 0);
      while ((child != NULL) && (child->fts_link != NULL)) {
        child = child->fts_link;
        switch(child->fts_info) {
          case FTS_D:
          case FTS_DP:
            {
              if (RTEST(callback(self, fs, parent, child))) {
                fts_set(fs, parent, FTS_SKIP);
              }
            }
            break;
          default: ;
        }
      }
    }
    fts_close(fs);
  }
  return Qnil;
}

VALUE collect_project(VALUE self, const FTS *fs, const FTSENT *parent, const FTSENT *child) {
  VALUE root, result;
  char *prefixed, *unprefixed;

  if (!is_vcs_dir(self, child->fts_name)) {
    return Qfalse;
  }

  root   = rb_iv_get(self, "@root");
  result = rb_iv_get(self, "@project_directories");

  prefixed   = parent->fts_path;
  unprefixed = prefixed + RSTRING_LEN(root);

  rb_ary_push(result, rb_str_new2(normalize_path(unprefixed)));
  return Qtrue;
}

// strips unnecessary trailing / on linux
char * normalize_path(char *path) {
  size_t path_length;
  path_length = strlen(path);

  if (path[path_length - 1] == '/') {
    path[path_length - 1] = '\0';
  }

  return path;
}

VALUE is_vcs_dir(VALUE self, const char *dir) {
  VALUE vcsDirectories;
  vcsDirectories = rb_iv_get(self, "@vcs_directories");
  return rb_funcall(vcsDirectories, rb_intern("include?"), 1, rb_str_new2(dir));
}

