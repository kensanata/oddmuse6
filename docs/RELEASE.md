How to make a release
=====================

1. Change the version in `META6.json`
2. Run `make test`
3. Test a local installation using `zef install --force-install .`
4. `git add META6.json`
5. `git commit -m "ready for release"`
6. Tag the commit with the appropriate tag (use `git tag --list` to show existing tags)
7. `make dist`
8. `make upload`
