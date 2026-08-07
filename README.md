# Lemongrass

[![Test Status][icon]][status]

[icon]: https://github.com/pyrmont/lemongrass/workflows/test/badge.svg
[status]: https://github.com/pyrmont/lemongrass/actions?query=workflow%3Atest

Lemongrass is a pure Janet library for converting between markup languages like
HTML and XML and Janet data structures (in [Hiccup syntax][hs]). It comes with
a CLI utility for converting at the command line.

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

(lemongrass/markup->janet `<h1 class="foo">Hello world!</h1>`)
# => @[:h1 @{:class "foo"} "Hello world!"]

(lemongrass/janet->markup [:h1 {:class "foo"} "Hello world!"])
# => "<h1 class="foo">Hello world!</h1>"
```

Both kinds of output can be pretty printed. Markup is indented by passing
`:indent`, with newlines added only where they cannot change how the markup is
interpreted:

```janet
(print (lemongrass/janet->markup
         [:div [:ul [:li "One"] [:li "Two"]] [:p "A " [:em "short"] " note."]]
         :indent 0))
# out> <div>
# out>   <ul>
# out>     <li>One</li>
# out>     <li>Two</li>
# out>   </ul>
# out>   <p>A <em>short</em> note.</p>
# out> </div>
```

Hiccup is pretty printed as Janet source with `janet->source`. An element is
kept on one line where it fits within `:width` columns and holds nothing but
text and inline elements, so the shape of the source follows the shape of the
markup:

```janet
(print (lemongrass/janet->source
         (lemongrass/markup->janet `<div><h1>Hi</h1><p>A <em>short</em> note.</p></div>`)
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

Convert from HTML/XML to Janet data structures.

Parameters:

 input    The <path> for the input file. (Default: stdin)

Options:

 -f, --format <format>    The <format> of the markup, either html or xml. (Default: html)
 -o, --output <path>      The <path> for the output file. (Default: stdout)
 -r, --reverse            Reverse the polarity and convert from Janet to markup.

 -p, --pretty             Pretty print the output over multiple lines.
 -i, --indent <number>    The <number> of spaces added for each level of nesting when pretty printing. (Default: 2)
 -w, --width <number>     The <number> of columns an element is fitted within when pretty printing to Janet. (Default: 80)

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

`--indent` applies to markup too, but only Janet output is fitted to a width,
so `--width` is ignored when `--reverse` is given.

## Bugs

Found a bug? I'd love to know about it. The best way is to report your bug in
the [Issues][] section on GitHub.

[Issues]: https://github.com/pyrmont/lemongrass/issues

## Licence

Lemongrass is licensed under the MIT Licence. See [LICENSE][] for more details.

[LICENSE]: https://github.com/pyrmont/lemongrass/blob/master/LICENSE
