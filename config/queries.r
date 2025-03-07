
query_get_card <- '
  query ($card_id: ID!) {
    card(id: $card_id) {
      current_phase {
        
        name
      }
      parent_relations {
        name
        cards {
          id
        }
      }
      child_relations {
        name
        cards {
          id
        }
      }
      fields {
        name
        report_value
      }
    }
  }
'


query_update_field <- '
mutation ($card_id: ID!, $field_id : ID! ,$field_value: [UndefinedInput] ) {
  updateCardField(
    input: {card_id: $card_id, 
      field_id : $field_id  , 
      new_value: $field_value}
  ) {
    success
    clientMutationId
  }
}'


get_report_id <- 'mutation {
  exportPipeReport(input: {pipeId: 302370343, pipeReportId: 300834648}) {
    clientMutationId
    pipeReportExport {
      id
    }
  }
}
'

get_report_file <- 'query ($report_id : ID!) {
  pipeReportExport(id : $report_id) {
    id
    state
    startedAt
    finishedAt
    fileURL
  }
}
'



createPresignedUrl <- 'mutation ($file_name: String!) {
  createPresignedUrl(input: {fileName: $file_name, organizationId: 300527823}) {
    url
  }
}
'


query_get_cards_phase <- 'query ( $phase_id : ID! ){
  phase(id: $phase_id ) {
    cards  {
      pageInfo {
        hasNextPage
        endCursor
        startCursor
      }
      edges {
        node {
          id
          title
          fields{
            name
            value
          }
        }
      }
    }
  }
}
'

query_get_cards_phase_other_cards <- 'query ( $phase_id : ID!, $after : String  ){
  phase(id: $phase_id ) {
    cards (after : $after ) {
      pageInfo {
        hasNextPage
        endCursor
        startCursor
      }
      edges {
        node {
          id
          title
          fields{
            name
            value
          }
        }
      }
    }
  }
}'
