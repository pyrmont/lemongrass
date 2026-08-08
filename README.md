# Lemongrass

[![Test Status][icon]][status]

[icon]: https://github.com/pyrmont/lemongrass/workflows/test/badge.svg
[status]: https://github.com/pyrmont/lemongrass/actions?query=workflow%3Atest

Lemongrass is a pure Janet library for converting between markup languages like
HTML and XML and Janet data structures written in [Hiccup syntax][hs]. It comes
with a CLI utility for converting at the command line.

[hs]: http://weavejester.github.io/hiccup/syntax.html "Read more about Hiccup syntax"

## Library

### Installation

Add the dependency to your `info.jdn` file:

```janet
  :dependencies ["https://github.com/pyrmont/lemongrass"]
```

### Usage

Lemongrass can be used like this:

```janet
(import lemongrass)

(lemongrass/markup->hiccup `<h1 class="foo">Hello world!</h1>`)
# => @[:h1 @{:class "foo"} "Hello world!"]

(lemongrass/hiccup->markup [:h1 {:class "foo"} "Hello world!"])
# => "<h1 class="foo">Hello world!</h1>"
```

Both kinds of output can be pretty printed. Markup is laid out over several
lines by passing `:indent`, the number of spaces to indent each level of
nesting by, with newlines added only where they cannot change how the markup is
interpreted:

```janet
(print (lemongrass/hiccup->markup
         [:div [:ul [:li "One"] [:li "Two"]] [:p "A " [:em "short"] " note."]]
         :indent 2))
# out> <div>
# out>   <ul>
# out>     <li>One</li>
# out>     <li>Two</li>
# out>   </ul>
# out>   <p>A <em>short</em> note.</p>
# out> </div>
```

Without `:indent` the markup is put on one line. Each level is indented by
`:indent` repetitions of `:step`, so tabs are `:indent 1 :step "\t"`. A
separate `:inset` string is put at the start of every line, which shifts the
whole document across for embedding it in another one:

```janet
(print (lemongrass/hiccup->markup [:p "Hi"] :indent 2 :inset "    "))
# out>     <p>Hi</p>
```

Hiccup is pretty printed as Janet source with `hiccup->source`, which takes
`:indent`, `:step` and `:inset` in the same way. An element is kept on one line
where it fits within `:width` columns and holds nothing but text and inline
elements, so the shape of the source follows the shape of the markup:

```janet
(print (lemongrass/hiccup->source
         (lemongrass/markup->hiccup `<div><h1>Hi</h1><p>A <em>short</em> note.</p></div>`)
         :width 40))
# out> @[:div
# out>   @[:h1 "Hi"]
# out>   @[:p "A " @[:em "short"] " note."]]
```

Check out the [API document](api.md) for more information.

## Utility

### Installation

To install the `lg` CLI utility with JPM:

```shell
$ jpm install "https://github.com/pyrmont/lemongrass"
```

### Usage

Run `lg --help` for usage information:

```
$ lg --help
Usage: lg [--format <format>] [--output <path>] [--reverse] [--pretty] [--indent <number>] [--width <number>] [<input>]

Convert from HTML/XML to Hiccup data structures.

Parameters:

 input    The <path> for the input file. (Default: stdin)

Options:

 -f, --format <format>    The <format> of the markup, either html or xml. (Default: html)
 -o, --output <path>      The <path> for the output file. (Default: stdout)
 -r, --reverse            Reverse the polarity and convert from Hiccup to markup.

 -p, --pretty             Pretty print the output over multiple lines.
 -i, --indent <number>    The <number> of spaces added for each level of nesting when pretty printing. (Default: 2)
 -w, --width <number>     The <number> of columns an element is fitted within when pretty printing Hiccup. (Default: 80)

 -h, --help               Show this help message.
```

Output is written on a single line unless `--pretty` is given, and even then
an element holding only text and inline elements is left on one line where it
fits within 80 columns:

```shell
$ cat page.html
<div class="wrap"><h1>Hello</h1><p>Some <em>text</em> and more.</p><ul><li>One</li><li>Two</li></ul></div>

$ lg --pretty page.html
@[:div @{:class "wrap"}
  @[:h1 "Hello"]
  @[:p "Some " @[:em "text"] " and more."]
  @[:ul
    @[:li "One"]
    @[:li "Two"]]]
```

Use `--width` to change the number of columns an element is fitted within and
`--indent` to change the number of spaces added for each level of nesting:

```shell
$ lg --pretty --width 40 --indent 4 page.html
@[:div @{:class "wrap"}
    @[:h1 "Hello"]
    @[:p
        "Some "
        @[:em "text"]
        " and more."]
    @[:ul
        @[:li "One"]
        @[:li "Two"]]]
```

`--indent` applies to markup too, but only Hiccup output is fitted to a width,
so `--width` is ignored when `--reverse` is given.

## Bugs

Found a bug? I'd love to know about it. The best way is to report your bug in
the [Issues][] section on GitHub.

[Issues]: https://github.com/pyrmont/lemongrass/issues

## Licence

Lemongrass is licensed under the MIT Licence. See [LICENSE][] for more details.

[LICENSE]: https://github.com/pyrmont/lemongrass/blob/master/LICENSE
