town_charter:
  type: item
  material: writable_book
  display name: <yellow>Town Charter
  recipes:
    1:
      type: shapeless
      input: material:writable_book|material:wheat|material:*stone|material:iron_ingot

kdm_check_proximity:
  type: task
  script:
  - define nearby <player.location.find_blocks_flagged[kdm.town_charter].within[512]>
  - if not <[nearby].is_empty>:
    - define other <[nearby].first>
    - define distance <player.location.distance[<[other]>]>
    - if <[distance]> <= 150:
      - define desc "just "
    - else if <[distance]> >= 300:
      - define desc "far "
    - define direction <&[emphasis]><[desc].if_null[<empty>]><player.location.direction[<[other]>]>
    - narrate "<&[error]>Unable to start a settlement; there exists one <[direction]> <&[error]>of here."
    - determine cancelled

kdm_town_charter_fn:
  type: world
  events:
    on player right clicks lectern with:town_charter:
    - if <context.location.has_flag[kdm.town_charter]> || <context.location.lectern_page> != -1:
      - determine cancelled
    - inject lf_discord_check_link_cancel
    #- inject kdm_check_proximity
    - flag <player> kdm.creating_settlement.location:<context.location>
    - flag <context.location> kdm.town_charter
    - run kdm_prompt "def:settlement_name|Settlement Name"
    on player takes item from lectern location_flagged:kdm.town_charter:
    - determine cancelled
    on player breaks block location_flagged:kdm.town_charter:
    - determine cancelled