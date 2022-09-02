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

kdm_is_member:
  type: procedure
  definitions: kingdom
  script:
  - if not <player.has_flag[kdm.kingdom]>:
    - determine false
  - determine <player.flag[kdm.kingdom].equals[<[kingdom]>]>