# ``SalonKit``

The shared kit of the two Salon1c apps — app models, salon configuration, and the
single typed door to the `Salon1cAPI` package.

## Overview

Two apps — SalonBook for the customer, SalonDesk for the staff — share one
direction, so the direction docs live here in the kit rather than in either app:
two apps, one direction, one place to read it.

Rule 1 is the kit's reason to exist: generated types stop at the controller
boundary. Controllers use the generated `Client` and `.payload()`; views see
app models (``Salon``) — never `Components.Schemas.*`. ``SalonClient`` is the
one door to the wire, ``SalonConfiguration`` the white-label dial.

## Topics

### Project Direction

- <doc:Vision>
- <doc:Design>
- <doc:Roadmap>
- <doc:TechDebt>

### Essentials

- ``SalonConfiguration``
- ``Salon``
- ``SalonClient``
