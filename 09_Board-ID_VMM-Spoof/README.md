# Using unsupported Board-IDs with macOS Monterey
A set of Booter and Kernel patches which allow installing, booting and updating macOS Monterey on unsupported Board-IDs.

## System requirements
**Minimum macOS**: Big Sur using XNU Kernel 20.4.0 or newer!</br>
**CPU**: Basically, every outdated SMBIOS that supports your CPU but is no longer supported by macOS Monterey. This affects processors of the following Intel CPU families:

- Sandy Bridge (need additionl Sur Plus and RDRAND patches)
- Ivy Bridge
- Haswell (partially)

Since this is a pretty new approach, I have to look into a bit more.

## How it works
The latest version of **OpenCore Legacy Patcher** (OCLP) introduced a new set of booter and kernel patches which make use of macOS Monterey's virtualization capabilities (VMM) to spoof a supported Board-ID reported to Software Update.

These patches skip the Board-ID check of the used hardware, redirecing it to OpenCore which then spoofs a supported Board ID via VMM to the Update Servers via Kernel patches. 

This allows using the correct SMBIOS for a given CPU family even if it is not officially supported by macOS Monterey. This not only improves CPU Powermanagement - especially on Laptops – it also allows installing, booting and updating macOS Monterey with otherwise unsupported hardware:

> Parrotgeek1's VMM patch set would force kern.hv_vmm_present to always return True. With hv_vmm_present returning True, both OSInstallerSetupInternal and SoftwareUpdateCore will set the VMM-x86_64 board ID while the rest of the OS will continue with the original ID.
> 
> - Patching kern.hv_vmm_present over manually setting the VMM CPUID allows for native features such as CPU and GPU power management
>
> **Source**: https://github.com/dortania/OpenCore-Legacy-Patcher/issues/543

The patching consists of two stages:

1. Skipping the Board-ID check and rerouting the Hardware Board-ID to OpenCore (Booter Patches)
2. In the 2nd stage, Kernel patches are used to make Update Servers believe that macOS Monterey is running as a Virtual Machine with a supported Board-ID

I had a look at the [**config.plist**](https://github.com/dortania/OpenCore-Legacy-Patcher/blob/4a8f61a01da72b38a4b2250386cc4b497a31a839/payloads/Config/config.plist) included in OCLP, copied the relevant patches Booter and Kernel patches (and a few others) into my config and tested them.

The attached plist contains these patches to make this work and a few more.

## Applying the Patches
Before you do the following make sure you have a working backup of your EFI stored on a FAT32 formatted USB stick to boot your PC from just in case something goes wrong!

- Download the attached .plist
- Open it with a plist editor
- Copy the patches located under Booter > Patch into clipboard and paste them into your OpenCore config at the same location
- Do the same for the Kernel Patches. Enable additional patches if requires (for Sandy Brige for example)
- Save config 
- Reboot.

Enjoy macOS Monterey with the correct SMBIOS for your CPU and Updates!

### About the Kernel Patches
In the .plist, only 3 of the 9 kernel patches are enabled by default. Enable additional one as needed. Here's what they do:

- **Patches 0-2**: Enable board ID spoof via VMM in macOS 12.0.1 (active) >> Allows booting, installing and updating macOS 12.x with unsupported Board-ID and SMBIOS
- **Patch 3:** seems to be related to Apple's SMC Controller in real Macs (disabled)
- **Patch 4**: disables [Library Validation Enforcement](https://www.naut.ca/blog/2020/11/13/forbidden-commands-to-liberate-macos/). (disabled)
- **Patches 5-6**: SurPlus patches for Race Condition Fix on Sandy Bridge and older CPUs. Fixes issues for macOS 11.3 onward, where newer Big Sur builds often wouldn't boot with SMBIOS `MacPro5,1`. (disabled)
- **Patches 7-8**: Experimental RDRAND Patches to re-enable Sandy Bridge CPU support in Monterey 12.1 beta (disabled)

<details>
<summary><strong>Background Info: My test</strong> (Click to show content!)</summary>

## Testing the Patches

I tested these patches on my Lenovo T530 Notebook, using an Ivy Bridge CPU with `MacBookPro10,1` SMBIOS, which is officialy not compatible with macOS Monterey. After rebooting, the system started without using `-no_compat_check` boot-arg, as you can see here:

![Proof01](https://user-images.githubusercontent.com/76865553/139529766-87daac84-126e-4dfc-ac1d-37e4730e0bbf.png)

Terminal shows the currnetly used Board-ID which belongs to the `MacBookPro10,1` SMBIOS as you can see in Clover Configurator. Usually, running macOS would require using `MacBookPro11,4` which uses a different Board-ID as you can see in the Clover Configuratos snippet:

![Proof02](https://user-images.githubusercontent.com/76865553/139529778-6f82306a-22db-43dd-b594-c863af6e4ddd.png)
  
Next, I checked for updates and was offered macOS 12.1 beta:

![Proof03](https://user-images.githubusercontent.com/76865553/139529788-d8ca770e-f8c2-49a8-a44e-908137f5e45c.png)
  
Which I installed…
  
![Proof04](https://user-images.githubusercontent.com/76865553/139529792-d92e52d3-5f91-4044-b788-730d603327b3.png)

Installation went smoothly and macOS 12.1 booted without issues:

![About](https://user-images.githubusercontent.com/76865553/139529802-3ea61297-7c7b-4369-8c21-4160b437f1a6.png)
</details>

## Credits
- Dortania for [**OpenCore Legacy Patcher**](https://github.com/dortania/OpenCore-Legacy-Patcher)
- parrotgeek1 for [**VMM Patches**](https://github.com/dortania/OpenCore-Legacy-Patcher/blob/4a8f61a01da72b38a4b2250386cc4b497a31a839/payloads/Config/config.plist#L1222-L1281) 
- reenigneorcim for [**SurPlus**](https://github.com/reenigneorcim/SurPlus)
- Khronokernel for [**RDRAND Patches**](https://github.com/dortania/OpenCore-Legacy-Patcher/commit/c6b3aaaeb78d56f98a94d7991fd3019190b48dd3)