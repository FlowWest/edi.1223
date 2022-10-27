library(EMLaide)
library(tidyverse)

# Load in tabular data 
datatable_metadata <- tibble(filepath = c("data/snorkel_all.csv"),
                             attribute_info = c("data-raw/metadata_snorkel.xlsx"),
                             datatable_description = c("Snorkel Data"),
                             datatable_url = paste0("https://raw.githubusercontent.com/FlowWest/edi.1223/update_time/data/",
                                                    c("snorkel_all.csv"))
                             )

# Prep Other Entity metadata
other_entity_metadata <- list("file_name" = "2014_2022_HW_snorkel_final.zip",
                              "file_description" = "A zipped folder containing vector shapefiles associated with this dataset",
                              "file_type" = "zipped",
                              "physical" = create_physical("data-raw/2014_2022_HW_snorkel_final.zip"))


# Check warnings when reading in excel sheets
excel_path <- "data-raw/metadata_snorkel.xlsx"
sheets <- readxl::excel_sheets(excel_path)
metadata <- lapply(sheets, function(x) readxl::read_excel(excel_path, sheet = x))
names(metadata) <- sheets

abstract_docx <- "data-raw/abstract_final.docx"
methods_docx <- "data-raw/methods.docx"

# edi_number <- reserve_edi_id(user_id = Sys.getenv("edi_user_id"), password = Sys.getenv("edi_password"))

edi_number = "edi.1223.5"

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
  add_datatable(datatable_metadata) %>% 
  add_other_entity(other_entity_metadata)

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


EMLaide::evaluate_edi_package(Sys.getenv("edi_user_id"), Sys.getenv("password"), 
                              #paste0(edi_number, ".xml"),
                              environment = "staging",
                              eml_file_path = "edi.1223.5.xml" )

EMLaide::update_edi_package(Sys.getenv("edi_user_id"), Sys.getenv("password"), 
                              existing_package_identifier = paste0(edi_number, ".xml"),
                              environment = "staging",
                              eml_file_path = "edi.1223.1.xml")
# EMLaide::upload_edi_package(Sys.getenv("edi_user_id"), Sys.getenv("password"), paste0(edi_number, ".xml"),
#                             environment = "staging")
