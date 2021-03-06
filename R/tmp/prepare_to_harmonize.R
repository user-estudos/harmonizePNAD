#' Builds a synthetic variable for age - 1960
#' @param Data
#' @param type
#' @param year
#' @param state_var_name
#' @value data.frame
#' @export

prepare_to_harmonize <- function(Data,
                                 type,
                                 year,
                                 pnadc_freq = NULL,
                                 quarter = NULL,
                                 state_var_name = NULL){

        attr(Data, which = "readyToHarmonize") <- FALSE

        # Cheking if it is a data.frame
        if(!is.data.frame(Data)){
                stop("'Data' is not a data.frame")
        }

        if(!(type %in% c("pnad", "pnadc", "census"))){
                stop("'type' must be 'pnad', 'pnadc' or 'census'.")
        }

        if(type == "pnad"){
                time_frame = c(1973, 1976:1979, 1981:1990, 1992, 1993, 1995:1999, 2001:2009, 2011:2015)

                if((length(year) != 1) & !(type == year %in% time_frame)){
                        stop(paste("'year' must be one of the following:", paste(time_frame, collapse = ", ")))
                }
        }

        if(type == "pnadc"){
                time_frame = 2012:2018

                if((length(year) != 1) & !(type == year %in% time_frame)){
                        stop(paste("'year' must be one of the following:", paste(time_frame, collapse = ", ")))
                }

                if(is.null(pnadc_freq) | !(pnadc_freq %in% c("annual", "quarterly"))){
                        stop(paste("'pnadc_freq' must be 'annual' or 'quarterly'."))
                }

                if(pnadc_freq == "annual" & !is.null("quarter")){
                        warning("The data was defined as 'annual'. The argument 'quarter' will be ignored")
                }

                if(pnadc_freq == "quarterly" & !(quarter %in% 1:4)){
                        stop("The data was defined as 'quarterly'. The argument 'quarter' must be 1, 2, 3, or 4.")
                }

        }


        if(type == "census"){
                time_frame = c(1960, 1970, 1980, 1991, 2000, 2010)

                if((length(year) != 1) & !(type == year %in% time_frame)){
                        stop(paste("'year' must be one of the following:", paste(time_frame, collapse = ", ")))
                }
        }

        # Converting to data.table
        if(!is.data.table(Data)){
                Data = as.data.table(Data)
        }

        attr(Data, which = "type") <- type
        attr(Data, which = "year") <- year

        if(type == "pnadc"){
                attr(Data, which = "pnadc_freq") <- pnadc_freq

                if(pnadc_freq == "quarterly") {
                        attr(Data, which = "quarter") <- quarter
                }
        }

        # Variable names to lower case
        setnames(x = Data, old = names(Data), new = tolower(names(Data)))
        warning("All variable names were set to lowercase")

        if(type == "census" & year == 1970){

                if(is.null(state_var_name)){
                        stop("\n1970 Census: For the year 1970, you have to specify 'state_var_name'. The original\ndatabase produced by IBGE do not contains an state variable. So each user may have\ncreated a different name for it. This function will rename it to 'uf'.")
                }else{

                        # Converting to data.table
                        if((length(state_var_name) != 1) | !is.character(state_var_name)){
                                stop("\n'state_var_name' must be a single-valued character vector informing the name of the\nvariable representing the Brazilian states in the 1970 Census.")
                        }

                        setnames(Data, old = state_var_name, new = "uf")
                        warning("1970 Census: The variable for states was renamed to 'uf'.")
                }
        }


        attr(Data, which = "readyToHarmonize") <- TRUE

        gc()
        Data
}
