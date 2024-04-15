connection: "recruit_rs_replica"

# include all the views
include: "/views/**/*.view.lkml"

datagroup: support_project_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}

persist_with: support_project_default_datagroup

explore: companies_ats_integrations {}


explore:  supp_dashboard{
  label: "SUPP Dashboard"
}
