#' Compute a basis with 4ti2
#'
#' 4ti2 provides several executables that can be used to generate
#' bases for a configuration matrix A.  See the references for
#' details.
#'
#' @param A a matrix
#' @param format how the basis (moves) should be returned.  if
#'   "mat", the moves are returned as the columns of a matrix.
#' @param dim the dimension to be passed to \code{\link{vec2tab}} if
#'   format = "tab" is used; a vector of the number of levels of
#'   each variable in order
#' @param all if TRUE, all moves (+ and -) are given.  if FALSE,
#'   only the + moves are given as returned by the executable.
#' @param dir directory to place the files in, without an ending /
#' @param opts options for basis ("-parb" for markov, zbasis, and
#'   groebner; "" for graver)
#' @param quiet if FALSE, messages the 4ti2 output
#' @param dbName the name of the model in the markov bases database,
#'   http://markov-bases.de, see examples
#' @param ... ...
#' @param exec (temporary, don't use)
#' @return a matrix containing the Markov basis as its columns (for
#'   easy addition to tables)
#' @rdname fourTiTwo
#' @references Drton, M., B. Sturmfels, and S. Sullivant (2009).
#'   \emph{Lectures on Algebraic Statistics}, Basel: Birkhauser
#'   Verlag AG.
#' @examples
#'
#' \dontrun{ these examples require having 4ti2 installed
#'
#'
#'
#'
#' # basic input and output for the 2x2 independence example
#' (A <- rbind(
#'   kprod(diag(3), ones_r(3)),
#'   kprod(ones_r(3), diag(3))
#' ))
#' markov(A)
#' markov(A, "vec")
#' markov(A, "tab", c(3, 3))
#' markov(A, "tab", c(3, 3), all = TRUE)
#' tableau(markov(A), dim = c(3, 3)) # tableau notation
#'
#'
#'
#'
#' # a slighly larger example, 2x3 independence)
#' # (source: LAS ex 1.2.1, p.12)
#' (A <- rbind(
#'   kprod(diag(2), ones_r(3)),
#'   kprod(ones_r(2), diag(3))
#' ))
#'
#' markov(A, "tab", c(3, 3))
#' # Prop 1.2.2 says that there should be
#' 2*choose(2, 2)*choose(3,2) # = 6
#' # moves (up to +-1)
#' markov(A, "tab", c(3, 3), TRUE)
#'
#'
#'
#'
#' # comparing the bases for the 3x3x3 no-three-way interaction model
#' A <- rbind(
#'   kprod(  diag(3),   diag(3), ones_r(3)),
#'   kprod(  diag(3), ones_r(3),   diag(3)),
#'   kprod(ones_r(3),   diag(3),   diag(3))
#' )
#' str(zbasis(A))   #    8 elements = ncol(A) - qr(A)$rank
#' str(markov(A))   #   81 elements
#' str(groebner(A)) #  110 elements
#' str(graver(A))   #  795 elements
#'
#'
#'
#' # you can memoise the result; this will cache the result for
#' # future use.  (note that it doesn't persist across sessions.)
#' A <- rbind(
#'   kprod(  diag(4), ones_r(4), ones_r(4)),
#'   kprod(ones_r(4),   diag(4), ones_r(4)),
#'   kprod(ones_r(4), ones_r(4),   diag(4))
#' )
#' system.time(markov(A))
#' system.time(markov(A))
#' system.time(mem_markov(A))
#' system.time(mem_markov(A))
#'
#' A <- rbind(
#'   kprod(  diag(3), ones_r(3), ones_r(2)),
#'   kprod(ones_r(3),   diag(3), ones_r(2)),
#'   kprod(ones_r(3), ones_r(3),   diag(2))
#' )
#' system.time(graver(A))
#' system.time(mem_graver(A))
#' system.time(mem_graver(A))
#'
#'
#'
#'
#'
#'
#'
#'
#'
#' # LAS example 1.2.12, p.17  (no 3-way interaction)
#' (A <- rbind(
#'   kprod(  diag(2),   diag(2), ones_r(2)),
#'   kprod(  diag(2), ones_r(2),   diag(2)),
#'   kprod(ones_r(2),   diag(2),   diag(2))
#' ))
#' markov(A)
#' tableau(markov(A), dim = c(2,2,2))
#'
#'
#'
#' # LAS example 1.2.12, p.16  (no 3-way interaction)
#' A <- rbind(
#'   kprod(  diag(2),   diag(2),  ones_r(2), ones_r(2)),
#'   kprod(  diag(2), ones_r(2),  ones_r(2),   diag(2)),
#'   kprod(ones_r(2),   diag(2),    diag(2), ones_r(2))
#' )
#' plot_matrix(A)
#' zbasis(A)
#' markov(A)
#' groebner(A)
#' graver(A)
#'
#'
#'
#'
#'
#'
#'
#'
#'
#' # using the markov bases database, must be connected to internet
#' # A <- markov(dbName = "ind3-3")
#' B <- markov(rbind(
#'   kprod(diag(3), ones_r(3)),
#'   kprod(ones_r(3), diag(3))
#' ))
#' # all(A == B)
#'
#'
#'
#'
#'
#'
#'
#'
#'
#'
#'
#'
#' markov(diag(1, 10))
#' zbasis(diag(1, 10), "vec")
#' groebner(diag(1, 10), "vec", all = TRUE)
#' graver(diag(1, 10), "vec", all = TRUE)
#' graver(diag(1, 4), "tab", all = TRUE, dim = c(2,2))
#'
#' }
#'
#'








basis <- function(exec){

  ## stuff in basis
  extension <- switch(exec,
    markov = ".mar",
    groebner = ".gro",
    hilbert = ".hil",
    graver = ".gra",
    zbasis = ".lat",
    zsolve = ".zfree"
  )

  commonName = switch(exec,
    markov = "markov",
    groebner = "grobner",
    hilbert = "hilbert",
    graver = "graver",
    zbasis = "lattice",
    zsolve = "solve"
  )

  defaultOpts = switch(exec,
    markov = "-parb",
    groebner = "-parb",
    hilbert = "-p=gmp",
    graver = "-p=gmp",
    zbasis = "-parb",
    zsolve = "-p=gmp"
  )


  ## create the function to return
  function(A, format = c("mat", "vec", "tab"), dim = NULL,
    all = FALSE, dir = tempdir(), opts = defaultOpts, quiet = TRUE,
    dbName
  ){

    ## check for 4ti2
    program_not_found_stop("4ti2_path")


    ## check args
    format <- match.arg(format)
    if(format == "tab" && missing(dim)){
      stop('if format = "tab" is specified, dim must be also.', call. = FALSE)
    }


    ## make dir to put 4ti2 files in (within the tempdir) timestamped
    dir2 <- file.path2(dir, timeStamp())
    suppressWarnings(dir.create(dir2))


    ## make 4ti2 file
    if(!missing(A)) write.latte(A, file.path2(dir2, "PROJECT.mat"))


    ## switch to temporary directory
    oldWd <- getwd()
    setwd(dir2)
    on.exit(setwd(oldWd), add = TRUE)


    ## create/retrieve markov basis
    if(missing(dbName)){

      ## run 4ti2 if needed
      if(is.mac() || is.unix()){

        system2(
          file.path2(getOption("4ti2_path"), exec),
          paste(opts, file.path2(dir2, "PROJECT")),
          stdout = paste0(exec, "Out"), stderr = FALSE
        )

      } else if(is.win()){

        matFile <- file.path2(dir2, "PROJECT")
        matFile <- chartr("\\", "/", matFile)
        matFile <- str_c("/cygdrive/c", str_sub(matFile, 3))

        system2(
          "cmd.exe",
          paste(
            "/c env.exe",
            file.path(getOption("4ti2_path"), exec),
            opts, matFile
          ), stdout = paste0(exec, "Out"), stderr = FALSE
        )

      }


      if(!quiet) cat(readLines(paste0(exec, "Out")), sep = "\n")

    } else { # if the model name is specified

      download.file(
        paste0("http://markov-bases.de/data/", dbName, "/", dbName, extension),
        destfile = "PROJECT.mar" # already in tempdir
      )

    }

    ## fix case of no graver basis
    if(exec == "graver"){
      if(paste0("PROJECT", extension) %notin% list.files(dir2)){
        warning(sprintf("%s basis empty, returning 0's.", capitalize(commonName)), call. = FALSE)
        return(fix_graver(A, format, dim))
      }
    }


    ## figure out what files to keep them, and make 4ti2 object
    basis <- t(read.latte(paste0("PROJECT", extension)))


    ## fix case of no basis
    basisDim <- dim(basis)
    noBasisFlag <- FALSE
    if(any(basisDim == 0)){
      noBasisFlag <- TRUE
      warning(sprintf("%s basis empty, returning 0's.", capitalize(commonName)), call. = FALSE)
      basisDim[basisDim == 0] <- 1L
      basis <- rep(0L, prod(basisDim))
      dim(basis) <- basisDim
    }


    ## format
    if(all && !noBasisFlag) basis <- cbind(basis, -basis)


    # out
    if(format == "mat"){
      return(basis)
    } else {
      lbasis <- as.list(rep(NA, ncol(basis)))
      for(k in 1:ncol(basis)) lbasis[[k]] <- basis[,k]
      if(format == "vec") return(lbasis)
      if(format == "tab") return(lapply(lbasis, vec2tab, dim = dim))
    }
  }
}





#' @export
#' @rdname fourTiTwo
zsolve <- basis("zsolve")

#' @export
#' @rdname fourTiTwo
zbasis <- basis("zbasis")

#' @export
#' @rdname fourTiTwo
markov <- basis("markov")

#' @export
#' @rdname fourTiTwo
groebner <- basis("groebner")

#' @export
#' @rdname fourTiTwo
hilbert <- basis("hilbert")

#' @export
#' @rdname fourTiTwo
graver <- basis("graver")






#' @export
#' @rdname fourTiTwo
mem_zsolve <- memoise::memoise(mem_zsolve)

#' @export
#' @rdname fourTiTwo
memZbasis <- memoise::memoise(zbasis)

#' @export
#' @rdname fourTiTwo
mem_markov <- memoise::memoise(markov)

#' @export
#' @rdname fourTiTwo
mem_groebner <- memoise::memoise(groebner)

#' @export
#' @rdname fourTiTwo
mem_hilbert <- memoise::memoise(hilbert)

#' @export
#' @rdname fourTiTwo
mem_graver <- memoise::memoise(graver)




fix_graver <- function(A, format, dim){
  if(format == "mat"){
    return(matrix(0L, nrow = ncol(A)))
  } else {
    lbasis <- list(rep(0L, ncol(A)))
    if(format == "vec") return(lbasis)
    if(format == "tab") return(lapply(lbasis, vec2tab, dim = dim))
  }
}