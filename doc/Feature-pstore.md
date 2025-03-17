# omnect device management - feature `pstore`

## Motivation

For devices in the field it is important to know why they rebooted
so countermeasures can be taken in case this was not done on purpose.

In omnect Secure OS this feature - named identically to the
[Linux kernel's subsystem](https://docs.kernel.org/admin-guide/pstore-blk.html)
which it is based upon - was introduced to allow
for keeping track of such issues and also reboots in general.

Beside the kernel sub-system the feature relies on the capability of
devices to retain certain information across system starts.

Not all devices provide suitable persistent memory to keep such
information across power cycles or power failures, but where available
this capability is taken advantage of. This currently applies to x86
based devices with BIOS/UEFI firmware only.

On other devices, where possible, the kernel provided driver `ramoops`
is used together with a defined RAM area - which mustn't be otherwise
touched by firmware and/or kernel during restarts - to yield similar
functionality.
However, power cycles or power fails cannot be distinguished from
intentional shutdowns on such systems while lacking means to store an
appropriate hint that survives an accompanying powerless state.

## The Mechanisms Used

As already mentioned above, the fundament for most reboot reason
detection functionality forms Linux kernel sub-system `pstore`
together with some extra drivers depending on the type of the device
used.

### `pstore`

The `pstore` sub-system contains a dedicated filesystem which gets
automatically mounted during system start under `/sys/fs/pstore`.

Depending on configuration and system status, the kernel places
various files into that file system, reflecting the system's run
history to some extent.

Files named after the following schemes can appear there, depending on
system type:
- for `ramoops` devices:
  - `console-ramoops-0`
	contains kernel log messages of previous system run in general,
	limited to the available space in the defined RAM area
  - `pmsg-ramoops-0`
	contains whatever was written to device `/dev/pmsg0` during
	previous system run; this is used to record reboot hints only, no
	other system instance uses it
  - `dmesg-ramoops-0`
	again contains kernel log messages of previous system run, but
	here belonging to a kernel crash/oops; as with console messages
	above the amount of kernel log messages stored is limited by the
	allocated RAM area
- for (U)EFI devices
  - e.g. `dmesg-efi-155741337601001`
	also contains kernel log messages, but only small chunks thereof
	and "tagged" in-line with a special first line telling about the
	kind of log message this is a part of: normal console log or
	system crash/emergency log; these pieces need to be gathered for a
	complete log
	
	**NOTE:** these files actually reflect data of EFI variables as
	found in directory `/sys/firmware/efi/efivars/` and removal in
	pstore path cause also corresponding EFI variables to get removed.
	However, actual removal might only be carried out by (U)EFI
	firmware during next system start.

### EFI Variables

On (U)EFI there is no such thing as a `pmsg` file, like on `ramoops`
supporting systems, which can hold hints about intentional reboot
reason.
To compensate for this lack, a specifically named EFI variable is used
instead: `reboot-reason-53d7f47e-126f-bd7c-d98a-5aa0643aa921`

As for `pstore` EFI variables have a related (pseudo-)filesystem
which again is automatically mounted during system start.

It is located under `/sys/firmware/efi/efivars/` and holds all kinds of
variables which are regularly stored in EFI variable space.

With the help of tool `efivar` such variables can be created, modified
or read where reading a variable's content returns not only the data
part of the variable but also some meta data.

Deletion of variables is done by standard means of filesystem
manipulation, i.e. via a simple `rm`.
Also reading data content of variables can be carried out by directly
reading sysfs files.
However, the kernel prepares for accidental manipulation of EFI
variables by marking them `invariant`.
So, prior to actually removing a variable by its corresponding file,
this attribute has to be reverted manually by issuing command
`chattr -i` on it.

## Implementation

This feature consists of several parts:
- kernel configuration to enable ...
  - `pstore` sub-system
  - (pseudo-)persistent memory:
	- EFI variable store, or
	- driver `ramoops`
- a script allowing for ...
  - registering of annotations for intentional system reboots
  - analysis of boot annotations to determine the reason of last reboot
- instrumentation of reboot reason annotation scripts for intentional
  reboots, like:
  - reboot via omnect-device-service
    (local API or triggered by omnect portal)
  - factory reset
    (local API or triggered by omnect portal)
  - software update
  - rollback after software update due to failed update validation
  - general reboot or shutdown, e.g. invoked over SSH tunnel, both
    realized via system services
  - failed system start-up due to missing network online state
  - standard reboot or shutdown through dedicated services

**Note:** actual script and underlying service files for its
instrumentation are part of repository
[omnect-device-service](https://github.com/omnect/omnect-device-service/)

### Kernel Configuration

The kernel configuration required for reboot reason support is managed
in a [kernel config fragment](../recipes-kernel/linux/files/pstore.cfg).

It is activated via machine feature `omnect_pstore`.

### Reboot Reason Script

At the core of the reboot reason feature there is the script
`omnect_reboot_reason.sh` which is located in repository of
[omnect-device-service](https://github.com/omnect/omnect-device-service/healthcheck/omnect_reboot_reason.sh).

It supports several commands:
- `log`: store indicator of reboot about to happen
- `get`: analyze current boot, i.e. console, dmesg and pmsg files, and
  generate a reboot reason report - including gathered files - in a
  sub-directory under `/var/lib/omnect/reboot-reason/`
- `boottag_get` / `boottag_set`: special handling for EFI type
  systems; see chapter [Specialities: EFI Systems](#Specialities: EFI Systems)
below
- `is_enabled`
  this command allows for easy run-time detection whether or not the
  system really does support reboot reason feature

For detailed information on how this script works and which data
structures are involved for reason logging as well as reboot reason
report generation, have a look directly into the contained
documentation.

### Dedicated System Services

To able of tracking reboot reasons, standard reboot paths need to be
tracked.

This is done by adding two services activated in the wake of systemd
reboots or shutdowns:
- `omnect-pstore-log-shutdown.service`
- `omnect-pstore-log-reboot.service`

In both services an appropriate reboot hint gets logged.

For the analysis of the reason which lead to the current system run
there is another service responsible:
- `omnect-reboot-reason.service`

It invokes the `get` command of the script, yielding a report
directory with involved files and the result file `reboot-reason.json`

- `omnect-pstore-boottag.service`

This service is specific to EFI systems. See chapter
[Specialities: EFI Systems](#Specialities: EFI Systems) below for
explanation of its purpose.

## Specialities: U-Boot Systems

As already mentioned in [chapter Motivation](#Motivation) systems
starting via U-Boot don't normally have any persistent storage backing
the `pstore` kernel sub-system.

While it is possible to also use a dedicated partition on a persistent
storage device - eMMC or SATA/PCIe/NVMe disk - this has also
disadvantages.

Firstly, any permanent kernel logging to it, possibly happening in
addition to the standard kernel logging, can lead to the storage
waering off earlier.

But more important is the fact that this type of logging requires a
lot more intact kernel infrastructure to carry out write operations in
a system crash situation.

So, sub-system `pstore` is used on such systems only with kernel
driver `ramoops`, solely relying on RAM access.

The downside of this is that there is no way to differentiate between
an intentional power cycle and a power failure: in either situation
RAM contents will be lost.

## Specialities: EFI Systems

The persistent memory available in EFI systems allow for more complete
system start tracking, because even an intentional shutdown followed
by a power cycle can be detected: the reboot reason "shutdown" can be
seen in next system run and logged as correct reason.

However, keeping track of multiple reboots/power failures can be
tricky or even impossible.

The introduction of another EFI variable holding UUIDs of system
starts - made available by kernel through sysfs path
`/proc/sys/kernel/random/boot_id` - tries mitigating this gap by
logging the current boot_id as early as possible during system
startup.

Any intentional reboot will take care of removing the current ID from
the variable.
So. analysis of contained IDs upon `get` operation of reboot reason
script invokedd during system start can deduce that if the EFI
variable holds more than the current ID, then there was definitely (at
least) one unintentional reboot.
