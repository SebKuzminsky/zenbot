This configuration is for the Zenbot CNC Mini Router (2007 version)
with 7i30 driver board, using the Mesa 5i23 for pwm generation &
quadrature counting.

Each axis/joint is run by a servo controlled by a 7i30.  All the servos
have no index channel, instead the index channel is used for home/limit
switches, plus the tool length offset switch.




# Spindle

The spindle is a TB-350S from Wolfgang Engineering (Richard?).

Rated for 0.0001 runout expected, 0.0004 runout max.

20,000 or 25,000 RPM, it's unclear.

Chris Radek has one, and has worked out how to replace the spindle
bearings.




# Work holding

There is not much cutting force on the work, the main job of work holding
is to keep the copper surface parallel to XY across the whole work piece.

I used Target or Scotch branch "permanent double sided tape", it seemed
to work.

FIXME: note new tape, easier to work with since it has paper backing on
one side

Chris Radek says:

    I use the thicker tape with filaments in it that's meant for making
    very poor quality installations of tile or maybe carpet?

    Duck brand "Indoor Heavy Duty Carpet Tape"

    https://www.findtape.com/shop/product-images.aspx?pid=646

Try NYC CNC's technique of "blue painter's tape/ca/blue painter's tape":
https://www.youtube.com/watch?time_continue=628&v=r6DCvtcU8_M




# Z touch off

Bring the tool down close to the work, then raise it 0.001 at a time
until you can just barely roll a precision ground dowel pin between the
tool and the work.  The pins at SSD have a diameter of 0.250 +- 0.001.

If you don't have a dowel pin, the shank of a cutter works too but make
sure you measure the actual diameter carefully.




# Speeds and Feeds


## PreciseBits RCC08-0315-026F

Fish-tail chip breaker router bit, 0.0315 diameter, 0.256 depth of cut.

Speed: 24,000
Feed: 5 ipm, 125 mm/min
Plunge feed: 2.5 ipm, 62 mm/min

https://www.precisebits.com/products/carbidebits/fcrouter.asp?product_id=713
https://www.precisebits.com/products/carbidebits/fdrouter.asp?product_id=742


## PreciseBits MN208-0100-002F

2-flute endmill, 0.010 diameter, 0.015 depth of cut.

Speed: 24,000
Feed: 2.4 ipm, 60 mm/min
Plunge feed: 1.2 ipm, 30 mm/min

https://www.precisebits.com/products/carbidebits/precisebit-stub.asp?product_id=564
https://www.precisebits.com/products/carbidebits/precisebit-stub.asp?product_id=567


## Accupro 0.010" endmill (MSC #37290426)

0.010" diameter 2-flute carbide endmill, 0.015" LOC, 1/8" Shank
Uncoated, Spiral Flute, 30° Helix, Centercutting, Right Hand Cut, Right Hand Flute

MSC prices:
    List Price $23.99
    Your Price $14.87 ea.


## Accupro 0.010" endmill (long) (MSC #37289451)

0.010" diameter 2-flute carbide endmill, 0.030" LOC, 1/8" Shank
Uncoated, Spiral Flute, 30° Helix, Centercutting, Right Hand Cut, Right Hand Flute

MSC prices:
    List Price $23.99
    Your Price $14.87 ea.




# Copper clad board

The work table can hold up to 4" x 6" boards.

I've been using MG Chemicals #506:

    Proto Board Copper Clad FR4
    Single Sided
    1 oz.
    6.00" x 4.00" (152.4mm x 101.6mm)

$7.14 from Digi-Key.




# Toolchain

KiCAD -> FlatCAM -> LinuxCNC


## KiCAD


### Schematic Capture

Design the circuit, save.

Export netlist in pcbnew format.


### PCB Layout

In the schematic editor, click the "Run Pcbnew" tool icon, or
Tools->Update PCB.

In "Setup -> Design Rules..." set "Clearance" and "Track Width" to
reasonable numbers for your machine and tooling.  "Clearance" is the
isolation between traces, should be at least slightly more than the
diameter of your cutting tool.  "Track Width" is trace width.

Use Mounting Hole footprints for mounting holes.

Draw the board outline as a "graphic polygon" on the Edge.Cuts layer.
When we generate gcode for this layer in FlatCAM later, the outside
of the polygon will be cut but the inside will not.  If you draw the
board edge as a collection of "graphic line" and "graphic arc" objects
both inside and outside will be cut, as if the outline were a trace.
It can be fixed in CAM by deleting the inside gcode, but using "graphic
polygon" is simpler.

Use "Place -> Drill and Place Offset" (or select the "place auxiliary
axis origin" tool) to set the origin of the project to the lower left
corner of the board.

To export to FlatCAM or other board fabrication tools:

    File -> Plot

        enable "Use auxiliary axis as origin"

        select the layers (B.Cu, Edge.Cuts), Plot (makes a `.gbr` gerber
        file for each layer).

        "Generate Drill Files...", enable "PTH and NPTH holes in single
        file", "Generate Drill File" (makes `.drl` file).


## FlatCAM

At startup, before loading any project Gerber or Excelleon files, switch
to the "Options" tab, select "APPLICATION DEFAULTS", and set "Units"
to mm, to match what KiCad puts out.


### Load PCB fabrication files

"Open Gerber" to load the different layers.

"Open Excellon" to load the drill file.


### Mirror the bottom copper and the drill locations

* `mirror breakout-board-B.Cu.gbr -axis Y -box breakout-board-Edge.Cuts.gbr`
* `mirror breakout-board.drl -axis Y -box breakout-board-Edge.Cuts.gbr`


### Generate trace isolation geometry from copper layer

In the Project tab, select the B.Cu object.

Switch to the Selected tab.

Set tool diameter to 0.010" (0.254mm) which matches the "PreciseBits
MN208-0100-002F" endmill i'm using).

Click Generate Geometry.


### Generate geometry for irregular board outlines aka Edge Cuts

In the Project tab, select the Edge.Cuts object.

Switch to the Selected tab.

Set tool diameter to 0.0315" (0.794mm) (to match the "PreciseBits
RCC08-0315-026F" endmill i'm using for this cut).

#### If you drew the board edge as a graphic polygon

Click "Generate Geometry".

#### If you drew the board edge as graphic lines & arcs

* `isolate breakout-board-Edge.Cuts.gbr -outname outline-iso`
* `exteriors outline-iso -outname outline`
* `delete outline-iso`
* `delete breakout-board-Edge.Cuts.gbr_iso`


### Mill holes

In the Project tab, select the drill object.

Switch to the Selected tab.

Find the Mill Holes section.

Set tool diameter to 0.0315" (to match the "PreciseBits RCC08-0315-026F"
endmill i'm using for this cut).

Click Generate Geometry.


### Generate G-code

For each of the three toolpath objects (trace isolation, drill/mill,
and board outline), select the object in the "Project" tab, switch to the
"Selected" tab, set "Create CNC Job" options, click "Generate".

For the isolation job: Use the 0.010" endmill, feed 2.4 inch/min (60.1
mm/min), "Cut Z" should be maybe -0.005 inch (-0.127mm), with a single
pass.  (1 oz copper clad board has a 0.0014 inch (0.036mm) thick copper
layer, and it's pretty easy to mount the board with less than 0.003 inch
(0.076mm) wobble.)

For the drill/mill and board outline jobs: Use the 0.031 inch (0.794mm)
endmill, feed 5.0 inch/min (127 mm/min), "Cut Z" should be the thickness
of the board + 0.005" or so, call it 0.070 inch (1.8mm), with a depth/pass
of 0.020 inch (0.5mm)?


### Save the G-code

In each G-code object:

* If you're using mm units: Add "G21 G64 P0.01" to "Prepend to G-code".

* If you're using inch units: Add "G20 G64 P0.0005" to "Prepend to
  G-code".

* Add "M2" to "Append to G-code".

* Turn off Dwell.

* Click "Export G-Code".


# FlatCAM fixes

* Actual helix milling for the holes
