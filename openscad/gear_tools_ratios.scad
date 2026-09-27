use <libs/utilities.scad>
use <libs/lib_gear_tools.scad>

translate_y(40){
    nut_spinner();
}

translate_y(20){
    labelled_gear_holder(ratio=2);
}

labelled_gear_holder(ratio=18/18);

translate_y(-20){
    labelled_gear_holder(ratio=16/20);
}
