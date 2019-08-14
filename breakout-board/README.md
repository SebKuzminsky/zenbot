This is a breakout board for connecting the Zenbot to a Mesa FPGA board.

It connects to a standard 50-pin ribbon cable from the Mesa FPGA board.

It passes the servo pins for channels 0, 1, and 2 to a second 50-pin
connector, for connecting to the 7i30 and driving the X, Y, and Z servos.

The remaining FPGA connector pins are routed to screw terminals, for
additional IO (eg the control line for an SSR to power the spindle).

The servo control pins are:

    1-23, 29, 31, 35, 39, 43, 47 (and 49)

The GPIO pins are:

    25, 27, 33, 37, 41, 45 (and 49)

The male 50-pin connectors are TE Part #1-5499923-0

The screw terminals are Phoenix Contact Part #1725711, "MPT 0,5/ 8-2,54"


# Fabrication

1. Mount a piece of single-sided 1 oz copper clad board to the mill.
   Make sure it's level.

2. Insert a PreciseBits MN208-0100-002F cutter, touch off Z

3. Open the `back-copper.ngc` gcode file and touch off X and Y at the
   lower left corner of the work.

4. Safety glasses, hearing protection, and spindle on.

5. Run the `back-copper.ngc` gcode file.

6. Switch to the PreciseBits RCC08-0315-026F cutter, touch off Z but
   not X and Y.

7. Safety glasses, hearing protection, and spindle on.

8. Run `drill-mill.ngc`.

9. Run `outline.ngc`.


# Prototypes

## Prototype 0: d7a043c1

* Cut deeper!  Some of the cuts didn't remove all the copper.

* The resistor lead holes should be a little larger diameter.  The pins
  on the other four components (LED, screw terminal, 50-pin connectors)
  all fit well.

* Would it be useful to to connect the ground pins on the 50-pin
  connectors to the ground plane?

* The 2x25 connectors extend past the end of the board some.


## Prototype 1: 2033f8a4

### Design changes from previous prototype

* Use a resistor with fatter leads.

* Cut 0.010 deep instead of 0.008.

* Resize the board to be more compact, and so the 2x25 connectors fit.
  I can fit two prototypes on a 4x6 board now.

### Fabrication

Broke two 0.010 endmills while cutting `back-copper.ngc`.  The first time
I switched in a fresh tool and restarted from just before where it broke,
but that was my last spare and now the project is stalled again.

I guess the 0.010 axial depth of cut is too much, maybe make the cut in
two passes of 0.005 or so instead?


## Prototype 2: a6cbd07e

### Design changes

* Increase PCB trace isolation from 0.010" to 0.011", so i can optionally
  use larger (by 0.001, but still), cheaper endmills.

* Decrease isolation milling depth of cut from 0.010" to 0.006", hopefully
  i'll break fewer tools.  If it doesn't isolate properly (like it
  probably won't) i can always touch off Z deeper and rerun the program.

### Fabrication

First pass ran to completion, didn't break the cutter (yay!), but didn't
fully isolate the traces (as expected).

Moved Z down 0.005, reran the program.

It finished!  There were a lot of burrs on the edges of the cuts, some
that caused shorts between the traces or between the traces and the
untouched copper pour.  I scrubbed it with a scotchbrite pad and that
fixed it, it's good!
