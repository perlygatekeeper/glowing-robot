# Function Composition

One of the design goals of the RPN calculator is that higher-level operations
should be composed from simpler building blocks whenever possible.

The following diagram illustrates how the built-in commands, user functions,
and application-specific functions build upon one another.

-------------------------------------------------------------------------------
Primitive Commands
-------------------------------------------------------------------------------

    dieroll
    repeat
    sort
    sum
    sprintf
    withstack
    withcopystack
    pop
    exch
    over
    ifelse
    ...

-------------------------------------------------------------------------------
Dice Functions
-------------------------------------------------------------------------------

    d4     ─────────────► 4 dieroll
    d6     ─────────────► 6 dieroll
    d8     ─────────────► 8 dieroll
    d10    ─────────────► 10 dieroll
    d20    ─────────────► 20 dieroll
    d100   ─────────────► 100 dieroll


-------------------------------------------------------------------------------
Selection Functions
-------------------------------------------------------------------------------

                      max2
                        │
          over over <= ifelse
               │            │
               ▼            ▼
           keeptop      keep2
               │            │
          exch pop        pop


                      min2
                        │
          over over >= ifelse
               │            │
               ▼            ▼
           keeptop      keep2


-------------------------------------------------------------------------------
Advantage / Disadvantage
-------------------------------------------------------------------------------

                 adv
                  │
        ┌─────────┴─────────┐
        ▼                   ▼
      d20                 d20
        │                   │
        └─────────┬─────────┘
                  ▼
                max2


                 dis
                  │
        ┌─────────┴─────────┐
        ▼                   ▼
      d20                 d20
        │                   │
        └─────────┬─────────┘
                  ▼
                min2


-------------------------------------------------------------------------------
Ability Score Generation
-------------------------------------------------------------------------------

                               stat
                                 │
                                 ▼
         "_string_" "4d6kh3_as_string" withstack
                                 │
                                 ▼
                        4d6kh3_as_string
                                 │
                        format sprintf
                                 │
                                 ▼
                             4d6kh3
                     ┌──────────┴──────────┐
                     ▼                     ▼
                   4d6              sum_highest_3
                     │                     │
          4 "d6" repeat sort              │
                     │                     │
                     ▼                     ▼
                    d6        "_sum_" "sum3" withcopystack
                     │                     │
                     ▼                     ▼
                6 dieroll               sum3
                                          │
                                          ▼
                                     pop → sum


-------------------------------------------------------------------------------
Architectural Layers
-------------------------------------------------------------------------------

Level 0
    Primitive commands.

Level 1
    Simple user functions.

Level 2
    Reusable combinators.

Level 3
    Domain-specific functions.

Level 4
    Presentation functions.

Level 5
    User-facing commands.

As the language evolves, new functionality should generally be added by
composing existing operations rather than by introducing new primitive
commands whenever practical.
