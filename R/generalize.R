generalize <- function(y, x, Z, D, expr = TRUE, simp = FALSE, steps = FALSE, primes = FALSE, stop_on_nonid = TRUE) {
  d <- length(D)
  z <- length(Z)
  v <- get.vertex.attribute(D[[1]], "name")
  s <- v[which(vertex.attributes(D[[1]])$description == "S")]
  if (length(s) > 0) stop("The causal diagram cannot contain selection variables.")
  if (d != z) stop("Number of available experiments does not match number of domains.")
  if (length(intersect(x, y)) > 0) stop("Sets 'x' and 'y' are not disjoint.")
  topo <- lapply(D, function(k) topological.sort(observed.graph(k)))
  topo <- lapply(1:d, function(k) get.vertex.attribute(D[[k]], "name")[topo[[k]]])
  D <- lapply(D, function(k) {
    if (length(edge.attributes(k)) == 0) {
      k <- set.edge.attribute(k, "description", 1:length(E(k)), NA)
    }
    return(k)
  })
  for (i in 1:d) {
    if (!is.dag(observed.graph(D[[i]]))) {
      if (i > 1) stop("Selection diagram 'D[", i, "]' is not a DAG.")
      else stop("Causal diagram 'D[", i, "]' is not a DAG.")
    }
    if (length(setdiff(y, topo[[i]])) > 0) stop("Set 'y' contains variables not present in diagram 'D[", i, "]'.")
    if (length(setdiff(x, topo[[i]])) > 0) stop("Set 'x' contains variables not present in diagram 'D[", i, "]'.")
    if (length(setdiff(Z[[i]], topo[[i]])) > 0) stop("Set 'Z[", i, "]' contains variables not present in diagram 'D[", i, "]'.")
  }
  res <- trmz(y, x, probability(domain = 1), c(), 1, 1, D, Z, topo, list())
  if (res$tree$call$id) {
    res.prob <- res$P
    attr(res.prob, "algorithm") <- "trmz"
    attr(res.prob, "query") <- list(y = y, x = x)
    attr(res.prob, "sources") <- d - 1
    if (expr) res.prob <- get.expression(res.prob, primes)
    if (steps) return(list(P = res.prob, steps = res$tree, id = TRUE))
    return(res.prob)
  } else {
    if (stop_on_nonid) stop("Not transportable.", call. = FALSE)
    res.prob <- probability()
    attr(res.prob, "algorithm") <- "trmz"
    attr(res.prob, "query") <- list(y = y, x = x)
    attr(res.prob, "sources") <- d - 1
    if (steps) return(list(P = res.prob, steps = res$tree, id = FALSE))
    if (expr) return("")
    return(NULL)
  }
}
