# Sound Card IRQ Patches (`SSDT-HPET`) 

## Description

Sound cards of earlier systems require High Precision Event Timer **HPET** **`PNP0103`** to provide interrupts `0` & `8`, otherwise the sound card will not work properly. 

In most cased, almost all machines have **HPET** without any interrupts. Usually, interrupts `0` & `8` are occupied by **RTC** **`PNP0B00`** or **TIMR** **`PNP0100`** respectively. To solve this issue, we need to fix **HPET**, **RTC** and **TIMR** simultaneously.

## Patching Principle

- Disable **HPET**, **RTC**, **TIMR**.
- Create fake **HPE0**, **RTC0**, **TIM0**.
- Remove `IRQNoFlags (){8}` from **RTC0** and `IRQNoFlags (){0}` from **TIM0** and add them to **HPE0**.

## Patching Method (NEW)

The old patch method described below is outdated, because the patching process can now be automated using **SSDTTime** which can generate the following SSDTs based on analyzing your system's `DSDT`:

* ***SSDT-AWAC*** &rarr; Context-Aware AWAC and Fake RTC
* ***SSDT-EC*** &rarr; OS-aware fake EC for Desktops and Laptops
* ***SSDT-PLUG*** &rarr; Sets plugin-type to 1 on `CPU0`/`PR00`
* ***SSDT-HPET*** &rarr; Patches out IRQ Conflicts
* ***SSDT-PMC*** &rarr; Enables Native NVRAM on True 300-Series Boards

**HOW TO:**

1. Download [**SSDTTime**](https://github.com/corpnewt/SSDTTime) and run it
2. Pres "D", drag in your system's DSDT and hit "ENTER"
3. Generate all the SSDTs you need.
4. The SSDTs will be stored under `Results` inside the `SSDTTime-master`Folder along with `patches_OC.plist`.
5. Copy the generated `SSDTs` to EFI > OC > ACPI
6. Open `patches_OC.plist` and copy the included patches to your `config.plist` (to the same section, of course).
7. Save your config
8. Save. Reboot. Done. 

Audio should work now (assuming AppleALC.kext is present along with the correct layout-id for your on-board audio card).

**NOTE**
If you are editing your config using [**OpenCore Auxiliary Tools**](https://github.com/ic005k/QtOpenCoreConfig/releases), OCAT it will update the list of kexts and .aml files automatically, since it monitors the EFI folder.

<details>
<summary><strong>Old Method </strong>(kept for documentary purposes)</summary

# Sound Card IRQ Patch (manual method)
## About
Below you will find the guide for fixing IRQ issues manually if you don't want to use SSDTTime.

### Technical Background 
Although mostly older platforms (mobile Ivy Bridge for example) are affected by `IRQ` issues which cause the on-board sound not to work since `AppleHDA.kext` is not loaded (only `AppleHDAController.kext` is), the problem can occur on recent platforms as well. 

This is due to the fact that `HPET` is a legacy device from Intel's 6th Gen platform and is only present for backward compatibility with older Windows versions. If you use 7th Gen Intel Core CPU or newer with Windows 8.1+, HPET (High Precision Event Timer) is no longer present in Device Manager (the driver is unloaded).
	
For macOS 10.12 and newer, if the problem occurs on the 6th Gen HPET can be blocked directly to solve the problem. Consult the original DSDT's HPET `_STA` method for specific settings.

- The sound card on earlier machines required part **HPET** **`PNP0103`** to provide interrupt numbers `0` & `8`, otherwise the sound card would not work properly. In reality almost all machines have **HPET** without any interrupt number provided. Usually, interrupt numbers `0` & `8` are occupied by **RTC** **`PNP0B00`**, **TIMR** **`PNP0100`** respectively
- To solve the above problem, we need to fix **HPET**, **RTC** and **TIMR** simultaneously.

## Patching principle
To fix this issue, we use ***SSDT-HPET_RTC_TIMR-fix***, which does the following things:

- Disables original **HPET**, **RTC**, **TIMR** devices,
- Creates fake **HPE0**, **RTC0**, **TIM0** and finally,
- Remove `IRQNoFlags (){8}` from **RTC0** and `IRQNoFlags (){0}` from **TIM0** and adds them to **HPE0**.

## Patching method
Use ***SSDT-HPET_RTC_TIMR-fix*** to disable **HPET**, **RTC** and **TIMR**

### Disable **`HPET`**
Usually, `_STA` exists for HPET, so disabling HPET requires the use of the Preset Variable Method by changing `HPAE`/`HPTE` to `0`:

```swift
External (HPAE, IntObj) /* or External (HPTE, IntObj) */
Scope (\)
    {
    	If (_OSI ("Darwin"))
    	{
    	HPAE =0 /* or HPTE =0 */
    	}
    }
```
**NOTE**: The `HPAE`/`HPTE` variable within `_STA` may vary from machine to machine.
  
### Disable **`RTC`**
Older machines have RTCs without `_STA`, disable RTCs by pressing the `_STA` method. e.g.:

```swift
Method (_STA, 0, NotSerialized)
{
	If (_OSI ("Darwin"))
	{
		Return (0)
	}
		Else
	{
		Return (0x0F)
	}
}
```
### Disable **`TIMR`**
(same as **RTC**)

### Disable **`IPIC`**/ **`PIC`** (optional)
Use ***SSDT-IPIC***. 

If the three-in-one patch alone does not fix audio, add ***SSDT-IPIC*** as well. It disables an existing `IPIC`/`PIC` device, adds a fake one instead and removes `IRQNoFlags{2}`. Adjust the scopes, device names and pci paths according to your `DSDT`.

## Caution
- The names and paths of the `LPC/LPCB`bus as well as `RTC`, `TMR`, `RTC` and `IPIC` devices used in the hotpatch must match the names and paths used in the original `DSDT`.
- These patches cannot be used in conjunction with the following SSDTs:
  - ***SSDT-RTC_Y-AWAC_N*** and OC's Official ***SSDT-AWAC***
  - ***SSDT-RTC0*** and ***SSDT-RTC0-NoFlags***
