# Qolor

(WIP) An atom package to color your queries!

Qolor applies semantic highlighting to your SQL queries by matching tables to
their aliases using the same color.

All colors of tables are deterministic from their table name.
They will be the same on any Atom editor anywhere!

## Installation

    apm install qolor

## Settings

Two stylistic flavors.  Underline or a border box.

## TODO
* Custom styling of underline / border.
* Better handling of colors.  Possibly hue blending etc.  Leverage theme
information.  I still want these to be deterministic but for example,
perhaps a marginal shift of the colors to play nicely with the themes.
* Jump to and from matching tables and aliases under cursor.
* List number of references in the status bar.
