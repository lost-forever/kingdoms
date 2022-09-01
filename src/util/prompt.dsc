kdm_prompt_item:
  type: item
  display name: <&gt><&sp>
  material: writable_book
  lore:
  - <dark_aqua>Rename <&[base]>to input text
  - <dark_aqua>Click <&[base]>to <green>confirm
  - <&[base]>Exit to <red>cancel

kdm_prompt_inventory:
  type: inventory
  inventory: anvil
  gui: true
  slots:
  - [kdm_prompt_item] [] []

kdm_prompt:
  type: task
  definitions: id|title
  script:
  - flag <player> kdm.prompt:<[id]>
  - define inv <inventory[kdm_prompt_inventory]>
  - adjust <[inv]> title:<[title]>
  - inventory open d:<[inv]>

kdm_handle_prompt:
  type: world
  events:
    on player clicks item in kdm_prompt_inventory flagged:kdm.prompt slot:3:
    # trim_to_character_set[abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ<&sq><&sp>]
    - define text <context.inventory.anvil_rename_text.after[<&gt>].trim>
    - customevent id:kdm_prompt_finish context:[prompt_id=<player.flag[kdm.prompt]>;text=<[text]>]
    - flag <player> kdm.prompt:!
    - inventory close
    after player closes kdm_prompt_inventory flagged:kdm.prompt:
    - customevent id:kdm_prompt_cancel context:[prompt_id=<player.flag[kdm.prompt]>] save:result
    - flag <player> kdm.prompt:!
    - if no_message not in <entry[result].determination_list>:
      - narrate "<&[error]>Prompt cancelled!"