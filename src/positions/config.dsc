# TODO I MAY BE OVERCOMPLICATING THIS, I WILL THINK ABOUT IT

kdm_positions_config:
  type: data
  hierarchy:
  - citizen
  - lord
  - representative
  - prospector
  - advisor
  - leader
  positions:
    citizen:
      name: Citizen
      color: <gray>
      material: paper
      description:
      - A member of the nation. No administrative permissions or obligations.
      permanent: true
    lord:
      name: Lord
      color: <blue>
      material: writable_book
      description:
      - A significant person and contributor to the kingdom.
      - Can place bounties on Citizens in the same nation.
      permanent: false
    representative:
      name: Representative
      color: <yellow>
      material: goat_horn
      description:
      - A spokesperson of the nation.
      - Can shout a highlighted message globally once every hour which will show up on the kingdom log.
      permanent: false
    prospector:
      name: Prospector
      color: <dark_green>
      material: red_banner
      description:
      - A traveler and a settler.
      - Can found new settlements for the nation.
      permanent: false
    advisor:
      name: Advisor
      color: <dark_red>
      material: iron_sword
      description:
      - A kingdom overseer.
      - Can temporarily or permanently exile anyone below them.
      - Can place kill orders on Citizens in the same nation or anyone outside the nation.
      permanent: false
    leader:
      name: Leader
      color: <light_purple>
      material: nether_star
      description:
      - A ruler of the kingdom.
      - Can change the positions of any member and rename positions.
      - Can manage wartime at will.
      - Can make changes to any settlement in the territory.
      permanent: true

kdm_position_item:
  type: procedure
  definitions: position
  script:
  - define item <item[<[position].get[material]>].with[display=<bold><[position].get[color].parsed><[position].get[name]>]>
  - foreach <[position].get[description]> as:line:
    - define lore:->:<[loop_index].equals[1].if_true[<&[base]>].if_false[<&[emphasis]>]><[line]>
  - determine <[item].with[lore=<[lore]>]>

kdm_positions_config_reloader:
  type: world
  events:
    after scripts loaded:
    - define config <script[kdm_positions_config]>
    - define positions <[config].parsed_key[positions]>
    - foreach <[config].parsed_key[hierarchy]> as:position:
      - flag server kdm.positions.items.<[position]>:<[positions].get[<[position]>].proc[kdm_position_item]>