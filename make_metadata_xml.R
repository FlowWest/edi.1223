library(EMLaide)
library(tidyverse)

# Load in all the documents
datatable_metadata <- tibble(filepath = c("data/snorkel_all.csv"),
                             attribute_info = c("data-raw/metadata_snorkel.xlsx"),
                             datatable_description = c("Snorkel Data"))


# TODO Check warnings when reading in excel sheets
excel_path <- "data-raw/metadata_snorkel.xlsx"
sheets <- readxl::excel_sheets(excel_path)
metadata <- lapply(sheets, function(x) readxl::read_excel(excel_path, sheet = x))
names(metadata) <- sheets

abstract_docx <- "data-raw/abstract_final.docx"
methods_docx <- "data-raw/methods.docx"

# edi_number <- reserve_edi_id(user_id = Sys.getenv("EDI_user"), password = Sys.getenv("EDI_password"))

edi_number = "edi.1221.1"

dataset <- list() %>%
  add_pub_date() %>%
  add_title(metadata$title) %>%
  add_personnel(metadata$personnel) %>%
  add_keyword_set(metadata$keyword_set) %>%
  add_abstract(abstract_docx) %>%
  add_license(metadata$license) %>%
  add_method(methods_docx) %>%
  add_maintenance(metadata$maintenance) %>%
  add_project(metadata$funding) %>%
  add_coverage(metadata$coverage, metadata$taxonomic_coverage) %>%
  add_datatable(datatable_metadata)

custom_units <- data.frame(id = c("nephelometric turbidity units", "fish"),
                           unitType = c("dimensionless", "dimensionless"),
                           parentSI = c(NA, NA),
                           multiplierToSI = c(NA, NA),
                           description = c("Turbidity Units", "Number of Fish"))

unitList <- EML::set_unitList(custom_units)
eml <- list(packageId = edi_number,
            system = "EDI",
            access = add_access(),
            dataset = dataset,
            additionalMetadata = list(metadata = list(
              unitList = unitList)))

EML::write_eml(eml, paste0(edi_number, ".xml"))
EML::eml_validate(paste0(edi_number, ".xml"))

