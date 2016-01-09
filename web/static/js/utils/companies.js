import values from 'lodash/object/values'

export function buildAutoSuggestItems(companies) {
  return values(companies.items).map(item => {
    return {
      id: item.id,
      text: `${item.ticker} · ${item.name}`
    }
  })
}
