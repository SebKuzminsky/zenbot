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

The spindle uses an O-ring as a drive belt.  I got these from the local
hardware store, both seem to work:

* 2 1/16" OD, 1 7/8" ID, 3/32" wall
* 2 1/8" OD 1 7/8" ID, 1/8" wall




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


From Kyocera:

    http://www.kyoceraprecisiontools.com/micro/speeds-feeds/micro-end-mills-in.html

    Ap = Axial engagement
    Ae = Radial engagement

    Solid carbide endmills (d=0.010) in soft copper alloy (Bronze,
    300-350 sfm):

        ipt (roughing, Ap=1.0d, Ae=0.3d): 0.00004-0.00008
        ipt (finishing, Ap=1.0d, Ae=0.1d): 0.00008-0.00016
        ipt (slotting, Ap=0.5d, Ae=1.0d): 0.00003-0.00005

        slotting (5 thou deep, 10 thou wide):
            0.00003 inch/tooth * 2 tooth/rev * 24000 rev/sec
            0.00006 inch/rev * 24000 rev/sec
            1.44000 inch/sec

        diameter = 0.010 inch
        circumference = 0.031415 inch = 0.0026179939 feet
        speed = 24,000 rev/min
        0.00262 feet/rev * 24000 rev/min
        62.8318536 sfm, way too low but what can you do

    Solid carbide endmills (d=0.010) in hard copper alloy (Brass,
    240-290 sfm): not recommended




# Copper clad board

The work table can hold up to 4" x 6" boards.

I've been using MG Chemicals #506:

    Proto Board Copper Clad FR4
    Single Sided
    1 oz.
    6.00" x 4.00" (152.4mm x 101.6mm)
    the copper layer is 0.0014 inch (0.036 mm) thick

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

At startup, before loading any project Gerber or Excelleon files, set
up some options.  Switch to the "Options" tab and select "APPLICATION
DEFAULTS".

Set "Units" to mm, to match what KiCad puts out.

In the "Gerber Options" section:

* In "Isolation Routing":

    * Set "Tool dia" to 0.254 mm (0.010 inch) which matches the
      "PreciseBits MN208-0100-002F" endmill i'm using.

    * Set "Width (# passes)" to 2.

    * Set "Pass overlap" to 0.15 (this is in percent of the tool
      diameter).

    * Check the "Combine Passes" checkbox.

* In "Board cutout":

    * Set "Tool dia" to 0.800 mm (0.0315 inch) which matches the
      "PreciseBits RCC08-0315-026F" endmill i'm using for this cut.

    * Set "Margin" to 0.000 mm (0.0 inch).

    * Set "Gap size" to 0.000 mm (0.0 inch), since we're using
      double-sided tape for work holding no work-holding tabs are needed.
      FlatCAM imposes a minimum size so we can't get totally rid of them.

    * Set "Gaps" to "2 (L/R)" or whatever feels appropriate to you.
      Since we don't want board cutout gaps and there's no "0" option
      here, you should probably choose one of the 2-gap options.

In the "Excelleon Options" section:

* In "Create CNC Job":

    * Set "Cut Z" to -1.8 mm, just enough to cut all the way through
      the circuit board.

    * Set "Travel Z" to 0.5 mm.

    * Set "Feed Rate" to 125 mm/min.

* In "Mill Holes" section:

    * Set "Tool dia" to 0.794 mm to match the diameter of the cutter
      we'll be milling holes with.

In the "Geometry Options" section:

* In "Create CNC Job":

    * Set "Travel Z" to 0.5 mm.

    * Set "Spindle Speed" to 24,000 rpm.

    Those two options are the same for every operation, so it's useful
    to set the defaults.  The other options will need to change depending
    on the operation, so the defaults are not useful.

In the "CNC Job Options" section:

* In "Export G-Code":

    * Set "Prepend to G-Code": "G21 G64 P0.01" for mm, or "G20 G64
      P0.0005" for inch.

    * Set "Append to G-Code": "m2"

    * Disable "Dwell".

Go to "File" -> "Save Defaults".  If you changed any of the application
settings you have to quit FlatCAM and restart for them to take effect.


### Load PCB fabrication files

"Open Gerber" to load the 'back copper' and 'edge cuts' files.

"Open Excellon" to load the drill file.


### Mirror the bottom copper and the drill locations

Select "Tool" -> "Double-Sided PCB Tool".

In "Bottom Layer", select the bottom copper gerber.

Set "Mirror Axis" to "Y".

Set "Axis Location" to "Box".

Set "Point/Box" to the edge cuts gerber.

Click "Mirror Object".

In "Bottom Layer", select the excelleon drill file.

Click "Mirror Object".


### Generate trace isolation geometry from the back copper layer

In the Project tab, select the B.Cu object.

Switch to the "Selected" tab.

Click "Isolation Routing" -> "Generate Geometry".

In the resulting "Geometry Object", set these options:

* "Cut Z": Maybe -0.051 mm (-0.002 inch).  1 oz copper clad board has
  a 0.036 mm (0.0014 inch) thick copper layer, and it's pretty easy to
  mount the board with less than 0.076 mm (0.003 inch) wobble.

* "Feed Rate": 60.1 mm/min (2.4 inch/min)

* "Multi-Depth": disabled (since this cut is so shallow)

Note: "Travel Z", "Tool dia" and "Spindle speed" should be set correctly
from the application defaults we set up earlier.

Click "Create CNC Job" -> "Generate".

In the resulting "CNC Job Object", click "Export G-Code".


### Generate geometry for the board outline

In the Project tab, select the Edge.Cuts object.

Switch to the "Selected" tab.

#### If you drew the board edge as a graphic polygon

Click "Board cutout" -> "Generate Geometry".

In the resulting "Geometry Object", set these options:

* "Cut Z": Maybe -1.800 mm (-0.070 inch).  1 oz copper clad board is
  about 0.065" thick, so this should cut through with a reasonable margin.

* "Feed Rate": 127 mm/min (5.0 inch/min)

* "Multi-Depth": enabled

* "Depth/pass": 0.5 mm (0.200 inch)

Note: "Travel Z", "Tool dia", and "Spindle speed" should all have correct
values from the application defaults we set earlier.

Click "Create CNC Job" -> "Generate".

In the resulting "CNC Job Object", click "Export G-Code".


#### If you drew the board edge as graphic lines & arcs

* `isolate breakout-board-Edge.Cuts.gbr -outname outline-iso`
* `exteriors outline-iso -outname outline`
* `delete outline-iso`
* `delete breakout-board-Edge.Cuts.gbr_iso`


### Mill holes

In the Project tab, select the drill object.

Switch to the "Selected" tab.

Find the "Mill Holes" section.

Verify that "Tool dia" has the correct default value of 0.800 mm (0.0315
inch) (to match the "PreciseBits RCC08-0315-026F" endmill i'm using for
this cut).

Click "Mill Holes" -> "Generate Geometry".

In the resulting "CNC Job Object", set these options:

* "Cut Z": Maybe -1.800 mm (-0.070 inch).  1 oz copper clad board is
  about 0.065" thick, so this should cut through with a reasonable margin.

* "Feed Rate": 100 mm/min (4.0 inch/min)

* "Tool dia": 0.800 mm (0.0315 inch)

* "Multi-Depth": enabled

* "Depth/pass": 0.5 mm (0.200 inch)

Note: "Travel Z" and "Spindle speed" should have the correct default
values from Application Options.

Click "Create CNC Job" -> "Generate".

In the resulting "CNC Job Object", click "Export G-Code".


# FlatCAM fixes

* Actual helix milling for the holes

* Ramp entry on multi-depth paths.

* Shouldn't `G0X0Y0` at the end.
