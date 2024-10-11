# GitHub Actions

All workflows have `on: workflow_dispatch:` so can be run on demand.

1. `changes.yml`: Recent Changes refresh
    - every day at 12:20/on push to main when corresponding yml/.R file changes
    - run `weblate/Recent Changes/Recent changes.R` to get recent changes from Weblate
    - commit with message "Updated changes Csv" and push to main
2. `csv.yml`: Creation of CSV 
    - every day at 00:00/on push to main when corresponding yml/.R file changes
    - run `translation_status.R` to get recent changes from r-devel/r-svn GitHub mirror
    - commit with message "Added csv in the repository" and push to main
3. `Dashboard.yml`: Weblate Dashboard Refresh
    - every day, every 12 hours/on push to main when corresponding yml/index.Rmd file changes
    - render `weblate/index.Rmd`
    - commit with message "CSS updated" and push to main
4. `languages.yml`: Languages Statistics Refresh
    - every day, at 12:10/on push to main when corresponding yml/.R file changes
    - run `weblate/Language Statisitics/Languages_Statistics.R` to get statistics per language: `Language Statistics_new.csv` from Weblate
5. `library.yml`: Library Statistics Refresh
     - every day, at 12:00/on push to main when corresponding yml/.R file changes
    - run `weblate/Library Language Statistics/Library Language Statistics.R` to get statistics per language: `Language Statistics_new.csv` from Weblate
5. `main.yml`: Main Dashboard Refresh
    - every day, every 12 hours/on push to main when corresponding yml/index.Rmd file changes
    - render `index.Rmd`
    - commit with message "CSS updated" and push to main
6. `Slack.yaml`: Slack refresh
    - at 19:00 on Friday/on push to main when corresponding yml/.R file changes
    - run `Slack/Weblate_Slack.R` to send updates to #gsoc-translations channel on R Contributors Slack (e.g. new contributors) 
7. `User Statistics.yml`: User refresh
    - every day at 12:30/on push to main when corresponding yml/.R file changes
    - run `weblate/User Statistics/User_statistics.R` to get statistics per user: `Statistics.csv`
    - commit with message "CSS updated" and push to main

(plus pages-build-deployment, currently deploying main branch to GitHub Pages)