# lemongrass API


[janet-&gt;markup](#janet-markup), [markup-&gt;janet](#markup-janet)

## janet-&gt;markup

**function**  | [source][1]

```janet
(janet->markup ds &keys {:indent indent :format format})
```

Converts a Janet data structure

This function takes a Hiccup-style Janet datastructure and converts it to
markup

[1]: lib/to-markup.janet#L93

## markup-&gt;janet

**function**  | [source][2]

```janet
(markup->janet s &keys {:html? html?})
```

Converts a string of markup to a Janet data structure

This function takes a string of markup and converts it to a Hiccup-style
data structure in Janet. By default, the string is assumed to be HTML. If
not, `:html?` can be set to false.

[2]: lib/to-janet.janet#L79

