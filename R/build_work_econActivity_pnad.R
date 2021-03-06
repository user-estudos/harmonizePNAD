
build_work_econActivity_pnad <- function(Data){

        just_created_vars_list_existedBefore <- exists(x = "just_created_vars", where = .GlobalEnv)

        # Loading the crosswalk
        file_location <- system.file("extdata",
                                     "crosswalk_pnad_econActivity.csv",
                                     package = "harmonizePNAD")
        crosswalk   <- data.table::fread(file_location)

        # Selecting the appropriate crosswalk for the current year
        metadata    <- harmonizePNAD:::get_metadata(Data)
        crosswalk_i <- crosswalk[year == metadata$year]

        # Checking the variable availability
        harmonizePNAD:::check_necessary_vars(Data, crosswalk_i$var_econActivity)

        # Recoding
        Data[ , econActivity := as.numeric(NA)]

        expr_active   <- with(crosswalk_i, paste(var_econActivity,"%in% c(",econActivity_active, ")"))
        expr_inactive <- with(crosswalk_i, paste(var_econActivity,"%in% c(",econActivity_inactive, ")"))

        Data[eval(parse(text = expr_active)),    econActivity := 1]
        Data[eval(parse(text = expr_inactive)),  econActivity := 0]

        Data <- harmonizePNAD:::check_and_build_onTheFly(Data,
                                                         var_name = "age",
                                                         general_or_specific = "general")

        Data[age < 10, econActivity := NA]
        if(just_created_vars_list_existedBefore == F){
                Data <- harmonizePNAD:::erase_just_created_vars(Data)
        }

        gc()

        Data


}
