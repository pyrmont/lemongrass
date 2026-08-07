# lemongrass API

[janet-&gt;markup](#janet-markup), [janet-&gt;source](#janet-source), [markup-&gt;janet](#markup-janet)

## janet-&gt;markup

**function**  | [source][1]

```janet
(janet->markup ds &keys {:add-doctype? add-doctype? :tab tab :indent indent :format format})
```

Converts a Janet data structure to markup

This function takes a Hiccup-style Janet data structure and converts it to
markup. By default, the markup is HTML. If not, `:format` can be set to
`:xml`.

If `:indent` is a number, the markup is pretty printed with that many spaces
of leading indentation and `:tab` (two spaces by default) added for each
level of nesting. Newlines are only introduced between children where they
cannot change how the markup is interpreted, so the contents of elements
like `<p>` and `<pre>` are left alone. If `:indent` is nil, no whitespace is
added.

A `<!doctype html>` declaration is added ahead of a top-level `:html`
element unless `:add-doctype?` is set to false or the data structure
already carries a declaration of its own.

[1]: lib/to-markup.janet#L110


## janet-&gt;source

**function**  | [source][2]

```janet
(janet->source ds &keys {:tab tab :width width})
```

Converts a Janet data structure to a string of Janet source

This function takes a Hiccup-style Janet data structure and pretty prints it
as Janet source. An element is put on one line if it fits within `:width`
columns (80 by default); otherwise its tag (and its attributes, if they fit
too) stay on the opening line and its children are placed beneath it,
indented by `:tab` (two spaces by default) for each level of nesting.

[2]: lib/to-source.janet#L73


## markup-&gt;janet

**function**  | [source][3]

```janet
(markup->janet s &keys {:html? html?})
```

Converts a string of markup to a Janet data structure

This function takes a string of markup and converts it to a Hiccup-style
data structure in Janet. By default, the string is assumed to be HTML. If
not, `:html?` can be set to false.

[3]: lib/to-janet.janet#L71

