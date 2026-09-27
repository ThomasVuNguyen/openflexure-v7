## Mount the microscope {pagestep}

![](renders/mount_microscope_{{var_optics, default:rms}}{{var_body, default:}}1.png)
![](renders/mount_microscope_{{var_optics, default:rms}}{{var_body, default:}}2.png)

* Place the microscope onto the [microscope stand][prepared microscope stand](fromstep){qty:1, cat:subassembly}.
* The lugs on the microscope should sit on the lugs of the stand.
{{includetext: "* Use four [M3x10 cap head screws](parts/mechanical.yml#CapScrew_M3x10mm_SS){qty: 4, cat:mech}", if: var_stand is not post}}{{includetext:"* Use two [M3x10 cap head screws](parts/mechanical.yml#CapScrew_M3x10mm_SS){qty: 2, cat:mech}", if: var_stand is post}} to fix the microscope in place using the same [Allen key][2.5mm Ball-end Allen key]
