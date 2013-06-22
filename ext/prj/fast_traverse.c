#include <ruby.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <fts.h>

void Init_fast_traverse();

VALUE prj_fast_traverse_traverse_m(VALUE self, VALUE projects_root, VALUE search_nested_repositories);

VALUE Prj, FastTraverse;

void Init_fast_traverse() {
    Prj = rb_define_module("Prj");
    FastTraverse = rb_define_module_under(Prj, "FastTraverse");
    rb_define_singleton_method(FastTraverse, "traverse", prj_fast_traverse_traverse_m, 2);
}

VALUE prj_fast_traverse_traverse_m(VALUE self, VALUE projects_root, VALUE search_nested_repositories) {
    FTS *fs        = NULL;
    FTSENT *child  = NULL;
    FTSENT *parent = NULL;
    VALUE parent_path, child_name;

    char *paths[] = { StringValueCStr(projects_root), NULL };
    fs = fts_open(paths, FTS_COMFOLLOW | FTS_LOGICAL | FTS_NOSTAT, NULL);

    if (fs == NULL) {
        return Qnil;
    }

    while ((parent = fts_read(fs)) != NULL) {
        child = fts_children(fs, 0);
        while(child != NULL) {
            parent_path = rb_str_new(parent->fts_path, parent->fts_pathlen);
            child_name = rb_str_new(child->fts_name, child->fts_namelen);
            if (child->fts_info == FTS_D && rb_block_given_p() && RTEST(rb_yield_values(2, parent_path, child_name))) {
                fts_set(fs, (RTEST(search_nested_repositories) ? child : parent), FTS_SKIP);
            }
            child = child->fts_link;
        }
    }

    fts_close(fs);
    return Qnil;
}

