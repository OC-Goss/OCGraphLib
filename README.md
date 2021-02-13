# OCGraphLib
OpenComputers Graphing Library  

Made/Tested for lua 5.3, May/May not work on other versions of lua.  
May still be buggy, but should be good enough for usage.  
Examples are in `examples/`  
Requires my `subpixel3` library (included)

## Documentation  
 - `graphlib.drawGraph(data:table, x:number, y:number, w:number, h:number[, range:number, options:table])`  
Draws a graph of the data given, at the coordinates given, in the size specified. Optionally a range and other options can be provided to customise the graph.  
Parameters:  
`data`: The table of values to be drawn.  
`x` and `y`: The coordinates to draw the data at.  
`w` and `h`: The width and height of the graph.  
`range`: The "range" of the graph, for example, a value of 3000 will make the graphs vertical scale be 0 to 3000. If this is `nil`, the graph will use the largest value in the table as the range.  
`options`: A table of options that can be provided to customise the appearance of the graph. These include `fg` (Foreground Colour), `bg` (Background Colour), `textfg` (Text Foreground Colour), `textbg` (Text Background Colour), `style` (Graph Style, 1 for line graph, 2 for "filled" line graph), `title` (Graph Title), `legend` (Graph Legend, Displays Max and Min values), `current` (Current Value, Displays the current value).
 - `graphlib.cycleTable(data:table, newdata:number[, length:number]):number`  
 "Cycles" the table one place to the left, and appends `newdata` to the end.  
 Returns the value that was previously at index 1.  
 Parameters:  
 `data`: The table of values to cycle.  
 `newdata`: The data to append.  
 `length`: (Optional) The length to assume the table is.
