kdm_config:
  type: data
  min_settlement_distance: 256
  protect_blocks:
  - chest
  cycle_interval: 2

kingdoms:
  type: world
  events:
    after server start:
    - if not <server.has_flag[kdm.cycle]>:
      - flag server kdm.cycle:0
    after custom event id:cdnc_cycle:
    - define interval <script[kdm_config].data_key[cycle_interval]>
    - if <server.flag[kdm.cycle]> < <[interval]>:
      - flag server kdm.cycle:++
    - if <server.flag[kdm.cycle]> == <[interval]>:
      - customevent id:kdm_cycle
      - flag server kdm.cycle:0