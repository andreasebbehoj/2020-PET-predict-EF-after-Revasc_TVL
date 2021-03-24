***** 1_FigTabLayout.do *****

***** Graphs
** General
set scheme s2color
grstyle init graphlayout, replace
grstyle set plain // No plot region color, white background + other tweaks

** Size
grstyle set graphsize 1200pt 1200pt // in pixels, default is 5.5 inches *72 pt/inch = 396pt
grstyle set symbolsize small
grstyle set size 20pt: axis_title // X and Y axis text size

** Axis
grstyle anglestyle vertical_tick horizontal // Horizontal "tick"text on y-axis
grstyle color major_grid gs11 // colour of horizontal lines

** Legend
grstyle set legend ///
	10, /// clock position of legend (1-12).
	nobox /// no legend background
	inside // inside plotregion

** Line graphs (size, colors and patterns)
grstyle set linewidth 3pt: p // line width (line and rcap)


** Export
graph set eps logo off
global exportformat = ".png"
global exportoptions = ", replace width(1200)"
global exportvector = ".eps, replace"


***** Tables
global tablecells =  `"border(all, nil) halign(center) valign(center)"'
global tablefirstrow = `"border(bottom, single) bold shading(191 191 191)"' // First row: bold, underlined and dark gray
global tabletotalrow = `"border(bottom, single, black, 1) "' // Bottom row, black line bottom
global tablerows = `"shading(217 217 217)"' // Remaining subheaders light grey
global tablefirstcol = `"halign(left)"' // First column, left aligned
