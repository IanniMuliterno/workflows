# workflows (development version)

* When using a formula preprocessor with `add_formula()`, workflows now uses
  model-specific information from parsnip to decide whether or not to expand
  factors into dummy variables. This should result in more intuitive behavior
  when working with models that don't require dummy variables. For example,
  if a parsnip `rand_forest()` model is used with a ranger engine, dummy
  variables will not be created, because ranger can handle factors directly
  (#51).

# workflows 0.1.1

* hardhat's minimum required version has been bumped to 0.1.2, as it contains
  an important fix to how recipes are prepped by default.

# workflows 0.1.0

* Added a `NEWS.md` file to track changes to the package.
