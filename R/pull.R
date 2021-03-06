#' Extract elements of a workflow
#'
#' @description
#' These functions extract various elements from a workflow object. If they do
#' not exist yet, an error is thrown.
#'
#' - `pull_workflow_preprocessor()` returns either the formula or recipe used
#'   for preprocessing.
#'
#' - `pull_workflow_spec()` returns the parsnip model specification.
#'
#' - `pull_workflow_fit()` returns the parsnip model fit.
#'
#' - `pull_workflow_mold()` returns the preprocessed "mold" object returned
#'   from [hardhat::mold()]. It contains information about the preprocessing,
#'   including either the prepped recipe or the formula terms object.
#'
#' - `pull_workflow_prepped_recipe()` returns the prepped recipe. It is
#'   extracted from the mold object returned from `pull_workflow_mold()`.
#'
#' @param x A workflow
#'
#' @return
#' The extracted value from the workflow, `x`, as described in the description
#' section.
#'
#' @name workflow-extractors
#' @examples
#' library(parsnip)
#' library(recipes)
#'
#' model <- linear_reg()
#' model <- set_engine(model, "lm")
#'
#' recipe <- recipe(mpg ~ cyl + disp, mtcars)
#' recipe <- step_log(recipe, disp)
#'
#' base_workflow <- workflow()
#' base_workflow <- add_model(base_workflow, model)
#'
#' recipe_workflow <- add_recipe(base_workflow, recipe)
#' formula_workflow <- add_formula(base_workflow, mpg ~ cyl + log(disp))
#'
#' fit_recipe_workflow <- fit(recipe_workflow, mtcars)
#' fit_formula_workflow <- fit(formula_workflow, mtcars)
#'
#' # The preprocessor is either a recipe or a formula
#' pull_workflow_preprocessor(recipe_workflow)
#' pull_workflow_preprocessor(formula_workflow)
#'
#' # The `spec` is the parsnip spec before it has been fit.
#' # The `fit` is the fit parsnip model.
#' pull_workflow_spec(fit_formula_workflow)
#' pull_workflow_fit(fit_formula_workflow)
#'
#' # The mold is returned from `hardhat::mold()`, and contains the
#' # predictors, outcomes, and information about the preprocessing
#' # for use on new data at `predict()` time.
#' pull_workflow_mold(fit_recipe_workflow)
#'
#' # A useful shortcut is to extract the prepped recipe from the workflow
#' pull_workflow_prepped_recipe(fit_recipe_workflow)
#'
#' # That is identical to
#' identical(
#'   pull_workflow_mold(fit_recipe_workflow)$blueprint$recipe,
#'   pull_workflow_prepped_recipe(fit_recipe_workflow)
#' )
NULL

#' @rdname workflow-extractors
#' @export
pull_workflow_preprocessor <- function(x) {
  validate_is_workflow(x)

  if (has_preprocessor_formula(x)) {
    return(x$pre$actions$formula$formula)
  }

  if (has_preprocessor_recipe(x)) {
    return(x$pre$actions$recipe$recipe)
  }

  abort("The workflow does not have a preprocessor.")
}

#' @rdname workflow-extractors
#' @export
pull_workflow_spec <- function(x) {
  validate_is_workflow(x)

  if (has_spec(x)) {
    return(x$fit$actions$model$spec)
  }

  abort("The workflow does not have a model spec.")
}

#' @rdname workflow-extractors
#' @export
pull_workflow_fit <- function(x) {
  validate_is_workflow(x)

  if (has_fit(x)) {
    return(x$fit$fit)
  }

  abort("The workflow does not have a model fit. Have you called `fit()` yet?")
}

#' @rdname workflow-extractors
#' @export
pull_workflow_mold <- function(x) {
  validate_is_workflow(x)

  if (has_mold(x)) {
    return(x$pre$mold)
  }

  abort("The workflow does not have a mold. Have you called `fit()` yet?")
}

#' @rdname workflow-extractors
#' @export
pull_workflow_prepped_recipe <- function(x) {
  validate_is_workflow(x)

  if (!has_preprocessor_recipe(x)) {
    abort("The workflow must have a recipe preprocessor.")
  }

  mold <- pull_workflow_mold(x)

  mold$blueprint$recipe
}
