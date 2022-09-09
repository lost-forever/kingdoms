kdm_create_kingdom_confirm:
  type: item
  material: player_head
  display name: <&[positive]>Yes
  mechanisms:
    skull_skin: eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvNDMxMmNhNDYzMmRlZjVmZmFmMmViMGQ5ZDdjYzdiNTVhNTBjNGUzOTIwZDkwMzcyYWFiMTQwNzgxZjVkZmJjNCJ9fX0=
  lore:
  - <&[lore]>Since you're not in a <&[kingdom]>Kingdom <&[lore]>already,
  - <&[lore]>you can <&[emphasis]>create your own<&[lore]>, with this settlement
  - <&[lore]>as its <&[kingdom]>Capital<&[lore]>.
  - <empty>
  - <&[lore]>With a <&[kingdom]>Kingdom<&[lore]>, you'll have more <&[emphasis]>organization<&[lore]>,
  - <&[emphasis]>expansion potential<&[lore]>, and <&[emphasis]>policy options<&[lore]>.

kdm_create_kingdom_deny:
  type: item
  material: player_head
  display name: <red>No
  mechanisms:
    skull_skin: eyJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvYmViNTg4YjIxYTZmOThhZDFmZjRlMDg1YzU1MmRjYjA1MGVmYzljYWI0MjdmNDYwNDhmMThmYzgwMzQ3NWY3In19fQ==
  lore:
  - <&[lore]>This settlement will become <&[kingdom]>Free<&[lore]>,
  - <&[lore]>but you can <&[emphasis]>spend resources <&[lore]>to change this later.

kdm_creation_type:
  type: procedure
  definitions: is_kingdom|is_capital
  script:
  - if <[is_kingdom]>:
    - determine <[is_capital].if_true[capital_kingdom].if_false[kingdom]>
  - determine capital_free

kdm_format_creation_description:
  type: procedure
  definitions: type|name
  script:
  - choose <[type]>:
    - case capital_kingdom:
      - determine "<&[positive]>It is the <&[kingdom]>Capital <&[positive]>of the new <&[emphasis]><[name]> <&[positive]>kingdom."
    - case capital_free:
      - determine "<&[positive]>It is a <&[kingdom]>Free <&[positive]>settlement, functioning as its own <&[kingdom]>Capital<&[positive]>."
    - default:
      - determine "<&[positive]>Its allegiance lies with the kingdom of <&[emphasis]><[name]><&[positive]>."

kdm_create_settlement:
  type: task
  definitions: type|kingdom|is_capital|is_ruler
  script:
  - define data <player.flag[kdm.creating_settlement]>
  - define uuid <[data].get[uuid]>
  - define chunks <[data].get[chunks]>
  - define name <[data].get[name]>
  - define is_kingdom <[kingdom].equals[null].not>
  # Initial flag data for the settlement
  - definemap settlement_data:
      is_capital: <[is_capital]>
      type: <[type]>
      ruler: <[is_ruler].if_true[<player>].if_false[null]>
      names: <list_single[<[name]>]>
      chunks: <[chunks]>
      town_charter: <[data].get[location]>
      claims: 3
  # If town has a kingdom, add to data
  - if <[is_kingdom]>:
    - define settlement_data <[settlement_data].with[kingdom].as[<[kingdom]>]>
  # Flag to server
  - flag server kdm.settlements.<[uuid]>:<[settlement_data]>
  # Flag each chunk with a claim ID
  - foreach <[chunks]> as:chunk:
    - flag <[chunk]> kdm.claim:<[uuid]>
  # Alert player
  - define type <proc[kdm_creation_type].context[<[is_kingdom]>|<[is_capital]>]>
  - define kingdom_name <[kingdom].proc[kdm_get_kingdom].get[names].last.if_null[null]>
  - narrate <empty>
  - narrate "<&[positive]>The settlement <&[emphasis]><[name]> <&[positive]>has been created."
  - narrate <proc[kdm_format_creation_description].context[<[type]>|<[kingdom_name]>]>
  - narrate "<&[base]>Consult the <&[emphasis]>Manual <&[base]>for more details."
  - narrate <empty>
  # Remove temporary data
  - flag <player> kdm.creating_settlement:!
  # Fire custom events
  - customevent id:kdm_create context:[settlement=<[settlement_data]>;type=<[type]>;kingdom_name=<[kingdom_name]>]

kdm_starting_chunks:
  type: procedure
  script:
  - determine <player.location.chunk.cuboid.expand[32,0,32].chunks>

kdm_create_prompts:
  type: world
  finish_free:
  - define data <player.flag[kdm.creating_settlement]>
  - run kdm_create_settlement def:free|null|true|true
  events:
    after custom event id:kdm_prompt_finish data:prompt_id:settlement_name:
    # THe UUID of the settlement
    - define uuid <util.random_uuid>
    # If the user isn't part of a kingdom, prompt them to create one
    # TODO: Check for being ruler of Free settlement (requires new flag) and prompt them to create a kingdom including both settlements
    - if not <player.has_flag[kdm.kingdom]>:
      - flag <player> kdm.creating_settlement.uuid:<[uuid]>
      - flag <player> kdm.creating_settlement.name:<context.text>
      - run kdm_choice "def:create_kingdom|Create a Kingdom?|kdm_create_kingdom_confirm|kdm_create_kingdom_deny"
    - else:
      - define is_ruler <player.flag[kdm.kingdom].get[positions.leader.members].contains[<player>].not>
      - run kdm_create_settlement def:kingdom|<player.flag[kdm.kingdom]>|false|<[is_ruler]>
    after custom event id:kdm_prompt_cancel data:prompt_id:settlement_name:
    - define town_charter <player.flag[kdm.creating_settlement.location]>
    - inventory clear d:<[town_charter].inventory>
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
    # Flag data
    - flag server kdm.kingdoms.<[kingdom_uuid]>:<[kingdom_data]>
    - flag <player> kdm.kingdom:<[kingdom_uuid]>
    - flag <player> kdm.positions:->:leader
    - run kdm_create_settlement def:kingdom|<[kingdom_uuid]>|true|false
    on custom event id:kdm_prompt_cancel data:prompt_id:kingdom_name:
    - determine passively no_message
    - narrate "<&[error]>Kingdom creation cancelled; creating free settlement..."
    - run kdm_create_prompts.finish_free