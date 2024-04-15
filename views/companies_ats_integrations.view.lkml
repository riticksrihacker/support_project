view: companies_ats_integrations {
  sql_table_name: public.companies_ats_integrations ;;

  dimension: company_id {
    type: number
    sql: ${TABLE}.company_id ;;
  }
  dimension: company_name {
    type: string
    sql: ${TABLE}.company_name ;;
  }
  dimension: integration {
    type: string
    sql: ${TABLE}.integration ;;
  }
  dimension_group: last_used {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.last_used_at ;;
  }
  dimension: stripe_plan {
    type: string
    sql: ${TABLE}.stripe_plan ;;
  }
  dimension: type {
    type: string
    sql: ${TABLE}.type ;;
  }
  measure: count {
    type: count
    drill_fields: [company_name]
  }
}
