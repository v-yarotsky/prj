#include <ruby.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <fts.h>

void Init_finder();

VALUE prj_finder_initialize_m(VALUE self, VALUE projectsRoot, VALUE options);
VALUE expand_path(VALUE path);

VALUE prj_finder_find_project_directories_m(VALUE self);
VALUE prj_finder_traverse_projects_root(VALUE self, char *projectsRoot, int searchNestedRepositories, VALUE (*callback)(VALUE self, const FTS *fs, const FTSENT *parent, const FTSENT *child));
VALUE prj_finder_collect_project(VALUE self, const FTS *fs, const FTSENT *parent, const FTSENT *child);
char * prj_finder_normalize_path(char *path);
VALUE prj_finder_is_vcs_dir(VALUE self, const char *dir);

VALUE Prj, PrjFinder;

void Init_finder() {
  Prj = rb_define_module("Prj");
  PrjFinder = rb_define_class_under(Prj, "Finder", rb_cObject);
  rb_define_method(PrjFinder, "initialize", prj_finder_initialize_m, 2);
  rb_define_method(PrjFinder, "find_project_directories", prj_finder_find_project_directories_m, 0);
}

VALUE prj_finder_initialize_m(VALUE self, VALUE projectsRoot, VALUE options) {
  VALUE expandedProjectsRoot, vcsDirectories, searchNestedRepositories;
  expandedProjectsRoot = expand_path(projectsRoot);

  vcsDirectories = rb_hash_aref(options, ID2SYM(rb_intern("vcs_directories")));

  if (!RTEST(vcsDirectories)) {
    vcsDirectories = rb_ary_new();
  }

  searchNestedRepositories = rb_hash_aref(options, ID2SYM(rb_intern("search_nested_repositories")));

  rb_iv_set(self, "@root", expandedProjectsRoot);
  rb_iv_set(self, "@vcs_directories", rb_check_array_type(vcsDirectories));
  rb_iv_set(self, "@search_nested_repositories", searchNestedRepositories);
  rb_iv_set(self, "@project_directories", rb_ary_new());
  return self;
}

VALUE expand_path(VALUE path) {
  VALUE file;
  file = rb_const_get(rb_cObject, rb_intern("File"));
  return rb_funcall(file, rb_intern("expand_path"), 1, rb_check_string_type(path));
}

VALUE prj_finder_find_project_directories_m(VALUE self) {
  VALUE result, root, searchNestedRepositories;

  result       = rb_iv_get(self, "@project_directories");
  root         = rb_iv_get(self, "@root");
  searchNestedRepositories = rb_iv_get(self, "@search_nested_repositories");

  if (RARRAY_LEN(result) == 0) {
    prj_finder_traverse_projects_root(self, StringValueCStr(root), RTEST(searchNestedRepositories), &prj_finder_collect_project);
  }

  return result;
}

VALUE prj_finder_traverse_projects_root(VALUE self, char *projectsRoot, int searchNestedRepositories, VALUE (*callback)(VALUE self, const FTS *fs, const FTSENT *parent, const FTSENT *child)) {
  FTS *fs        = NULL;
  FTSENT *child  = NULL;
  FTSENT *parent = NULL;

  char *paths[] = { projectsRoot, NULL };
  fs = fts_open(paths, FTS_COMFOLLOW | FTS_LOGICAL | FTS_NOSTAT, NULL);

  if (fs == NULL) {
    return Qnil;
  }

  while ((parent = fts_read(fs)) != NULL) {
    child = fts_children(fs, 0);
    while (child != NULL) {
      if (child->fts_info == FTS_D && RTEST(callback(self, fs, parent, child))) {
        fts_set(fs, (searchNestedRepositories ? child : parent), FTS_SKIP);
      }
      child = child->fts_link;
    }
  }
  fts_close(fs);

  return Qnil;
}

VALUE prj_finder_collect_project(VALUE self, const FTS *fs, const FTSENT *parent, const FTSENT *child) {
  VALUE root, result;
  char *prefixed, *unprefixed;

  if (!prj_finder_is_vcs_dir(self, child->fts_name)) {
    return Qfalse;
  }

  root   = rb_iv_get(self, "@root");
  result = rb_iv_get(self, "@project_directories");

  prefixed   = parent->fts_path;
  unprefixed = prefixed + RSTRING_LEN(root);

  rb_ary_push(result, rb_str_new2(prj_finder_normalize_path(unprefixed)));
  return Qtrue;
}

// strips unnecessary trailing / on linux
char * prj_finder_normalize_path(char *path) {
  size_t path_length;
  path_length = strlen(path);

  if (path[path_length - 1] == '/') {
    path[path_length - 1] = '\0';
  }

  return path;
}

VALUE prj_finder_is_vcs_dir(VALUE self, const char *dir) {
  VALUE vcsDirectories;
  vcsDirectories = rb_iv_get(self, "@vcs_directories");
  return rb_funcall(vcsDirectories, rb_intern("include?"), 1, rb_str_new2(dir));
}

