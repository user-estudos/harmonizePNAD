
build_income_earningsAllJobs_pnad <- function(Data){

        just_created_vars_list_existedBefore <- exists(x = "just_created_vars", where = .GlobalEnv)

        metadata = harmonizePNAD:::get_metadata(Data)

        # Loading the crosswalk
        file_location <- system.file("extdata",
                                     "crosswalk_pnad_earningsAllJobs.csv",
                                     package = "harmonizePNAD")
        crosswalk <- data.table::fread(file_location, colClasses = "numeric", dec =",")
        crosswalk <- crosswalk[year == metadata$year]

        Data <- harmonizePNAD:::check_and_build_onTheFly(Data,
                                                         var_name = "occupationalStatus",
                                                         general_or_specific = "general")

        Data <- harmonizePNAD:::check_and_build_onTheFly(Data,
                                                         var_name = "econActivity",
                                                         general_or_specific = "general")

        if(metadata$year == 1978){

                earnings_vars <- str_split(crosswalk$var_earningsAllJobs,pattern = ";") %>% unlist()
                harmonizePNAD:::check_necessary_vars(Data = Data, var_names = earnings_vars)

                earnings_matrix <- as.matrix(Data[ , earnings_vars, with = F])

                all_na <- apply(earnings_matrix, 1, function(x) sum(is.na(x)) == ncol(earnings_matrix))

                zero_incomes <- Data[, all_na == T & occupationalStatus == 1]
                zero_incomes[is.na(zero_incomes)] <- FALSE

                location_missings <- NULL
                for(j in 1:ncol(earnings_matrix)){
                        location_missings_j <- which(earnings_matrix[,j] >= crosswalk$missing_values)
                        if(length(location_missings_j) > 0){
                                location_missings <- rbind(location_missings,
                                                           cbind(location_missings_j,j)
                                                           )
                        }
                }

                earnings_matrix[location_missings] <- NA

                Data$earningsAllJobs <- rowSums(earnings_matrix, na.rm = T)
                Data[earningsAllJobs == 0, earningsAllJobs := NA]
                Data[ zero_incomes, earningsAllJobs := 0]

        }else{

                Data$earningsAllJobs = Data[[crosswalk$var_earningsAllJobs]]
        }


        if(metadata$year %in% c(1976,1977,1979:1990)){
                Data[occupationalStatus == 1 & is.na(earningsAllJobs), earningsAllJobs := 0]
        }

        Data[is.na(occupationalStatus) | occupationalStatus == 0, earningsAllJobs := NA]
        Data[is.na(econActivity)       | econActivity == 0      , earningsAllJobs := NA]

        if(just_created_vars_list_existedBefore == F){
                Data <- harmonizePNAD:::erase_just_created_vars(Data)
        }

        Data[earningsAllJobs >= crosswalk$missing_values, earningsAllJobs := NA]

        gc()
        Data
}

