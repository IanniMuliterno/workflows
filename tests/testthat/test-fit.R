test_that("can `fit()` a workflow with a recipe", {
  rec <- recipes::recipe(mpg ~ cyl, mtcars)

  mod <- parsnip::linear_reg()
  mod <- parsnip::set_engine(mod, "lm")

  workflow <- workflow()
  workflow <- add_recipe(workflow, rec)
  workflow <- add_model(workflow, mod)

  result <- fit(workflow, mtcars)

  expect_is(result$fit$fit, "model_fit")

  expect_equal(
    coef(result$fit$fit$fit),
    coef(lm(formula = mpg ~ cyl, data = mtcars))
  )
})

test_that("can `fit()` a workflow with a formula", {
  mod <- parsnip::linear_reg()
  mod <- parsnip::set_engine(mod, "lm")

  workflow <- workflow()
  workflow <- add_formula(workflow, mpg ~ cyl)
  workflow <- add_model(workflow, mod)

  result <- fit(workflow, mtcars)

  expect_is(result$fit$fit, "model_fit")

  expect_equal(
    coef(result$fit$fit$fit),
    coef(lm(formula = mpg ~ cyl, data = mtcars))
  )
})

test_that("missing `data` argument has a nice error", {
  mod <- parsnip::linear_reg()
  mod <- parsnip::set_engine(mod, "lm")

  workflow <- workflow()
  workflow <- add_formula(workflow, mpg ~ cyl)
  workflow <- add_model(workflow, mod)

  expect_error(fit(workflow), "`data` must be provided to fit a workflow")
})

test_that("cannot fit without a pre stage", {
  mod <- parsnip::linear_reg()
  mod <- parsnip::set_engine(mod, "lm")

  workflow <- workflow()
  workflow <- add_model(workflow, mod)

  expect_error(fit(workflow, mtcars), "must have a formula or recipe")
})

test_that("cannot fit without a fit stage", {
  workflow <- workflow()
  workflow <- add_formula(workflow, mpg ~ cyl)

  expect_error(fit(workflow, mtcars), "must have a model")
})

# ------------------------------------------------------------------------------
# .fit_pre()

test_that("`.fit_pre()` updates a formula blueprint according to parsnip's encoding info", {
  mod <- parsnip::rand_forest()
  mod <- parsnip::set_engine(mod, "ranger")
  mod <- parsnip::set_mode(mod, "regression")

  workflow <- workflow()
  workflow <- add_formula(workflow, Sepal.Length ~ .)
  workflow <- add_model(workflow, mod)

  result <- .fit_pre(workflow, iris)

  # ranger sets `indicators = FALSE`, so `Species` is not expanded
  expect_true("Species" %in% names(result$pre$mold$predictors))
  expect_false(result$pre$actions$formula$blueprint$indicators)
})

test_that("`.fit_pre()` ignores parsnip's encoding info with recipes", {
  mod <- parsnip::rand_forest()
  mod <- parsnip::set_engine(mod, "ranger")
  mod <- parsnip::set_mode(mod, "regression")
  rec <- recipes::recipe(Sepal.Length ~ ., iris)

  workflow <- workflow()
  workflow <- add_recipe(workflow, rec)
  workflow <- add_model(workflow, mod)

  result <- .fit_pre(workflow, iris)

  # recipe preprocessing won't auto-expand factors
  expect_true("Species" %in% names(result$pre$mold$predictors))
  expect_false("indicators" %in% names(result$pre$actions$recipe$blueprint))
})

test_that("`.fit_pre()` doesn't modify user supplied formula blueprint", {
  mod <- parsnip::rand_forest()
  mod <- parsnip::set_engine(mod, "ranger")
  mod <- parsnip::set_mode(mod, "regression")

  # request `indicators` to be used, even though parsnip's info on ranger
  # says not to make them.
  blueprint <- hardhat::default_formula_blueprint(indicators = TRUE)

  workflow <- workflow()
  workflow <- add_formula(workflow, Sepal.Length ~ ., blueprint = blueprint)
  workflow <- add_model(workflow, mod)

  result <- .fit_pre(workflow, iris)

  expect_true("Speciessetosa" %in% names(result$pre$mold$predictors))
  expect_identical(result$pre$actions$formula$blueprint, blueprint)
})

test_that("`.fit_pre()` doesn't modify user supplied recipe blueprint", {
  mod <- parsnip::rand_forest()
  mod <- parsnip::set_engine(mod, "ranger")
  mod <- parsnip::set_mode(mod, "regression")
  rec <- recipes::recipe(Sepal.Length ~ ., iris)

  blueprint <- hardhat::default_recipe_blueprint(allow_novel_levels = TRUE)

  workflow <- workflow()
  workflow <- add_recipe(workflow, rec, blueprint = blueprint)
  workflow <- add_model(workflow, mod)

  result <- .fit_pre(workflow, iris)

  expect_true("Species" %in% names(result$pre$mold$predictors))
  expect_identical(result$pre$actions$recipe$blueprint, blueprint)
})

