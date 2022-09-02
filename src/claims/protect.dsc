kdm_protect_chunk:
  type: world
  events:
    after player left clicks block flagged:!kdm.foreigner in:chunk_flagged:kdm.claim:
    - inject kdm_protect_chunk.check_foreigner
    on player breaks block flagged:kdm.foreigner in:chunk_flagged:kdm.claim:
    - if <context.material.name> == chest:
      - determine cancelled
    - inventory adjust slot:hand durability:<player.item_in_hand.durability.add[50]>
    - determine nothing
    on player places block in:chunk_flagged:kdm.claim:
    - inject kdm_protect_chunk.check_foreigner
    - if <player.has_flag[kdm.foreigner]>:
      - determine cancelled
    on entity explodes in:chunk_flagged:kdm.claim:
    - determine <list>
  check_foreigner:
  - if not <player.proc[kdm_is_member].context[<player.location.proc[kdm_get_kingdom_uuid]>]>:
    - flag <player> kdm.foreigner expire:1m
    - cast slow_digging duration:1m amplifier:1 hide_particles no_icon