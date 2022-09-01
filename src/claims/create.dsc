kdm_create_kingdom_confirm:
  type: item
  material: player_head
  display name: <green>Yes
  mechanisms:
    skull_skin: eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvNDMxMmNhNDYzMmRlZjVmZmFmMmViMGQ5ZDdjYzdiNTVhNTBjNGUzOTIwZDkwMzcyYWFiMTQwNzgxZjVkZmJjNCJ9fX0=
  lore:
  - <&[base]>Since you're not in a <red>Kingdom <&[base]>already,
  - <&[base]>you can <&[emphasis]>create your own<&[base]>, with this settlement
  - <&[base]>as its <red>Capital<&[base]>.
  - <empty>
  - <&[base]>With a <red>Kingdom<&[base]>, you'll have more <&[emphasis]>organization<&[base]>,
  - <&[emphasis]>expansion potential<&[base]>, and <&[emphasis]>policy options<&[base]>.

kdm_create_kingdom_deny:
  type: item
  material: player_head
  display name: <red>No
  mechanisms:
    skull_skin: eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvYmViNTg4YjIxYTZmOThhZDFmZjRlMDg1YzU1MmRjYjA1MGVmYzljYWI0MjdmNDYwNDhmMThmYzgwMzQ3NWY3In19fQ==
  lore:
  - <&[base]>This settlement will become <red>Free<&[base]>,
  - <&[base]>but you can <&[emphasis]>spend resources <&[base]>to change this later.

kdm_create_settlement:
  type: task
  definitions: type|kingdom
  script:
  - define data <player.flag[kdm.creating_settlement]>
  - define uuid <[data].get[uuid]>
  - define chunks <[data].get[chunks]>
  - define name <[data].get[name]>
  # Initial flag data for the settlement
  - definemap settlement_data:
      type: <[type]>
      names: <list_single[<[name]>]>
      chunks: <[chunks]>
      town_charter: <[data].get[location]>
  # If town has a kingdom, add to data
  - if <[kingdom]> != null:
    - define settlement_data <[settlement_data].with[kingdom].as[<[kingdom]>]>
  # Flag to server
  - flag server kdm.settlements.<[uuid]>:<[settlement_data]>
  # Flag each chunk with a claim ID
  - foreach <[chunks]> as:chunk:
    - flag <[chunk]> kdm.claim:<[uuid]>
  # Alert player
  - narrate <empty>
  - narrate "<green>The settlement <&[emphasis]><[name]> <green>has been created."
  - if <[kingdom]> != null:
    - define kingdom_name <server.flag[kdm.kingdoms.<[kingdom]>].get[names].last>
    - narrate "<green>It is the <red>Capital <green>of the new <&[emphasis]><[kingdom_name]> <green>kingdom."
  - narrate "<&[base]>Consult the <&[emphasis]>Manual <&[base]>for more details."
  - narrate <empty>
  # Remove temporary data
  - flag <player> kdm.creating_settlement:!

kdm_starting_chunks:
  type: procedure
  script:
  - determine <player.location.chunk.cuboid.expand[32,0,32].chunks>

kdm_create_prompts:
  type: world
  finish_free:
  - define data <player.flag[kdm.creating_settlement]>
  - run kdm_create_settlement def:free|null
  events:
    after custom event id:kdm_prompt_finish data:prompt_id:settlement_name:
    # THe UUID of the settlement
    - define uuid <util.random_uuid>
    # The settlement's starting chunks around where the charter was placed
    - define chunks <proc[kdm_starting_chunks]>
    # If the user isn't part of a kingdom, prompt them to create one
    - if not <player.has_flag[kdm.kingdom]>:
      - flag <player> kdm.creating_settlement.uuid:<[uuid]>
      - flag <player> kdm.creating_settlement.chunks:<[chunks]>
      - flag <player> kdm.creating_settlement.name:<context.text>
      - run kdm_choice "def:create_kingdom|Create a Kingdom?|kdm_create_kingdom_confirm|kdm_create_kingdom_deny"
    - else:
      - run kdm_create_settlement def:kingdom|<player.flag[kdm.kingdom]>
    after custom event id:kdm_prompt_cancel data:prompt_id:settlement_name:
    - define town_charter <player.flag[kdm.creating_settlement.location]>
    - flag <[town_charter]> kdm.town_charter:!
    - flag <player> kdm.creating_settlement:!
    after custom event id:kdm_choice data:choice_id:create_kingdom:
    # If not creating a kingdom, create a free city
    - if not <context.result>:
      - run kdm_create_prompts.finish_free
      - stop
    # If yes, prompt for kingdom info
    - run kdm_prompt "def:kingdom_name|Kingdom Name"
    after custom event id:kdm_prompt_finish data:prompt_id:kingdom_name:
    - define uuid <player.flag[kdm.creating_settlement.uuid]>
    # The UUID of the kingdom
    - define kingdom_uuid <util.random_uuid>
    # Initial flag data of the kingdom
    - definemap kingdom_data:
        names: <list_single[<context.text>]>
        settlements: <list_single[<[uuid]>]>
        capital: <[uuid]>
        members: <list_single[<player>]>
        positions:
          leader:
            members: <list_single[<player>]>
    # Flag to server
    - flag server kdm.kingdoms.<[kingdom_uuid]>:<[kingdom_data]>
    - run kdm_create_settlement def:kingdom|<[kingdom_uuid]>
    on custom event id:kdm_prompt_cancel data:prompt_id:kingdom_name:
    - determine passively no_message
    - narrate "<&[error]>Kingdom creation cancelled; creating free settlement..."
    - run kdm_create_prompts.finish_free