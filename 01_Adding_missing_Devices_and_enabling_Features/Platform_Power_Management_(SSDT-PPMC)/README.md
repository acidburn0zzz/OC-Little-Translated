# Platform Power Management Controller (`SSDT-PPMC`)

- What it is: Adds Platform Power Management Controller Device
- What it does: Improves Power Management (supposedly)
- Supported CPU Families:
  - **Desktop**: 6th to 8th Gen Intel (100 and 200-series mainboards only)
  - **Mobile/NUC**: 6th to 8th Gen Intel

## Instructions

- In **DSDT**, search for Address `0x001F0002` or `Device (PPMC)`. Make sure it's the address is not associated with a SATA Device!
- If missing, add `SSDT-PPMC.aml`

**CAUTION**: When using any of the patches, note that `LPC`/`LPCB` name should be consistent with the name used in the original ACPI table.

### Verifying
In IORegistryExplorer search for 'PPMC'. If present, it should look like this:

![PPMC](https://user-images.githubusercontent.com/76865553/140606933-94dbfeda-386e-4885-b2a6-ea214b9f4f07.png)
