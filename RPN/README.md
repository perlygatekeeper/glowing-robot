# RPN Calculator

RPN is an interactive Reverse Polish Notation calculator and a small
stack-oriented programming environment written in Perl.

It began as a command-line calculator and grew to include persistent values,
user-defined functions, vectors, matrices, geometry, transformations, SVG
graphics, plotting, and an extensive built-in learning system.

Current release: **4.1.0**

## Highlights

- Arithmetic, trigonometry, statistics, conversions, and special functions
- Named constants, variables, functions, and executable code blocks
- Multiple persistent stacks and command history
- Random numbers, dice, sequences, filtering, and flow control
- Financial, combinatoric, and number-theory commands
- Immutable vectors and matrices
- Immutable 2D and 3D geometry transformations
- SVG scenes, shapes, styling, and transformed graphics
- Data plotting and executable-function visualization
- Optional SVG QR-code generation
- 26 tutorials, 91 cookbook examples, and command discovery from the prompt
- 3,316 automated tests

## Requirements

- Perl 5.34 or newer
- `make` for the development and verification targets
- `prove`, normally included with Perl, for the test suite

The main calculator and SVG graphics system have no non-core graphics
dependency.

QR-code encoding is optional and requires:

- [`Text::QRCode`](https://metacpan.org/pod/Text%3A%3AQRCode)
- `libqrencode`

## Getting Started

Clone the repository and enter the RPN project directory:

```console
git clone git@github.com:perlygatekeeper/glowing-robot.git
cd glowing-robot/RPN
```

Check the installation:

```console
make check
make docs-check
```

Start the calculator:

```console
make run
```

You can also run it directly:

```console
./rpn.pl
```

## A First Calculation

RPN places values on a stack and then applies commands to them. To calculate
`(3 + 4) * 5`, enter:

```text
3 4
+
5
*
```

The result is `35`. There is no equals sign and no need for parentheses.

Useful stack commands include:

```text
dup      copy the top value
drop     remove the top value
swap     exchange the top two values
clear    clear the current stack
```

## Finding Your Way Around

RPN is designed to teach itself from the prompt:

```text
quickstart
help
help categories
help category matrix
help det
tutorials
tutorial graphics
examples
examples Graphics
```

The generated references are also available in the repository:

- [Command catalog](docs/Command_Catalog_v4.1.0.txt)
- [Examples catalog](docs/Examples_Catalog_v4.1.0.txt)
- [Roadmap](docs/Roadmap.txt)
- [Version 4.1 release notes](docs/Release_notes_v4.1.0.txt)

## Vectors, Matrices, and Transformations

Create a point, translate it, and apply the transformation:

```text
3 4
point2d
5 -2
translate2d
apply2d
```

Result:

```text
[8,2]
```

RPN supports translation, rotation, scaling, shearing, reflection,
composition, and inversion in 2D, with the corresponding affine operations in
3D.

## SVG Graphics

Create a scene, add a styled rectangle, and save it:

```text
640 480
scene
50 50 220 120
rectangle
'lightblue
fillcolor
'navy
strokecolor
draw
'drawing.svg
savesvg
```

Shapes are immutable values. Existing 2D transformations can be attached with
`transformshape`. Scenes can also contain plots and function visualizations.

See [the Graphics tutorial](docs/tutorials/Graphics_v01.txt) and
[graphics examples](examples/13_graphics/README.txt).

## Optional QR Codes on macOS with MacPorts

Install the native QR library and the MacPorts Perl installer:

```console
sudo /opt/local/bin/port install qrencode p5.34-app-cpanminus
sudo /opt/local/bin/cpanm-5.34 Text::QRCode
```

Make sure the MacPorts Perl is selected before running RPN:

```console
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
```

Within RPN, confirm that QR support is active:

```text
qravailable
```

A result of `1` means `qrcode` is ready to use.

## Tests and Documentation Checks

Run everything:

```console
make check
make docs-check
```

Or run the test suite by itself:

```console
make test
```

Other useful targets include:

```console
make syntax
make catalog
make examples-catalog
make backup
```

## Project Layout

```text
rpn.pl              interactive entry point
lib/RPN.pm          calculator coordinator
lib/RPN/            domain objects and command modules
constants/          loadable scientific constant packs
docs/               tutorials, catalogs, release notes, and design documents
examples/           cookbook recipes grouped by topic
t/                  automated tests
tools/              documentation and catalog utilities
```

The architecture favors small domain objects and command-family modules. See
[Architecture.txt](docs/Developer/Architecture.txt) and
[Module_Guide.txt](docs/Developer/Module_Guide.txt) for the development model.

## Author

RPN was designed and developed by Dr. Steven Parker, with collaborative design,
implementation, testing, and documentation assistance from ChatGPT.

## License

No software license has been declared for this repository. Unless a license is
added, copyright law reserves the rights to the author.
