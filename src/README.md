# Technical Guide

## Flags

### Server

- `kdm.settlements`: A map of settlement objects with the key being the settlement's UUID. The format is as follows:
  - `is_capital`: Whether the settlement is the capital of its kingdom or if it's a Free settlement
  - `type`: The settlement's type. Either `kingdom` or `free`
  - `kingdom`: The UUID of the settlement's kingdom. **This key does not exist on Free settlements!**
  - `ruler`: The settlement's ruler; can be `null`
  - `chunks`: A list of all claimed chunks within the settlement
  - `town_charter`: The town charter's location within the settlement
  - `claims`: How many chunk claims the settlement has left; this number is re-calculated every cycle, and decreases when players claim new chunks
- `kdm.kingdoms`: A map of kingdom objects with the key being the kingdom's UUID. The format is as follows:
  - `names`: A list of kingdom names, with the last entry being the most recent
  - `settlements`: A list of owned settlement UUIDs
  - `capital`: The UUID of the kingdom's capital settlement
  - `members`: A list of all players that are a part of the kingdom
  - `positions`: A map of position objects with the key being the position's internal default ID. The format is as follows:
    - `members`: A list of players with this position
    - `name`: The name override for this position

### Player

- `kdm.kingdom`: The UUID of the player's kingdom, if any.

### Misc

- Chunks can have a `kdm.claim` flag holding the UUID of the settlement that claims it.