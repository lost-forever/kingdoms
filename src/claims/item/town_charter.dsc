town_charter:
  type: item
  material: writable_book
  display name: <yellow>Town Charter
  recipes:
    1:
      type: shapeless
      input: material:writable_book|material:wheat|material:*stone|material:iron_ingot

kdm_town_charter_fn:
  type: world
  events:
    on player right clicks lectern with:town_charter:
    - if <context.location.has_flag[kdm.town_charter]> || <context.location.lectern_page> != -1:
      - determine cancelled
    - inject kdm_claim
    - flag <context.location> kdm.town_charter
    on player takes item from lectern location_flagged:kdm.town_charter:
    - determine cancelled
    on player breaks block location_flagged:kdm.town_charter:
    - determine cancelled