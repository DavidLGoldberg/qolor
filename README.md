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

*   Custom styling of underline / border.

*   Better handling of colors.  Possibly hue blending etc.  Leverage theme
information.  I still want these to be deterministic but for example,
perhaps a marginal shift of the colors to play nicely with the themes.

*   Jump to and from matching tables and aliases under cursor.

*   List number of references in the status bar.

## Prior Art / Related Works?

I got the idea for Qolor one day while painfully hunting through the zig zag of aliases of a giant query.

Later a friend pointed out that a lot of related work in the area of "semantic highligting" already exists.  I have yet to find one (have not done an exhaustive search) that does this semantic highlighting for SQL in this table to alias manner.  Let me know if another exists!

Here are some links:
__ TODO __

## How it works
Qolor uses the language-sql grammar built into Atom.  It does a double pass once for the table names and another for the aliases.

I don't know of any SQL parsers in node usable for this.

The code is ugly.  The grammar for SQL suffices for syntax coloring, but it's tokens aren't always accurate.  I try to make a layer of rules on top.

It should work for most cases, but please report any issues.
