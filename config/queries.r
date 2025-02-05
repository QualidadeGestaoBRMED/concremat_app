
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
