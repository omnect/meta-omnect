# Example: an IoT Edge module confined by an AppArmor profile

This example deploys the Azure IoT Edge **SimulatedTemperatureSensor** "hello world"
module and confines its container with a custom AppArmor profile. It demonstrates the
end-to-end path enabled by omnect-os' [Mandatory Access Control support](../../mac_lsm.md):
boot with AppArmor active → load a profile → reference it from the deployment.

Files:

- `omnect-temp-sensor` — the AppArmor profile (Docker's `docker-default` plus one demo
  rule that denies writes under `/tmp/forbidden`).
- `deployment.json` — the IoT Edge deployment manifest. The module's `createOptions`
  contains `"HostConfig":{"SecurityOpt":["apparmor=omnect-temp-sensor"]}`.

> This is example/reference material — nothing here is built into the omnect-os image.
> The profile is loaded manually and the deployment is applied via Azure IoT Hub.

## Prerequisites

1. An omnect-os image built with the `iotedge` kas feature (the AppArmor userspace is
   always present). The device is provisioned to Azure IoT Hub as an **IoT Edge** device.
2. The device is booted with **AppArmor active**. AppArmor is compiled in but DAC is the
   default, so enable it once (see [`doc/mac_lsm.md`](../../mac_lsm.md)):
   ```bash
   echo "lsm=landlock,lockdown,yama,loadpin,safesetid,bpf,apparmor" | sudo tee -a /boot/omnect_extra_bootargs_custom
   sudo omnect_extra_bootargs.sh set
   sudo reboot
   ```
   After reboot, confirm AppArmor is active: `apparmor` appears in
   `cat /sys/kernel/security/lsm` and `aa-status` reports it loaded.

## Apply

1. Copy the profile to the device and load it into the kernel **before** the module
   starts (Docker resolves the profile by name at container creation time):
   ```bash
   scp omnect-temp-sensor omnect@<device>:/tmp/
   ssh omnect@<device>
   sudo cp /tmp/omnect-temp-sensor /etc/apparmor.d/omnect-temp-sensor
   sudo apparmor_parser -r -W /etc/apparmor.d/omnect-temp-sensor
   sudo aa-status | grep omnect-temp-sensor          # should be listed
   ```
2. Apply the deployment from your workstation (cloud-side, via IoT Hub):
   ```bash
   az iot edge set-modules --hub-name <hub> --device-id <device> --content deployment.json
   ```

## Verify

On the device:

```bash
# the container is running under our profile, not docker-default
sudo docker inspect SimulatedTemperatureSensor --format '{{ .AppArmorProfile }}'
# -> omnect-temp-sensor

# the demo rule is enforced: the write is blocked
sudo docker exec SimulatedTemperatureSensor sh -c 'touch /tmp/forbidden_demo'
# -> touch: /tmp/forbidden_demo: Permission denied

# and the kernel logged the denial
sudo dmesg | grep 'apparmor="DENIED".*omnect-temp-sensor'

# meanwhile the module keeps working normally
iotedge logs SimulatedTemperatureSensor          # telemetry messages

# docker reports apparmor as an available security backend
sudo docker info | grep -A3 'Security Options'   # lists "apparmor"
```

## Notes

- If you load (or change) the profile *after* the container is already running, restart
  the module so the new profile takes effect:
  `iotedge restart SimulatedTemperatureSensor` (or `sudo docker restart SimulatedTemperatureSensor`).
- The profile here is copied into the writable `/etc` overlay, so it persists across
  reboots on this device but is not part of the image. To ship a profile on every image
  instead, add a recipe under `recipes-omnect/` that installs it to `/etc/apparmor.d/`
  (`apparmor.service` loads everything there at boot).
- No Docker change is needed: moby on omnect-os has AppArmor support built in.
