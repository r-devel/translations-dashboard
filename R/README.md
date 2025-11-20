# Scripts

This folder contains scripts for pulling data from Weblate, preprocessing it, and generating the CSV files used by the dashboards.

## Script Descriptions

- **language_statistics.R**  
  Pulls data from Weblate about all supported languages—including identifiers, translation progress metrics, and timestamps of the latest updates—and generates `language_statistics.csv`.

- **recent_changes.R**  
  Reads `language_statistics.csv` and generates `new_translation.csv` and `marked_for_edit.csv`, which record recently translated messages and messages flagged as needing edits.

- **translation_status.R**  
  Pulls the status of each message by language and generates `translation_status.csv`.

- **package_language_statistics.R**  
  Pulls data about translation status by package and language and generates `package_language_statistics.csv`.

- **user_statistics.R**  
  Reads `language_statistics.csv`, processes translator activity to produce contribution statistics, and generates `user_statistics.csv`.


