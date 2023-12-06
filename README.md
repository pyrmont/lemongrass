# Lemongrass

[![Build Status](https://github.com/pyrmont/lemongrass/workflows/build/badge.svg)](https://github.com/pyrmont/lemongrass/actions?query=workflow%3Abuild)

Lemongrass is a pure Janet library for converting between markup languages like
HTML and XML and Janet data structures.

## Installation

Add the dependency to your `project.janet` file:

```janet
(declare-project
  :dependencies ["https://github.com/pyrmont/lemongrass"])
```

## Usage

Lemongras can be used like this:

```janet
(import lemongrass)

(lemongrass/markup->janet `<h1 class="foo">Hello world!</h1>`)
# => @[:h1 @{:class "foo"} "Hello world!"]
```

## Bugs

Found a bug? I'd love to know about it. The best way is to report your bug in
the [Issues][] section on GitHub.

[Issues]: https://github.com/pyrmont/lemongrass/issues

## Licence

Lemongrass is licensed under the MIT Licence. See [LICENSE][] for more details.

[LICENSE]: https://github.com/pyrmont/lemongrass/blob/master/LICENSE
