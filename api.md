# lemongrass API

[hiccup-&gt;markup](#hiccup-markup), [hiccup-&gt;source](#hiccup-source), [janet-&gt;markup](#janet-markup), [janet-&gt;source](#janet-source), [markup-&gt;hiccup](#markup-hiccup), [markup-&gt;janet](#markup-janet)

## hiccup-&gt;markup

**function**  | [source][1]

```janet
(hiccup->markup ds &keys {:add-doctype? add-doctype? :tab tab :indent indent :format format})
```

Converts a Hiccup data structure to markup

This function takes a Hiccup data structure and converts it to markup. By
default, the markup is HTML. If not, `:format` can be set to `:xml`.

If `:indent` is a number, the markup is pretty printed with that many spaces
of leading indentation and `:tab` (two spaces by default) added for each
level of nesting. A newline is only introduced between two nodes where it
cannot change how the markup is interpreted, so the contents of elements
like `<p>` and `<pre>` are left alone. If `:indent` is nil, no whitespace is
added at all.

A `<!doctype html>` declaration is added ahead of a top-level `:html`
element unless `:add-doctype?` is set to false or the data structure
already carries a declaration of its own.

[1]: lib/to-markup.janet#L113


## hiccup-&gt;source

**function**  | [source][2]

```janet
(hiccup->source ds &keys {:tab tab :width width})
```

Converts a Hiccup data structure to a string of Janet source

This function takes a Hiccup data structure and pretty prints it as Janet
source. An element is put on one line if it fits within `:width` columns (80
by default) and none of its children starts a block of its own; otherwise its
tag (and its attributes, if they fit too) stay on the opening line and its
children are placed beneath it, indented by `:tab` (two spaces by default)
for each level of nesting.

Setting `:width` to `math/inf` asks for the compact form, which is the whole
data structure on a single line.

[2]: lib/to-source.janet#L94


## janet-&gt;markup

**function**  | [source][3]

```janet
<function hiccup->markup>
```

An alias for `hiccup->markup`

[3]: lib/to-markup.janet#L167


## janet-&gt;source

**function**  | [source][4]

```janet
<function hiccup->source>
```

An alias for `hiccup->source`

[4]: lib/to-source.janet#L115


## markup-&gt;hiccup

**function**  | [source][5]

```janet
(markup->hiccup s &keys {:html? html?})
```

Converts a string of markup to a Hiccup data structure

This function takes a string of markup and converts it to a Hiccup data
structure. By default, the string is assumed to be HTML. If not, `:html?`
can be set to false.

[5]: lib/to-hiccup.janet#L71


## markup-&gt;janet

**function**  | [source][6]

```janet
<function markup->hiccup>
```

An alias for `markup->hiccup`

[6]: lib/to-hiccup.janet#L130

