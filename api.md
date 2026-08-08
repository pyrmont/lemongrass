# lemongrass API

[hiccup-&gt;markup](#hiccup-markup), [hiccup-&gt;source](#hiccup-source), [janet-&gt;markup](#janet-markup), [janet-&gt;source](#janet-source), [markup-&gt;hiccup](#markup-hiccup), [markup-&gt;janet](#markup-janet)

## hiccup-&gt;markup

**function**  | [source][1]

```janet
(hiccup->markup ds &keys {:add-doctype? add-doctype? :inset inset :tab tab :indent indent :step step :format format})
```

Converts a Hiccup data structure to markup

This function takes a Hiccup data structure and converts it to markup. By
default, the markup is HTML. If not, `:format` can be set to `:xml`.

If `:indent` is a number, the markup is laid out over several lines, each
level of nesting indented by that many repetitions of `:step` (a single
space by default). A newline is only introduced between two nodes where it
cannot change how the markup is interpreted, so the contents of elements
like `<p>` and `<pre>` are left alone. If `:indent` is nil, the markup is
put on one line.

`:inset` is a string put at the start of every line, whether or not the
markup is laid out. It shifts the whole document across without taking any
part in the indentation of one level relative to another.

A `<!doctype html>` declaration is added ahead of a top-level `:html`
element unless `:add-doctype?` is set to false or the data structure
already carries a declaration of its own.

[1]: lib/to-markup.janet#L113


## hiccup-&gt;source

**function**  | [source][2]

```janet
(hiccup->source ds &keys {:inset inset :width width :tab tab :indent indent :step step})
```

Converts a Hiccup data structure to a string of Janet source

This function takes a Hiccup data structure and renders it as Janet source.

If `:indent` is a number, the source is laid out over several lines. An
element is put on one line if it fits within `:width` columns (80 by
default) and none of its children starts a block of its own; otherwise its
tag (and its attributes, if they fit too) stay on the opening line and its
children are placed beneath it, indented by `:indent` repetitions of `:step`
(a single space by default) for each level of nesting. If `:indent` is nil,
the whole data structure is put on one line and `:width` is ignored.

`:inset` is a string put at the start of every line, whether or not the
source is laid out. It shifts the whole data structure across without taking
any part in the indentation of one level relative to another, and counts
against `:width` like any other leading whitespace.

[2]: lib/to-source.janet#L94


## janet-&gt;markup

**function**  | [source][3]

```janet
(janet->markup ds &keys {:indent indent :add-doctype? add-doctype? :format format})
```

A deprecated conversion of a Hiccup data structure to markup

This function is kept for code written before `:step` and `:inset` were
introduced, when `:indent` was the number of spaces every line was shifted
across by and each level of nesting was indented by a further two. It takes
`:indent` that way and passes the rest of its arguments along unchanged.

New code should call `hiccup->markup`, where `:indent` is the number of
steps added for each level of nesting and the shift across is `:inset`.

[3]: lib/to-markup.janet#L176


## janet-&gt;source

**function**  | [source][4]

```janet
A deprecated alias for `hiccup->source`
```

This name is kept for code written before the library used Hiccup
terminology. New code should call `hiccup->source`.

[4]: lib/to-source.janet#L128


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
A deprecated alias for `markup->hiccup`
```

This name is kept for code written before the library used Hiccup
terminology. New code should call `markup->hiccup`.

[6]: lib/to-hiccup.janet#L130

