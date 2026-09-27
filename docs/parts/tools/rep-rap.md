# Fused Filament 3D printer

The microscope has been designed to be printed on low-cost entry-level [fused filament fabrication 3D printers](https://en.wikipedia.org/wiki/Fused_filament_fabrication). Many of these printers are Open-Hardware and originate from the [Rep-Rap project](https://reprap.org/wiki/RepRap).

The core development team routinely test on printers including the [Prusa Mini, Prusa Mk3s, Prusa Mk4](https://www.prusa3d.com/category/3d-printers/)

## Print bed size

All common standard size filament 3D printers will successfully print the microscope parts. 

The largest single part is the microscope stand, which fits in a bounding box 171×134mm (standard is 78mm high, tall is 95mm high). Brim will add to the print bed space used.  
It slices with brim just fitting on the 180×180mm Prusa Mini print bed, even though it is nominally 181mm wide with the 5mm brim.

The main body fits within 145×125×75mm, including the built-in smart brim.

>!! **Resin (SLS) 3D printers are not suitable**  
>!! 
>!! The motion mechanism of the microscope requires the right combination of stiffness and flexibility in different sections of the parts. The designs work well for the FFF filaments PLA and PETG. Common SLS resins are mostly  ABS-like and are too stiff. 
