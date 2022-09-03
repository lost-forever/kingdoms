town_charter:
  type: item
  material: writable_book
  display name: <&[item]>Town Charter
  recipes:
    1:
      type: shapeless
      input: material:writable_book|material:wheat|material:*stone|material:iron_ingot
  lore:
  - <&[lore]>Use on a <&[emphasis]>Lectern <&[lore]>to start a settlement!

kdm_check_proximity:
  type: task
  script:
  - define min_distance <script[kdm_config].data_key[min_settlement_distance]>
  - define nearby <player.location.find_blocks_flagged[kdm.town_charter].within[<[min_distance].sub[1]>]>
  - if not <[nearby].is_empty>:
    - define distance <player.location.distance[<[nearby].first>]>
    - define index <[distance].div[<[min_distance].div[3]>].round_down.add[1]>
    - define desc "<list[just |<empty>|far ].get[<[index]>]>"
    - define direction <&[emphasis]><[desc].if_null[<empty>]><player.location.direction[<[nearby].first>]>
    - narrate "<&[error]>Unable to start a settlement; there exists one <[direction]> <&[error]>of here."
    - determine cancelled

kdm_check_starting_chunks:
  type: task
  definitions: chunks
  script:
  - foreach <[chunks]> as:chunk:
    - if <[chunk].has_flag[kdm.claim]>:
      - narrate "<&[error]>This settlement area is already claimed."

kdm_town_charter_fn:
  type: world
  events:
    on player right clicks lectern location_flagged:!kdm.town_charter with:town_charter:
    # Cancel if the lectern is not empty
    - if <context.location.lectern_page> != -1:
      - determine cancelled
    - inject lf_discord_check_link_cancel
    - inject kdm_check_proximity
    # The settlement's starting chunks around where the charter was placed
    - define chunks <proc[kdm_starting_chunks]>
    - inject kdm_check_starting_chunks
    - flag <player> kdm.creating_settlement.location:<context.location>
    - flag <player> kdm.creating_settlement.chunks:<[chunks]>
    - flag <context.location> kdm.town_charter
    - run kdm_prompt "def:settlement_name|Settlement Name"
    on player right clicks lectern location_flagged:kdm.town_charter:
    # TODO Town Charter GUI
    - determine cancelled
    on player takes item from lectern location_flagged:kdm.town_charter:
    - determine cancelled
    on player breaks block location_flagged:kdm.town_charter:
    - determine cancelled