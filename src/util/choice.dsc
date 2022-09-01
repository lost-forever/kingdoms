kdm_choice_inventory:
  type: inventory
  inventory: chest
  gui: true
  procedural items:
  - determine <player.flag[kdm.choice.buttons].if_null[<list>]>
  definitions:
    y: lime_stained_glass_pane[display=<&sp>]
    n: red_stained_glass_pane[display=<&sp>]
    g: gray_stained_glass_pane[display=<&sp>]
  slots:
  - [y] [y] [] [y] [g] [n] [] [n] [n]

kdm_choice:
  type: task
  definitions: id|title|confirm|deny
  script:
  - flag <player> kdm.choice.id:<[id]>
  - flag <player> kdm.choice.title:<[title]>
  - flag <player> kdm.choice.buttons:<list[<[confirm]>|<[deny]>]>
  - inject kdm_choice.open_inventory
  open_inventory:
  - define inv <inventory[kdm_choice_inventory]>
  - adjust <[inv]> title:<[title]>
  - inventory open d:<[inv]>

kdm_handle_choice:
  type: world
  events:
    after player clicks item in kdm_choice_inventory flagged:kdm.choice:
    - if <context.slot> != 3 and <context.slot> != 7:
      - stop
    - customevent id:kdm_choice context:[choice_id=<player.flag[kdm.choice.id]>;result=<context.slot.equals[3]>]
    - flag <player> kdm.choice:!
    - inventory close
    after player closes kdm_choice_inventory flagged:kdm.choice:
    - define title <player.flag[kdm.choice.title]>
    - inject kdm_choice.open_inventory