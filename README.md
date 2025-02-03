# Lemongrass

[![Build Status](https://github.com/pyrmont/lemongrass/workflows/build/badge.svg)](https://github.com/pyrmont/lemongrass/actions?query=workflow%3Abuild)

Lemongrass is a pure Janet library for converting between markup languages like
HTML and XML and Janet data structures (in [Hiccup syntax][hs]). It comes with
a CLI utility for converting at the command line.

[hs]: http://weavejester.github.io/hiccup/syntax.html "Read more about Hiccup syntax"

## Library

### Installation

Add the dependency to your `project.janet` file:

```janet
(declare-project
  :dependencies ["https://github.com/pyrmont/lemongrass"])
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
Usage: lg [--format <format>] [--output <path>] [--reverse] [<input>]

Convert from HTML/XML to Janet data structures.

Parameters:

 input    The <path> for the input file. (Default: stdin)

Options:

 -f, --format <format>    The <format> of the markup, either html or xml. (Default: html)
 -o, --output <path>      The <path> for the output file. (Default: stdout)
 -r, --reverse            Reverse the polarity and convert from Janet to markup.

 -h, --help               Show this help message.
```

## Bugs

Found a bug? I'd love to know about it. The best way is to report your bug in
the [Issues][] section on GitHub.

[Issues]: https://github.com/pyrmont/lemongrass/issues

## Licence

Lemongrass is licensed under the MIT Licence. See [LICENSE][] for more details.

[LICENSE]: https://github.com/pyrmont/lemongrass/blob/master/LICENSE
