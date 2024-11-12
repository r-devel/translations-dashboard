# GitHub Actions

All workflows have `on: workflow_dispatch:` so can be run on demand.

1. `main_dashboard.yml`: Main Dashboard Refresh
    - every day, every 12 hours/on push to main when corresponding yml/index.Rmd file changes
    - render `index.Rmd`
    - commit with message "CSS updated" and push to main
2. `r_svn_changes.yml`: R SVN Changes 
    - every day at 00:00/on push to main when corresponding yml/.R file changes
    - run `translation_status.R` to get recent changes from r-devel/r-svn GitHub mirror
    - commit with message "Added csv in the repository" and push to main
3. `Slack.yaml`: Slack refresh
    - at 19:00 on Friday/on push to main when corresponding yml/.R file changes
    - run `Slack/Weblate_Slack.R` to send updates to #gsoc-translations channel on R Contributors Slack (e.g. new contributors) 
4. `weblate_dashboard.yml`: Weblate Dashboard Refresh
    - every day, every 12 hours/on push to main when corresponding yml/index.Rmd file changes
    - render `weblate/index.Rmd`
    - commit with message "CSS updated" and push to main
5. `weblate_languages.yml`: Language Statistics Refresh
    - every day, at 12:10/on push to main when corresponding yml/.R file changes
    - run `weblate/Language Statisitics/Languages_Statistics.R` to get statistics per language: `Language Statistics_new.csv` from Weblate
6. `weblate_libraries.yml`: Library Statistics Refresh
     - every day, at 12:00/on push to main when corresponding yml/.R file changes
    - run `weblate/Library Language Statistics/Library Language Statistics.R` to get statistics for each component per language: `Library Language Statistics.csv` from Weblate
7. `weblate_recent_changes.yml`: Weblate Recent Changes Refresh
    - every day at 12:20/on push to main when corresponding yml/.R file changes
    - run `weblate/Recent Changes/Recent changes.R` to get recent changes from Weblate
    - commit with message "Updated changes Csv" and push to main
8. `weblate_user_statistics.yml`: User Statistics Refresh
    - every day at 12:30/on push to main when corresponding yml/.R file changes
    - run `weblate/User Statistics/User_statistics.R` to get statistics per user: `Statistics.csv`
    - commit with message "CSS updated" and push to main

(plus pages-build-deployment, currently deploying main branch to GitHub Pages)

## Scheduling

00:00 R SVN Changes
00:10 Main Dashboard Refresh

12:00 Weblate Language Statistics Refresh
12:10 Weblate Library Statistics Refresh
12:20 Weblate Recent Changes Refresh
12:30 Weblate User Statistics Refresh
12:40 Weblate Dashboard Refresh

19:00 on Friday Slack refresh