//
DefinitionBlock("", "SSDT", 2, "OCLT", "NDGP", 0)
{
    External(_SB.PCI0.RP13.PXSX._PS0, MethodObj)
    External(_SB.PCI0.RP13.PXSX._PS3, MethodObj)
    External(_SB.PCI0.RP13.PXSX._DSM, MethodObj)
 
    If (_OSI ("Darwin"))
    {
        Device(DGPU)
        {
            Name(_HID, "DGPU1000")
            Method (_INI, 0, NotSerialized)
            {
                _OFF()
            }
            
            Method (_ON, 0, NotSerialized)
            {
                //path:
                If (CondRefOf (\_SB.PCI0.RP13.PXSX._PS0))
                {
                    \_SB.PCI0.RP13.PXSX._PS0()
                }
            }
            
            Method (_OFF, 0, NotSerialized)
            {
                //path:
                If (CondRefOf (\_SB.PCI0.RP13.PXSX._PS3))
                {
                    \_SB.PCI0.RP13.PXSX._DSM (Buffer ()
                    {
                    }, 0x0100, 0x1A,Buffer ()
                    { 0x01, 0x00, 0x00, 0x03 })
                    \_SB.PCI0.RP13.PXSX._PS3()
                }
            }
        }
    }
}
//EOF