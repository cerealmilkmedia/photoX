# Upstream tracking

PhotoX is based on GIMP.

| Component | Source | Version |
|-----------|--------|---------|
| GIMP      | https://github.com/GNOME/gimp (mirror of https://gitlab.gnome.org/GNOME/gimp) | tag `GIMP_3_2_6`, commit `e101dd19b165f927d3ba0a74658a71537c5661b9` |
| gimp-data | https://github.com/GNOME/gimp-data (mirror of https://gitlab.gnome.org/GNOME/gimp-data) | commit `fe4ecc0bf70fc8ff3bd929ce6abdd50fb5621072` |

`gimp-data` is upstream a git submodule; here it is vendored as a regular
directory. The build prints a harmless warning that it cannot verify the
submodule version.

## Updating to a newer GIMP release

The initial import was a snapshot without GIMP's history, so updates are
applied as a diff between two upstream tags:

```sh
git clone https://github.com/GNOME/gimp.git /tmp/gimp
cd /tmp/gimp
git diff GIMP_3_2_6 GIMP_<new_tag> -- . ':!gimp-data' > /tmp/gimp-update.patch
cd -   # back to PhotoX
git apply -3 /tmp/gimp-update.patch
```

Then refresh `gimp-data/` to the commit pinned by the new tag
(`git ls-tree GIMP_<new_tag> gimp-data` in the GIMP clone) and update the
table above.
