# Workaround: Removing the Pi camera lens without the official tool

The official Raspberry Pi Camera Module v2.1 now comes supplied with a white, injection-moulded tool allowing the fixed-focus lens to be adjusted or removed. This tool makes it very simple to remove the lens from the camera. 

However, some suppliers do not include the lens tool, in which case you will need to 3D print a [picamera2_lens_removal_tool.stl](models/picamera_2_lens_removal_tool.stl):

![Printed lens removal tool](models/picamera_2_lens_removal_tool.stl)

Be sure to use the top surface of the part, i.e. the side that sits on the print bed should face away from the camera module.  This is because any "elephant's foot" will cause it to be slightly the wrong shape.

If you cannot print the lens gripper, or if for some reason it doesn't work, you can also gently grip the lens with needlenose pliers to unscrew it.  However, it is very easy to damage the module accidentally when doing this, so we don't recommend it.

Also, note that this will not fit The Pi camera v1, which has three lugs rather than four. Only the Pi Camera v2 is currently supported in the OpenFlexure software.