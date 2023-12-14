
#-------------------------------------------------------------------------------
# first, download the CRAN version with all dependencies
install.packages("DDIwR", dependencies = TRUE)

# the latest development version
install.packages("DDIwR", repos = "dusadrian.r-universe.dev")


#-------------------------------------------------------------------------------
library(DDIwR)

# ESS is a cross national, multilingual study
# The integrated data file for round 10 has 2283 cases and 428 variables

# this command may take a lot of time, close to 60k lines XML file
convert(
  "~/uRos2023/ESS10.sav",
  to = "DDI",
  monolang = FALSE
)

# It creates the file ESS10.xml, found on GitHub

# Look at the variable edlvpfat, line 29334

# or import the ESS dataset into R:
ess <- convert("~/uRos2023/ESS10.sav")

# value labels, in Austria
labels(ess$edlvpfat)



#-------------------------------------------------------------------------------
# play with a smaller dataset

set.seed(123)
dfm <- data.frame(
  Area = declared(
    sample(1:2, 20, replace = TRUE),
    label = "Residence area",
    labels = c("Rural" = 1, "Urban" = 2)
  ),
  Gender = declared(
    sample(c(1:2, -91), 20, replace = TRUE, prob = c(0.45, 0.45, 0.1)),
    label = "Respondent's gender",
    labels = c("Males" = 1, "Females" = 2, "Non response" = -91),
    na_values = -91
  ),
  Age = declared(
    sample(c(18:49, -92), 20, replace = TRUE),
    label = "Respondent's age",
    labels = c("Prefer not to say" = -92),
    na_values = -92
  ),
  Children = declared(
    sample(c(0:5, -91), 20, replace = TRUE, prob = c(rep(0.15, 6), 0.1)),
    label = "Number of children",
    labels = c("Non response" = -91),
    na_values = -91
  ),
  Opinion = declared(
    sample(c(1:5, -93), 20, replace = TRUE, prob = c(rep(0.18, 5), 0.1)),
    label = "Opinion about this training",
    labels = c(
      "Awful" = 1, "Substandard" = 2, "Mhmm" = 3, "Pass" = 4, "OK" = 5,
      "Too shy to say" = -93
    ),
    na_values = -93
  )
)


convert(dfm, to = "~/uRos2023/dfm.xml")
# Monolingual by default, no xml:lang attribute but in the root

# simulate a multilingual file, like SPSS
dfm$Gender_ro <- declared(
  sample(c(1:2, -91), 20, replace = TRUE, prob = c(0.45, 0.45, 0.1)),
  label = "Respondent's gender",
  labels = c("Bărbat" = 1, "Femeie" = 2, "Non response" = -91),
  na_values = -91
)


convert(dfm, to = "~/uRos2023/dfm.xml", monolang = FALSE)
# xml:lang attribute appears in multiple places, by default "en"


attr(dfm$Gender_ro, "xmlang") <- "ro"

convert(dfm, to = "~/uRos2023/dfm.xml", monolang = FALSE, embed = FALSE)
# xml:lang attribute appears in multiple places, by default "en"

#----
        # For the ESS data
        # set the language for the valid categories
        attr(ess$edlvpfat, "xmlang") <- "de"

        # or for each and every category (including the misisng values)
        attr(ess$edlvpfat, "xmlang") <- c(rep("de", 18), rep("en", 5))
#----


# package xml2
codeBook <- getMetadata("~/uRos2023/dfm.xml")
names(codeBook)

    # with ESS10 this can take a lot of time, we can ignore the data description
    # codeBook <- getMetadata("~/uRos2023/ESS10.xml", ignore = "dataDscr")
    # names(codeBook)

showLineages("abstract")
# codeBook/stdyDscr/stdyInfo/abstract

abstract <- makeElement(
  "abstract",
  content = paste(
    "This dataset is a test one to demonstrate",
    "DDIwR for official statistics..."
  ),
  attributes = c(xmlang = "en", source = "RODA")
)


stdyInfo <- makeElement("stdyInfo")
addChildren(abstract, to = stdyInfo)

stdyDscr <- makeElement("stdyDscr")
addChildren(stdyInfo, to = stdyDscr)

addChildren(stdyDscr, to = codeBook)


## It also works with a single command
# addChildren(
#   makeElement("stdyDscr",
#     children = makeElement("stdyInfo", children = abstract)
#   ),
#   to = codeBook
# )


names(codeBook)

# update the current codebook
updateCodebook("~/uRos2023/dfm.xml", with = codeBook)


# embed the dataset
addChildren(
  makeDataNotes(dfm),
  to = codeBook$fileDscr
)

# and update it again
updateCodebook("~/uRos2023/dfm.xml", with = codeBook)


showLineages("universe")

showDetails("sampleFrame")

showDescription("method")

# sampling
# https://www.europeansocialsurvey.org/methodology/ess-methodology/sampling
# etc.

searchFor("sampling")

searchFor("sampling", where = "examples")

showExamples("weight")

showLineages("weight")

showDetails("weight")
