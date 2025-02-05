

is_concremat_card <- function(res) {
  any(res$data$card$fields$name == "Portal Concremat")
}

is_available_card <- function(res) {
  !is.null(res$data$card)
}

is_correct_phase <- function(res, phase) {
  res$data$card$current_phase$name == phase
}

validate_card <- function(res, expected_phase) {
  if (!is_available_card(res)) {
    return(FALSE)
  }
  
  if (!is_concremat_card(res)) {
    return(FALSE)
  }
  
  if (!is_correct_phase(res, expected_phase)) {
    return(FALSE)
  }
  
  return(TRUE)
}
