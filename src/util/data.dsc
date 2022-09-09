kdm_get_settlement_uuid:
  type: procedure
  definitions: loc
  script:
  - determine <[loc].chunk.flag[kdm.claim].if_null[null]>

kdm_get_settlement:
  type: procedure
  definitions: uuid
  script:
  - determine <server.flag[kdm.settlements.<[uuid]>]>

kdm_get_kingdom_uuid:
  type: procedure
  definitions: loc
  script:
  - define settlement <[loc].proc[kdm_get_settlement_uuid].proc[kdm_get_settlement]>
  - if <[settlement]> == null or <[settlement].get[type]> != kingdom:
    - determine null
  - determine <[settlement].get[kingdom]>

kdm_get_kingdom:
  type: procedure
  definitions: uuid
  script:
  - determine <server.flag[kdm.kingdoms.<[uuid]>]>

__kdm_player_data_checks:
  type: task
  definitions: settlement
  script:
  - if not <player.has_flag[kdm.kingdom]>:
    - determine false
  - if <[settlement].get[type]> == free:
    - determine <[settlement].get[ruler].equals[<player>]>
  - define kingdom <[settlement].get[kingdom].proc[kdm_get_kingdom]>

kdm_is_ruler:
  type: procedure
  definitions: settlement
  script:
  - inject __kdm_player_data_checks
  - determine <[kingdom].get[positions.leader.members].contains[<player>]>

kdm_is_member:
  type: procedure
  definitions: settlement
  script:
  - inject __kdm_player_data_checks
  - determine <player.flag[kdm.kingdom].equals[<[kingdom]>]>

