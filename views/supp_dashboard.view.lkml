
view: supp_dashboard {
  derived_table: {
      sql: -- P3, P4, P5

  -- Mean/90th Percentile Time To Acknowledge, Mean/90th Percentile time to Resolve, Mean/90th Percentile time to Mitigated

  SELECT
  *,
  CASE WHEN POSITION(',' IN created_date) > 0 THEN TO_TIMESTAMP(SPLIT_PART(created_date, ',', 2), 'YYYY-MM-DD HH24:MI')
    WHEN LENGTH(created_date) > 0 THEN TO_TIMESTAMP(created_date, 'DD/MM/YY HH24:MI') ELSE NULL END AS created_timestamp,
    CASE WHEN POSITION(',' IN acknowledged_date) > 0 THEN TO_TIMESTAMP(SPLIT_PART(acknowledged_date, ',', 2), 'YYYY-MM-DD HH24:MI')
    WHEN LENGTH(acknowledged_date) > 0 THEN TO_TIMESTAMP(acknowledged_date, 'DD/MM/YY HH24:MI') ELSE NULL END AS acknowledged_timestamp,
    CASE WHEN POSITION(',' IN mitigated_date) > 0 THEN TO_TIMESTAMP(SPLIT_PART(mitigated_date, ',', 2), 'YYYY-MM-DD HH24:MI')
    WHEN LENGTH(mitigated_date) > 0 THEN TO_TIMESTAMP(mitigated_date, 'DD/MM/YY HH24:MI') ELSE NULL END AS mitigated_timestamp,
    CASE WHEN POSITION(',' IN resolved_date) > 0 THEN TO_TIMESTAMP(SPLIT_PART(resolved_date, ',', 2), 'YYYY-MM-DD HH24:MI')
    WHEN LENGTH(resolved_date) > 0 THEN TO_TIMESTAMP(resolved_date, 'DD/MM/YY HH24:MI') ELSE NULL END AS resolved_timestamp,
  LEFT(severity_of_issue,2) AS priority_shortened,
  CASE WHEN EXTRACT(DOW FROM created_timestamp) = 6 THEN dateadd(day,2,date(created_timestamp))::timestamp
  WHEN EXTRACT(DOW FROM created_timestamp) = 0 THEN dateadd(day,1,date(created_timestamp))::timestamp
  ELSE created_timestamp END AS created_shifted,
  CASE WHEN EXTRACT(DOW FROM acknowledged_timestamp) = 6 THEN dateadd(day,2,date(acknowledged_timestamp))::timestamp
  WHEN EXTRACT(DOW FROM acknowledged_timestamp) = 0 THEN dateadd(day,1,date(acknowledged_timestamp))::timestamp
  ELSE acknowledged_timestamp END AS acknowledged_shifted,
  CASE WHEN EXTRACT(DOW FROM acknowledged_timestamp) IN (0,6) AND EXTRACT(DOW FROM created_timestamp) IN (0,6) and
  (datediff('day',created_timestamp::timestamp,acknowledged_timestamp::timestamp)::integer) < 2
  THEN datediff('minutes',created_timestamp::timestamp,acknowledged_timestamp::timestamp)::integer
  ELSE
    datediff('minutes',created_shifted::timestamp,acknowledged_shifted::timestamp)::integer
  - (datediff('week',created_shifted::timestamp,acknowledged_shifted::timestamp)::integer)*2*24*60
  END AS business_minutes_diff_acknowledge,
  CASE
  WHEN EXTRACT(DOW FROM mitigated_timestamp) = 6 THEN dateadd(day, 2, date(mitigated_timestamp))::timestamp
  WHEN EXTRACT(DOW FROM mitigated_timestamp) = 0 THEN dateadd(day, 1, date(mitigated_timestamp))::timestamp
  ELSE mitigated_timestamp
END AS mitigated_shifted,

CASE
  WHEN EXTRACT(DOW FROM mitigated_timestamp) IN (0, 6) AND EXTRACT(DOW FROM created_timestamp) IN (0, 6) AND (datediff('day', created_timestamp::timestamp, mitigated_timestamp::timestamp)::integer) < 2
  THEN datediff('minutes', created_timestamp::timestamp, mitigated_timestamp::timestamp)::integer
  ELSE datediff('minutes', created_shifted::timestamp, mitigated_shifted::timestamp)::integer - (datediff('week', created_shifted::timestamp, mitigated_shifted::timestamp)::integer) * 2 * 24 * 60
END AS business_minutes_diff_mitigate,
CASE
  WHEN EXTRACT(DOW FROM resolved_timestamp) = 6 THEN dateadd(day, 2, date(resolved_timestamp))::timestamp
  WHEN EXTRACT(DOW FROM resolved_timestamp) = 0 THEN dateadd(day, 1, date(resolved_timestamp))::timestamp
  ELSE resolved_timestamp
END AS resolved_shifted,

CASE
  WHEN EXTRACT(DOW FROM resolved_timestamp) IN (0, 6) AND EXTRACT(DOW FROM created_timestamp) IN (0, 6) AND (datediff('day', created_timestamp::timestamp, resolved_timestamp::timestamp)::integer) < 2
  THEN datediff('minutes', created_timestamp::timestamp, resolved_timestamp::timestamp)::integer
  ELSE datediff('minutes', created_shifted::timestamp, resolved_shifted::timestamp)::integer - (datediff('week', created_shifted::timestamp, resolved_shifted::timestamp)::integer) * 2 * 24 * 60
END AS business_minutes_diff_resolve


  FROM analytics.temp.jira_support_data;;
    }

    measure: count {
      type: count
      drill_fields: [detail*]
    }


  dimension: key {
    type: string
    sql: ${TABLE}.key ;;
  }

    dimension: business_minutes_diff_acknowledge {
      type: number
      sql: ${TABLE}.business_minutes_diff_acknowledge ;;
    }

  dimension: business_minutes_diff_mitigate {
    type: number
    sql: ${TABLE}.business_minutes_diff_mitigate ;;
  }

  dimension: business_minutes_diff_resolve {
    type: number
    sql: ${TABLE}.business_minutes_diff_resolve ;;
  }

    dimension: issue_type {
      type: string
      sql: ${TABLE}.issue_type ;;
    }

    dimension: summary {
      type: string
      sql: ${TABLE}.summary ;;
    }

    dimension: severity_of_issue {
      type: string
      sql: ${TABLE}.severity_of_issue ;;
    }

    dimension: impacted_area {
      type: string
      sql: ${TABLE}.impacted_area ;;
    }

    dimension: sub_impact_area {
      type: string
      sql: ${TABLE}.sub_impact_area ;;
    }

    dimension: status {
      type: string
      sql: ${TABLE}.status ;;
    }

    dimension: created_date {
      type: string
      sql: ${TABLE}.created_date ;;
    }

    dimension: acknowledged_date {
      type: string
      sql: ${TABLE}.acknowledged_date ;;
    }

    dimension: mitigated_date {
      type: string
      sql: ${TABLE}.mitigated_date ;;
    }

    dimension: reopened_date {
      type: string
      sql: ${TABLE}.reopened_date ;;
    }

    dimension: resolved_date {
      type: string
      sql: ${TABLE}.resolved_date ;;
    }

    dimension_group: ingest_date {
      type: time
      sql: ${TABLE}.ingest_date ;;
    }

    dimension_group: created_timestamp {
      type: time
      sql: ${TABLE}.created_timestamp ;;
    }

    dimension_group: acknowledged_timestamp {
      type: time
      sql: ${TABLE}.acknowledged_timestamp ;;
    }

    dimension_group: mitigated_timestamp {
      type: time
      sql: ${TABLE}.mitigated_timestamp ;;
    }

    dimension_group: resolved_timestamp {
      type: time
      sql: ${TABLE}.resolved_timestamp ;;
    }


  dimension: minutes_to_acknowledgement {
    type: number
    sql: CASE WHEN ${acknowledged_date} = '' THEN NULL ELSE
    DATE_DIFF('minute',${TABLE}.created_timestamp::timestamp,${TABLE}.acknowledged_timestamp::timestamp) END  ;;
  }

  dimension: minutes_to_mitigation {
    type: number
    sql:  CASE WHEN ${mitigated_date} = '' THEN NULL ELSE
    DATE_DIFF('minute',${TABLE}.created_timestamp::timestamp,${TABLE}.mitigated_timestamp::timestamp) END  ;;
  }

  dimension: minutes_to_resolution {
    type: number
    sql:  CASE WHEN ${resolved_date} = '' THEN NULL ELSE
      DATE_DIFF('minute',${TABLE}.created_timestamp::timestamp,${TABLE}.resolved_timestamp::timestamp) END  ;;
  }




    dimension: priority_shortened {
      type: string
      sql: ${TABLE}.priority_shortened ;;
    }

  parameter: perc_choice {
    type: unquoted
    description: "Select Average/90th Percentile."
    default_value: "average"
    allowed_value: {
      label: "Average"
      value: "average"
    }
    allowed_value: {
      label: "90th Percentile"
      value: "percentile"
    }
  }

  measure: average_minutes_to_acknowledgement {
    type: average
    label: "Average Time To Acknowledgement"
    sql:
    {% if drill_filter._parameter_value == 'minute' %}
        ${business_minutes_diff_acknowledge}
        {% elsif drill_filter._parameter_value == 'hour' %}
        ${business_minutes_diff_acknowledge}*1.0/60
        {% elsif drill_filter._parameter_value == 'day' %}
        ${business_minutes_diff_acknowledge}*1.0/(60*24)
        {% elsif drill_filter._parameter_value == 'week' %}
        ${business_minutes_diff_acknowledge}*1.0/(60*24*7)
        {% endif %};;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: percentile_minutes_to_acknowledgement {
    type: percentile
    label: "Percentile Time To Acknowledgement"
    percentile: 90
    sql:
    {% if drill_filter._parameter_value == 'minute' %}
    ${business_minutes_diff_acknowledge}
    {% elsif drill_filter._parameter_value == 'hour' %}
    ${business_minutes_diff_acknowledge}*1.0/60
    {% elsif drill_filter._parameter_value == 'day' %}
    ${business_minutes_diff_acknowledge}*1.0/(60*24)
    {% elsif drill_filter._parameter_value == 'week' %}
    ${business_minutes_diff_acknowledge}*1.0/(60*24*7)
    {% endif %};;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: average_or_percentile_acknowledgement {
    type: number
    # label_from_parameter: perc_choice
    sql:
        {% if perc_choice._parameter_value == 'average' %}
        ${average_minutes_to_acknowledgement}
        {% elsif perc_choice._parameter_value == 'percentile' %}
        ${percentile_minutes_to_acknowledgement}
        {% endif %};;

  }

  measure: average_minutes_to_mitigation {
    type: average
    label: "Average Time To Mitigation"
    sql:{% if drill_filter._parameter_value == 'minute' %}
         ${business_minutes_diff_mitigate}
        {% elsif drill_filter._parameter_value == 'hour' %}
        ${business_minutes_diff_mitigate} *1.0/60
        {% elsif drill_filter._parameter_value == 'day' %}
        ${business_minutes_diff_mitigate} *1.0/(60*24)
        {% elsif drill_filter._parameter_value == 'week' %}
        ${business_minutes_diff_mitigate} *1.0/(60*24*7)
        {% endif %};;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: percentile_minutes_to_mitigation {
    type: percentile
    percentile: 90
    label: "Percentile Time To Mitigation"
    sql:{% if drill_filter._parameter_value == 'minute' %}
    ${business_minutes_diff_mitigate}
    {% elsif drill_filter._parameter_value == 'hour' %}
    ${business_minutes_diff_mitigate} *1.0/60
    {% elsif drill_filter._parameter_value == 'day' %}
    ${business_minutes_diff_mitigate} *1.0/(60*24)
    {% elsif drill_filter._parameter_value == 'week' %}
    ${business_minutes_diff_mitigate} *1.0/(60*24*7)
    {% endif %};;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: average_or_percentile_mitigation {
    type: number
    # label_from_parameter: perc_choice
    sql:
        {% if perc_choice._parameter_value == 'average' %}
        ${average_minutes_to_mitigation}
        {% elsif perc_choice._parameter_value == 'percentile' %}
        ${percentile_minutes_to_mitigation}
        {% endif %};;

    }

  measure: average_minutes_to_resolution {
    type: average
    label: "Average Time To Resolution"
    sql:{% if drill_filter._parameter_value == 'minute' %}
    ${business_minutes_diff_resolve}
    {% elsif drill_filter._parameter_value == 'hour' %}
    ${business_minutes_diff_resolve} *1.0/60
    {% elsif drill_filter._parameter_value == 'day' %}
    ${business_minutes_diff_resolve} *1.0/(60*24)
    {% elsif drill_filter._parameter_value == 'week' %}
    ${business_minutes_diff_resolve} *1.0/(60*24*7)
    {% endif %};;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: percentile_minutes_to_resolution {
    type: percentile
    percentile: 90
    label: "Percentile Time To Resolution"
    sql:{% if drill_filter._parameter_value == 'minute' %}
    ${business_minutes_diff_resolve}
    {% elsif drill_filter._parameter_value == 'hour' %}
    ${business_minutes_diff_resolve} *1.0/60
    {% elsif drill_filter._parameter_value == 'day' %}
    ${business_minutes_diff_resolve} *1.0/(60*24)
    {% elsif drill_filter._parameter_value == 'week' %}
    ${business_minutes_diff_resolve} *1.0/(60*24*7)
    {% endif %};;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: average_or_percentile_resolution {
    type: number
    # label_from_parameter: perc_choice
    sql:
        {% if perc_choice._parameter_value == 'average' %}
        ${average_minutes_to_resolution}
        {% elsif perc_choice._parameter_value == 'percentile' %}
        ${percentile_minutes_to_resolution}
        {% endif %};;

    }

  parameter: date_granularity {
    type: unquoted
    description: "Select the appropiate level of granularity for dashboard."
    default_value: "date"
    allowed_value: {
      label: "Ticket Created by Date"
      value: "date"
    }
    allowed_value: {
      label: "Ticket Created by Week"
      value: "week"
    }
    allowed_value: {
      label: "Ticket Created by Month"
      value: "month"
    }
    allowed_value: {
      label: "Ticket Created by Quarter"
      value: "quarter"
    }
    # allowed_value: {
    #   label: "Ticket Created by Year"
    #   value: "year"
    # }
  }

  parameter: drill_filter {
    type: unquoted
    description: "Select the appropiate level of Time."
    default_value: "minutes"
    allowed_value: {
      label: "Minute"
      value: "minute"
    }
    allowed_value: {
      label: "Hour"
      value: "hour"
    }
    allowed_value: {
      label: "Day"
      value: "day"
    }
    allowed_value: {
      label: "Week"
      value: "week"
    }
  }

  dimension: period_type {
    label_from_parameter: date_granularity
    sql:
        {% if date_granularity._parameter_value == 'date' %}
        ${created_timestamp_date}
        {% elsif date_granularity._parameter_value == 'week' %}
        ${created_timestamp_week}
        {% elsif date_granularity._parameter_value == 'month' %}
        ${created_timestamp_month}
        {% elsif date_granularity._parameter_value == 'quarter' %}
        ${created_timestamp_quarter}
        {% elsif date_granularity._parameter_value == 'year' %}
        ${created_timestamp_year}
        {% endif %};;
  }

    set: detail {
      fields: [
        key,
        issue_type,
        summary,
        severity_of_issue,
        impacted_area,
        sub_impact_area,
        status,
        created_date,
        acknowledged_date,
        mitigated_date,
        reopened_date,
        resolved_date,
        ingest_date_time,
        created_timestamp_time,
        acknowledged_timestamp_time,
        mitigated_timestamp_time,
        resolved_timestamp_time,
        priority_shortened
      ]
    }
  }
