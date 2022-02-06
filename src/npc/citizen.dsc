kdm_citizen:
  type: assignment
  actions:
    on push:
    - narrate "Hey, watch it!"
  interact scripts:
  - kdm_citizen_interact

kdm_citizen_interact:
  type: interact
  steps:
    1:
      click trigger:
        1:
          trigger: *sword
          script:
          - narrate "Don't point that thing at me!"
        2:
          script:
          - narrate "Hello, traveler."