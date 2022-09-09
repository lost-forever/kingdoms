deed:
  type: item
  material: globe_banner_pattern
  display name: <&[item]>Deed
  mechanisms:
    hides: ITEM_DATA
  lore:
  - <&[lore]>Use on a chunk to <&[emphasis]>expand <&[lore]>a settlement!
  recipes:
    1:
      type: shapeless
      input: paper|paper|paper|feather

kdm_adjacent_settlement_chunk:
  type: procedure
  definitions: chunk
  script:
  - define list <list>
  - foreach -1|1 as:x:
    - foreach -1|1 as:z:
      - define new_chunk <[chunk].add[<[x]>,<[z]>]>
      - if <[new_chunk].has_flag[kdm.claim]>:
        - define list:->:<[new_chunk]>
  - determine <[list]>

kdm_deed_fn:
  type: world
  events:
    on player right clicks block in:chunk_flagged:!kdm.claim with:deed:
    - determine passively cancelled
    - define chunks <player.location.chunk.proc[kdm_adjacent_settlement_chunk]>
    # Stop if no chunks are adjacent
    - if <[chunks].is_empty>:
      - narrate "<&[error]>You must claim chunks adjacent to already-claimed ones."
      - stop
    # Stop if there is more than one settlement in the adjacent chunks
    - if <[chunks].size> > 1 and <[chunks].parse[flag[kdm.claim]].deduplicate> > 1:
      - narrate "<&[error]>Multiple settlements are adjacent to this area."
      - stop
    - define chunk <[chunks].first>
    - define uuid <[chunk].flag[kdm.claim]>
    - define settlement <[uuid].proc[kdm_get_settlement]>
    # Stop if player isn't qualified to claim this chunk
    - if not <[settlement].proc[kdm_is_ruler]>:
      - stop
    # Stop if the settlement doesn't have any claims left
    - if <[settlement].get[claims]> <= 0:
      - narrate "<&[error]>This settlement doesn't have any claims left."
      - stop
    # If everything passes, go through with the claim
    - flag server kdm.settlements.<[uuid]>.claims:--
    - flag server kdm.settlements.<[uuid]>.chunks:->:<[chunk]>
    - flag <[chunk]> kdm.claim:<[uuid]>
    - take item:deed
    # Alert player
    - narrate "<&[positive]>Successfully claimed this area for <&[emphasis]><[settlement].get[names].last><&[positive]>."
    - narrate "<&[base]>This settlement has <&[emphasis]><[settlement].get[claims].sub[1]> <&[base]>claims left."