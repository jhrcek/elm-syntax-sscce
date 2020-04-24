This SSCCE demonstrates a likely bug in elm-syntax

It seems that parsing expressions doesn't take operator precedence in account.

Input elm module being parsed:

```elm
module A exposing (..)

bool1 = True && True || True
bool2 = True || True && True

numeric1 = 1 ^ 2 * 3 + 4
numeric2 = 1 + 2 * 3 ^ 4
```

Output expressions formatted as trees. Notice that the expressions trees are right biased in all cases, despite
operator precedence being (see elm/core [Basics.elm](https://github.com/elm/core/blob/84f38891468e8e153fc85a9b63bdafd81b24664e/src/Basics.elm#L71-L89))
- && > ||
- ^ > * > +

```
&&
│
├─ True
│
└─ ||
   │
   ├─ True
   │
   └─ True

||
│
├─ True
│
└─ &&
   │
   ├─ True
   │
   └─ True

^
│
├─ 1
│
└─ *
   │
   ├─ 2
   │
   └─ +
      │
      ├─ 3
      │
      └─ 4

+
│
├─ 1
│
└─ *
   │
   ├─ 2
   │
   └─ ^
      │
      ├─ 3
      │
      └─ 4
```

To reproduce this issue run

```bash
elm make src/Main.elm
# Now open index.html in your browser
```

